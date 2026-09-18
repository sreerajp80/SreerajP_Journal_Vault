part of 'export_service.dart';

extension _ExportServicePart1 on ExportService {
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

  String _titleOf(ExportDocument document, ExportLabels labels) {
    final title = document.title?.trim();
    return title == null || title.isEmpty ? labels.untitledEntry : title;
  }

  /// `2026-08-16_my-entry.md` — dated first so a folder sorts chronologically.
  String _entryFileName(
    ExportDocument document,
    String extension,
    ExportLabels labels,
  ) {
    final date = document.effectiveDate;
    final datePart = date == null ? '' : '${formatDateOnly(date)}_';
    return '$datePart${safeFileName(_titleOf(document, labels))}.$extension';
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

  /// The note written after a locked attachment's name.
  String _lockedSuffix(ExportAttachmentRef attachment, ExportLabels labels) =>
      attachment.isLocked ? ' (${labels.lockedNotIncluded})' : '';

  String _markdownFor(
    ExportDocument document, {
    required ExportLabels labels,
    required bool includeMetadata,
    Set<int> linkableImageIds = const {},
  }) {
    final buffer = StringBuffer('# ${_titleOf(document, labels)}\n');

    if (includeMetadata) {
      final meta = _metadataLines(document, labels);
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
        renderMarkdown(
          document.blocks,
          labels: labels,
          linkableImageIds: linkableImageIds,
        ),
      );

    if (document.voiceNotes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## ${labels.voiceNotes}');
      for (final note in document.voiceNotes) {
        buffer.writeln(
          '- ${labels.recording(note.formattedDuration)} — '
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
        ..writeln('## ${labels.attachments}');
      for (final attachment in document.attachments) {
        buffer.writeln(
          '- ${attachment.fileName}${_lockedSuffix(attachment, labels)}',
        );
      }
    }

    return buffer.toString().trimRight();
  }

  String _plainTextFor(
    ExportDocument document, {
    required ExportLabels labels,
    required bool includeMetadata,
  }) {
    final title = _titleOf(document, labels);
    final buffer = StringBuffer()
      ..writeln(title)
      ..writeln('=' * (title.runes.length > 80 ? 80 : title.runes.length));

    if (includeMetadata) {
      for (final line in _metadataLines(document, labels)) {
        buffer.writeln(line);
      }
    }

    buffer
      ..writeln()
      ..writeln(renderPlainText(document.blocks, labels: labels));

    if (document.voiceNotes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('${labels.voiceNotes}:');
      for (final note in document.voiceNotes) {
        buffer.writeln(
          '  ${labels.recording(note.formattedDuration)} — '
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
        ..writeln('${labels.attachments}:');
      for (final attachment in document.attachments) {
        buffer.writeln(
          '  ${attachment.fileName}${_lockedSuffix(attachment, labels)}',
        );
      }
    }

    return buffer.toString().trimRight();
  }

  List<String> _metadataLines(ExportDocument document, ExportLabels labels) {
    final lines = <String>[];
    final date = document.effectiveDate;
    if (date != null) {
      lines.add('${labels.date}: ${formatDate(date)}');
    }
    if (document.tags.isNotEmpty) {
      lines.add('${labels.tags}: ${document.tags.join(', ')}');
    }
    if (document.mood != null) {
      final note = document.moodNote?.trim();
      final value = note == null || note.isEmpty
          ? labels.moodValue(document.mood!)
          : '${labels.moodValue(document.mood!)} — $note';
      lines.add('${labels.mood}: $value');
    }
    return lines;
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
}
