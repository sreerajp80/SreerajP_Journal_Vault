/// Turns a collected [ExportBundle] into the bytes of a file to save.
///
/// This is the orchestrator. It decides between a single file and a zip,
/// renders the chosen format, decrypts the attachments that are allowed out,
/// and reports everything it left behind.
///
/// **It never partially succeeds in silence.** Anything skipped comes back in
/// [ExportResult.skipped] so the screen can name it. An export that quietly
/// omitted a locked file would be worse than one that failed outright.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/core/security/vault_payload.dart';
import 'package:sreerajp_journal_vault/core/utils/safe_file_name.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_markdown.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_plain_text.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_html_builder.dart';
import 'package:sreerajp_journal_vault/features/export/services/html_pdf_service.dart';

/// Something that was left out of an export, and why.
class ExportOmission {
  const ExportOmission(this.message);

  /// Already worded for the user — see [ExportStrings].
  final String message;

  @override
  String toString() => message;
}

/// The finished export, ready to be written to disk.
class ExportResult {
  const ExportResult({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.entryCount,
    this.skipped = const [],
    this.isEncrypted = false,
  });

  final Uint8List bytes;

  /// The suggested file name, including the extension.
  final String fileName;
  final String mimeType;
  final int entryCount;

  /// Everything that could not be included.
  final List<ExportOmission> skipped;

  /// True when [bytes] are sealed under a password rather than readable.
  final bool isEncrypted;

  /// True when the file is a zip bundle. False for a sealed export: what is
  /// inside is not visible from the outside, which is the point.
  bool get isZip => fileName.endsWith('.zip');
}

/// Thrown when an export cannot be produced at all.
class ExportException implements Exception {
  const ExportException(this.message);

  final String message;

  @override
  String toString() => 'ExportException: $message';
}

class ExportService {
  // Private fields as named parameters — the same style the attachment
  // services use. Dart drops the underscore for the caller, so this reads as
  // `ExportService(cryptoStorage: ...)`.
  ExportService({
    required this._cryptoStorage,
    this._htmlBuilder = const ExportHtmlBuilder(),
    this._pdfService = const HtmlPdfService(),
    VaultEnvelope? envelope,
    this._now = DateTime.now,
  }) : _envelope = envelope ?? VaultEnvelope();

  final AttachmentCryptoStorage _cryptoStorage;
  final ExportHtmlBuilder _htmlBuilder;
  final HtmlPdfService _pdfService;

  /// The one sealed-file format the app writes. Shared with the backup
  /// archive so there is a single versioned envelope, not one per feature.
  final VaultEnvelope _envelope;

  /// Injectable so an export's timestamps are predictable in a test.
  final DateTime Function() _now;

  /// Builds the export.
  ///
  /// [includeAttachments] and [includeMetadata] mirror the scope the bundle was
  /// collected with. They are passed again rather than read off the bundle so
  /// this service stays usable on a hand-built bundle in a test.
  ///
  /// Pass a [password] to seal the finished file. Sealing happens here, before
  /// the bytes are handed to the save dialog, so a protected export never
  /// exists on disk in the clear.
  Future<ExportResult> build(
    ExportBundle bundle, {
    required ExportFormat format,
    bool includeAttachments = false,
    bool includeMetadata = true,
    String? password,
  }) async {
    if (bundle.isEmpty) {
      throw const ExportException(ExportStrings.nothingToExport);
    }

    final skipped = <ExportOmission>[];

    // Attachments are gathered first so the entry renderers know which files
    // actually made it into the bundle: a Markdown image link must not point
    // at a file that was skipped.
    final attachmentFiles = includeAttachments
        ? await _collectAttachmentFiles(bundle, skipped)
        : <_OutputFile>[];

    final entryFiles = await _renderEntryFiles(
      bundle,
      format: format,
      includeMetadata: includeMetadata,
      linkableImageIds: attachmentFiles
          .map((f) => f.attachmentId)
          .nonNulls
          .toSet(),
      skipped: skipped,
    );

    // A zip is needed when there is more than one file to deliver: several
    // entry files, or any attachment. A single entry with nothing attached
    // stays a plain file, which is far friendlier to open.
    final needsZip = entryFiles.length > 1 || attachmentFiles.isNotEmpty;

    if (!needsZip) {
      final single = entryFiles.single;
      return _finish(
        ExportResult(
          bytes: single.bytes,
          fileName: single.name,
          mimeType: format.mimeType,
          entryCount: bundle.entryCount,
          skipped: skipped,
        ),
        password: password,
      );
    }

    final zipBytes = _zip(
      bundle: bundle,
      format: format,
      entryFiles: entryFiles,
      attachmentFiles: attachmentFiles,
    );

    return _finish(
      ExportResult(
        bytes: zipBytes,
        fileName:
            '${safeFileName(bundle.journalTitle, fallback: 'journal')}'
            '_export_${formatDateOnly(_now())}.zip',
        mimeType: 'application/zip',
        entryCount: bundle.entryCount,
        skipped: skipped,
      ),
      password: password,
    );
  }

