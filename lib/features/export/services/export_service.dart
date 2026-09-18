/// Turns a collected [ExportBundle] into the bytes of a file to save.
///
/// This is the orchestrator. It decides between a single file and a zip,
/// renders the chosen format, decrypts the attachments that are allowed out,
/// and reports everything it left behind.
///
/// **It never partially succeeds in silence.** Anything skipped comes back in
/// [ExportResult.skipped] so the screen can name it. An export that quietly
/// omitted a locked file would be worse than one that failed outright.
///
/// **It holds no user-facing text.** The words written into the files come in
/// as [ExportLabels]; what it reports back is typed ([ExportOmissionReason],
/// [ExportFailureReason]) and the screen words it in the user's language.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/core/security/vault_payload.dart';
import 'package:sreerajp_journal_vault/core/utils/safe_file_name.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_markdown.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_plain_text.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_html_builder.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_labels.dart';
import 'package:sreerajp_journal_vault/features/export/services/html_pdf_service.dart';

part 'export_service_models.dart';
part 'export_service_rendering.dart';

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

  /// The README placed in a zip bundle. A file name, not text for the reader.
  static const String _readmeFileName = 'README.txt';

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
  /// [labels] are the words written into the files, in the language the user
  /// exported in.
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
    required ExportLabels labels,
    bool includeAttachments = false,
    bool includeMetadata = true,
    String? password,
  }) async {
    if (bundle.isEmpty) {
      throw const ExportException(ExportFailureReason.nothingToExport);
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
      labels: labels,
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
      labels: labels,
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

  // --- Entry files ----------------------------------------------------------

  Future<List<_OutputFile>> _renderEntryFiles(
    ExportBundle bundle, {
    required ExportFormat format,
    required ExportLabels labels,
    required bool includeMetadata,
    required Set<int> linkableImageIds,
    required List<ExportOmission> skipped,
  }) async {
    // HTML and PDF hold every entry in one document, with a page break
    // between them.
    if (format.combinesEntriesIntoOneFile) {
      final html = await _htmlBuilder.build(
        bundle,
        labels: labels,
        includeMetadata: includeMetadata,
        exportedAt: _now(),
        imageSources: await _resolveInlineImages(bundle, skipped),
      );

      final baseName = bundle.entryCount == 1
          ? safeFileName(_titleOf(bundle.documents.single, labels))
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
              labels: labels,
              includeMetadata: includeMetadata,
              linkableImageIds: linkableImageIds,
            )
          : _plainTextFor(
              document,
              labels: labels,
              includeMetadata: includeMetadata,
            );

      final name = _uniqueName(
        _entryFileName(document, format.extension, labels),
        usedNames,
      );
      files.add(_OutputFile(name, Uint8List.fromList(utf8.encode(text))));
    }

    return files;
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
            ExportOmissionReason.lockedInlineImage,
            image.fileName,
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
            ExportOmissionReason.unreadableInlineImage,
            image.fileName,
          ),
        );
        continue;
      }

      sources[image.attachmentId] =
          'data:${_imageMimeType(image)};base64,${base64.encode(bytes)}';
    }

    return sources;
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
            ExportOmissionReason.lockedAttachment,
            attachment.fileName,
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
            ExportOmissionReason.unreadableAttachment,
            attachment.fileName,
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
            ExportOmissionReason.unreadableVoiceNote,
            note.fileName,
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

  // --- Zip ------------------------------------------------------------------

  Uint8List _zip({
    required ExportBundle bundle,
    required ExportFormat format,
    required ExportLabels labels,
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
      labels.readme(
        journalTitle: bundle.journalTitle,
        exportedAt: formatDate(_now()),
        entryCount: bundle.entryCount,
        formatName: labels.formatName(format),
      ),
    );
    archive.addFile(ArchiveFile(_readmeFileName, readme.length, readme));

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