  /// Seals [result] when a password was given, and hands it back untouched
  /// when one was not.
  ///
  /// The real file name and mime type go **inside** the sealed bytes, in a
  /// [VaultPayloadHeader], and the sealed file is offered under a plain,
  /// dated name instead. An entry titled "Leaving my job" must not still be
  /// readable in the file name after the file itself has been encrypted.
  Future<ExportResult> _finish(
    ExportResult result, {
    required String? password,
  }) async {
    if (password == null) return result;

    // Throws BackupPasswordException-equivalent before any bytes are sealed.
    validateVaultPassword(password);

    final sealed = await _envelope.seal(
      plainBytes: wrapVaultPayload(
        bytes: result.bytes,
        header: VaultPayloadHeader(
          kind: vaultPayloadKindExport,
          fileName: result.fileName,
          mimeType: result.mimeType,
          createdAt: _now(),
        ),
      ),
      password: password,
    );

    return ExportResult(
      bytes: sealed,
      fileName:
          'journal_export_${formatDateOnly(_now())}'
          '.$vaultSealedFileExtension',
      mimeType: 'application/octet-stream',
      entryCount: result.entryCount,
      skipped: result.skipped,
      isEncrypted: true,
    );
  }

  // --- Entry files ----------------------------------------------------------

  Future<List<_OutputFile>> _renderEntryFiles(
    ExportBundle bundle, {
    required ExportFormat format,
    required bool includeMetadata,
    required Set<int> linkableImageIds,
    required List<ExportOmission> skipped,
  }) async {
    // HTML and PDF hold every entry in one document, with a page break
    // between them.
    if (format.combinesEntriesIntoOneFile) {
      final html = await _htmlBuilder.build(
        bundle,
        includeMetadata: includeMetadata,
        exportedAt: _now(),
        imageSources: await _resolveInlineImages(bundle, skipped),
      );

      final baseName = bundle.entryCount == 1
          ? safeFileName(_titleOf(bundle.documents.single))
          : safeFileName(bundle.journalTitle, fallback: 'journal');

      if (format == ExportFormat.html) {
        return [
          _OutputFile('$baseName.html', Uint8List.fromList(utf8.encode(html))),
        ];
      }

      final pdfBytes = await _pdfService.convert(html: html);
      return [_OutputFile('$baseName.pdf', pdfBytes)];
    }

    // Markdown and plain text produce one file per entry: a folder of files is
    // easier to work with than one enormous document, and it is what
    // re-importing expects.
    final files = <_OutputFile>[];
    final usedNames = <String>{};

    for (final document in bundle.documents) {
      final text = format == ExportFormat.markdown
          ? _markdownFor(
              document,
              includeMetadata: includeMetadata,
              linkableImageIds: linkableImageIds,
            )
          : _plainTextFor(document, includeMetadata: includeMetadata);

      final name = _uniqueName(
        _entryFileName(document, format.extension),
        usedNames,
      );
      files.add(_OutputFile(name, Uint8List.fromList(utf8.encode(text))));
    }

    return files;
  }

  String _titleOf(ExportDocument document) {
    final title = document.title?.trim();
    return title == null || title.isEmpty ? ExportStrings.untitledEntry : title;
  }

  /// `2026-08-16_my-entry.md` — dated first so a folder sorts chronologically.
  String _entryFileName(ExportDocument document, String extension) {
    final date = document.effectiveDate;
    final datePart = date == null ? '' : '${formatDateOnly(date)}_';
    return '$datePart${safeFileName(_titleOf(document))}.$extension';
  }

  /// Two entries on the same day can share a title, and a zip with two
  /// identical names loses one of them.
  String _uniqueName(String name, Set<String> used) {
    if (used.add(name)) return name;
    final dot = name.lastIndexOf('.');
    final stem = dot == -1 ? name : name.substring(0, dot);
    final extension = dot == -1 ? '' : name.substring(dot);
    var counter = 2;
    while (!used.add('$stem($counter)$extension')) {
      counter++;
    }
    return '$stem($counter)$extension';
  }

  String _markdownFor(
    ExportDocument document, {
    required bool includeMetadata,
    Set<int> linkableImageIds = const {},
  }) {
    final buffer = StringBuffer('# ${_titleOf(document)}\n');

    if (includeMetadata) {
      final meta = _metadataLines(document);
      if (meta.isNotEmpty) {
        buffer.writeln();
        for (final line in meta) {
          buffer.writeln('*$line*  ');
        }
      }
    }

    buffer
      ..writeln()
      ..writeln(
        renderMarkdown(document.blocks, linkableImageIds: linkableImageIds),
      );

    if (document.voiceNotes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## ${ExportStrings.labelVoiceNotes}');
      for (final note in document.voiceNotes) {
        buffer.writeln(
          '- ${ExportStrings.voiceNoteDuration(note.formattedDuration)} — '
          '${note.fileName}',
        );
        final transcript = note.transcript?.trim();
        if (transcript != null && transcript.isNotEmpty) {
          buffer.writeln('  > ${transcript.replaceAll('\n', '\n  > ')}');
        }
      }
    }

    if (document.attachments.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## ${ExportStrings.labelAttachments}');
      for (final attachment in document.attachments) {
        final suffix = attachment.isLocked ? ' (locked — not included)' : '';
        buffer.writeln('- ${attachment.fileName}$suffix');
      }
    }

    return buffer.toString().trimRight();
  }

  String _plainTextFor(
    ExportDocument document, {
    required bool includeMetadata,
  }) {
    final title = _titleOf(document);
    final buffer = StringBuffer()
      ..writeln(title)
      ..writeln('=' * (title.runes.length > 80 ? 80 : title.runes.length));

    if (includeMetadata) {
      for (final line in _metadataLines(document)) {
        buffer.writeln(line);
      }
    }

    buffer
      ..writeln()
      ..writeln(renderPlainText(document.blocks));

    if (document.voiceNotes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('${ExportStrings.labelVoiceNotes}:');
      for (final note in document.voiceNotes) {
        buffer.writeln(
          '  ${ExportStrings.voiceNoteDuration(note.formattedDuration)} — '
          '${note.fileName}',
        );
        final transcript = note.transcript?.trim();
        if (transcript != null && transcript.isNotEmpty) {
          buffer.writeln('    ${transcript.replaceAll('\n', '\n    ')}');
        }
      }
    }

    if (document.attachments.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('${ExportStrings.labelAttachments}:');
      for (final attachment in document.attachments) {
        final suffix = attachment.isLocked ? ' (locked — not included)' : '';
        buffer.writeln('  ${attachment.fileName}$suffix');
      }
    }

    return buffer.toString().trimRight();
  }

  List<String> _metadataLines(ExportDocument document) {
    final lines = <String>[];
    final date = document.effectiveDate;
    if (date != null) {
      lines.add('${ExportStrings.labelDate}: ${formatDate(date)}');
    }
    if (document.tags.isNotEmpty) {
      lines.add('${ExportStrings.labelTags}: ${document.tags.join(', ')}');
    }
    if (document.mood != null) {
      final note = document.moodNote?.trim();
      final value = note == null || note.isEmpty
          ? ExportStrings.moodValue(document.mood!)
          : '${ExportStrings.moodValue(document.mood!)} — $note';
      lines.add('${ExportStrings.labelMood}: $value');
    }
    return lines;
  }

  // --- Inline images --------------------------------------------------------

  /// Builds the `data:` URIs for the images sitting inside the writing.
  ///
  /// These are resolved whether or not attachments were included, because an
  /// inline image is part of the page — an HTML or PDF export with holes where
  /// the pictures were is not the entry the user wrote. The file is decrypted,
  /// read, and its temporary copy deleted straight away, one at a time.
  ///
  /// **A locked image is never decoded.** Locking it was a deliberate act and
  /// an export must not be a way around it, so it is reported as left out and
  /// the page names it instead. Same rule as [_collectAttachmentFiles].
  Future<Map<int, String>> _resolveInlineImages(
    ExportBundle bundle,
    List<ExportOmission> skipped,
  ) async {
    final sources = <int, String>{};
    final seen = <int>{};

    for (final image in bundle.allInlineImages) {
      // The same picture can be embedded more than once, and in more than one
      // entry. Decrypt it once and reuse the data URI.
      if (!seen.add(image.attachmentId)) continue;

      if (image.isLocked) {
        skipped.add(
          ExportOmission(
            ExportStrings.skippedLockedInlineImage(image.fileName),
          ),
        );
        continue;
      }

      final bytes = await _decrypt(
        encryptedPath: image.encryptedPath,
        nonceBase64: image.nonceBase64,
        keyReference: image.keyReference,
        fileName: image.fileName,
      );

      if (bytes == null) {
        skipped.add(
          ExportOmission(
            ExportStrings.skippedUnreadableInlineImage(image.fileName),
          ),
        );
        continue;
      }

      sources[image.attachmentId] =
          'data:${_imageMimeType(image)};base64,${base64.encode(bytes)}';
    }

    return sources;
  }

  /// The MIME type to stamp on an inline image's data URI.
  ///
  /// Only real image types are allowed through. A row whose MIME type is
  /// missing or is not an image falls back to PNG rather than putting an
  /// arbitrary type into the page's markup.
  String _imageMimeType(ExportAttachmentRef image) {
    final mime = image.mimeType?.trim().toLowerCase();
    if (mime == null || !mime.startsWith('image/')) return 'image/png';
    // Anything beyond the type itself (a `;charset=` tail, stray characters)
    // has no business in a data URI.
    return RegExp(r'^image/[a-z0-9.+-]+$').hasMatch(mime) ? mime : 'image/png';
  }

  // --- Attachments ----------------------------------------------------------

  /// Decrypts the attachments and voice notes that are allowed out.
  ///
  /// Each file is decrypted, copied into the bundle, and its temporary
  /// decrypted copy deleted straight away — so at no point is more than one
  /// plaintext file sitting in the cache.
  Future<List<_OutputFile>> _collectAttachmentFiles(
    ExportBundle bundle,
    List<ExportOmission> skipped,
  ) async {
    final files = <_OutputFile>[];
    final usedNames = <String>{};

    for (final attachment in bundle.allAttachments) {
      // A lock was a deliberate act. An export must not be a way around it.
      if (attachment.isLocked) {
        skipped.add(
          ExportOmission(
            ExportStrings.skippedLockedAttachment(attachment.fileName),
          ),
        );
        continue;
      }

      final bytes = await _decrypt(
        encryptedPath: attachment.encryptedPath,
        nonceBase64: attachment.nonceBase64,
        keyReference: attachment.keyReference,
        fileName: attachment.fileName,
      );

      if (bytes == null) {
        skipped.add(
          ExportOmission(
            ExportStrings.skippedUnreadableAttachment(attachment.fileName),
          ),
        );
        continue;
      }

      final name = _uniqueName(
        exportAttachmentFileName(attachment.attachmentId, attachment.fileName),
        usedNames,
      );
      files.add(
        _OutputFile(name, bytes, attachmentId: attachment.attachmentId),
      );
    }

    for (final note in bundle.allVoiceNotes) {
      final bytes = await _decrypt(
        encryptedPath: note.encryptedPath,
        nonceBase64: note.nonceBase64,
        keyReference: note.keyReference,
        fileName: note.fileName,
      );

      if (bytes == null) {
        skipped.add(
          ExportOmission(
            ExportStrings.skippedUnreadableVoiceNote(note.fileName),
          ),
        );
        continue;
      }

      final name = _uniqueName(
        'voice_${note.voiceNoteId}_${safeFileName(note.fileName, fallback: 'recording')}',
        usedNames,
      );
      files.add(_OutputFile(name, bytes));
    }

    return files;
  }

  /// Decrypts one stored file, or returns null when it cannot be read.
  ///
  /// A missing SD card or a damaged file must cost the export that one file,
  /// not the whole run — the user still wants the other nine years of writing.
  Future<Uint8List?> _decrypt({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) async {
    AttachmentTempFileHandle? handle;
    try {
      handle = await _cryptoStorage.decryptToTempFile(
        encryptedPath: encryptedPath,
        nonceBase64: nonceBase64,
        keyReference: keyReference,
        fileName: fileName,
      );
      return await handle.file.readAsBytes();
    } catch (error) {
      // The file name is user content and never goes in a log.
      AppLogger.warning(
        'export: could not decrypt an attachment for export',
        error: AppLogger.redact(error),
      );
      return null;
    } finally {
      // The decrypted copy is deleted whether or not the read worked.
      await handle?.release();
    }
  }

  // --- Zip ------------------------------------------------------------------

  Uint8List _zip({
    required ExportBundle bundle,
    required ExportFormat format,
    required List<_OutputFile> entryFiles,
    required List<_OutputFile> attachmentFiles,
  }) {
    final archive = Archive();

    for (final file in entryFiles) {
      archive.addFile(
        ArchiveFile('entries/${file.name}', file.bytes.length, file.bytes),
      );
    }
    for (final file in attachmentFiles) {
      archive.addFile(
        ArchiveFile('attachments/${file.name}', file.bytes.length, file.bytes),
      );
    }

    final readme = utf8.encode(
      ExportStrings.readmeBody(
        journalTitle: bundle.journalTitle,
        exportedAt: formatDate(_now()),
        entryCount: bundle.entryCount,
        formatName: format.label,
      ),
    );
    archive.addFile(
      ArchiveFile(ExportStrings.readmeFileName, readme.length, readme),
    );

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }
}

/// One file on its way into the export.
class _OutputFile {
  const _OutputFile(this.name, this.bytes, {this.attachmentId});

  final String name;
  final Uint8List bytes;

  /// The attachment row this file came from, when it is an attachment. Null for
  /// entry files and voice notes. Used to tell the Markdown renderer which
  /// images it may safely link to.
  final int? attachmentId;
}
