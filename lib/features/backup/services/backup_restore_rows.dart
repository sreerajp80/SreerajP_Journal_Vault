part of 'backup_restore_service.dart';

extension _BackupRestoreServicePart3 on BackupRestoreService {
  // ───────────────────────── reading the archive ─────────────────────────

  Future<_ReadArchive> _readArchive({
    required String backupPath,
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const BackupCorruptedException(backupWrongPasswordDetails);
    }

    final file = File(backupPath);
    if (!await file.exists()) {
      throw const BackupCorruptedException(backupInvalidArchiveDetails);
    }

    final Uint8List decrypted;
    try {
      decrypted = await _envelope.open(
        sealedBytes: await file.readAsBytes(),
        password: password,
      );
    } on VaultVersionTooNewException catch (e) {
      // The envelope speaks in its own version numbers; the restore screen
      // and the backup logs speak in archive versions. Same advice either
      // way: update the app.
      throw BackupVersionTooNewException(e.fileVersion, e.supportedVersion);
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(decrypted);
    } catch (_) {
      throw const BackupCorruptedException(backupInvalidArchiveDetails);
    }

    final manifestFile = archive.findFile(backupManifestFileName);
    final databaseFile = archive.findFile(backupDatabaseFileName);
    if (manifestFile == null || databaseFile == null) {
      throw const BackupCorruptedException(backupInvalidArchiveDetails);
    }

    final BackupManifest manifest;
    final Map<String, dynamic> rawTables;
    try {
      manifest = BackupManifest.fromJson(
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>,
      );
      rawTables =
          jsonDecode(utf8.decode(databaseFile.content as List<int>))
              as Map<String, dynamic>;
    } catch (_) {
      throw const BackupCorruptedException(backupInvalidArchiveDetails);
    }

    if (manifest.formatVersion > backupFormatVersion) {
      throw BackupVersionTooNewException(
        manifest.formatVersion,
        backupFormatVersion,
      );
    }

    final schemaVersion = manifest.schemaVersion;
    if (schemaVersion != null && schemaVersion > _db.schemaVersion) {
      // An archive from a newer schema may hold columns and tables this build
      // has never heard of. Refusing is the honest answer; a partial restore
      // that silently drops them is not.
      throw BackupVersionTooNewException(
        schemaVersion,
        _db.schemaVersion,
        isSchemaVersion: true,
      );
    }

    final tables = <String, List<Map<String, dynamic>>>{};
    for (final entry in rawTables.entries) {
      final value = entry.value;
      if (value is! List) continue;
      tables[entry.key] = value.whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    }

    return _ReadArchive(manifest: manifest, tables: tables, archive: archive);
  }

  // ──────────────────────────── planning ────────────────────────────

  /// Works out, per table, which archive rows are new and which the app
  /// already has. Nothing is written here.
  Future<_RestorePlan> _buildPlan(
    _ReadArchive archive,
    RestoreMode mode,
  ) async {
    final plan = _RestorePlan(mode: mode);

    if (mode == RestoreMode.replace) {
      // Everything in the archive lands, and everything currently held goes.
      for (final entry in archive.tables.entries) {
        if (entry.value.isEmpty) continue;
        plan.outcomes[entry.key] = RestoreTableOutcome(
          added: entry.value.length,
        );
      }
      plan.rowsToClear = await _countUserRows();
    } else {
      await _planMerge(archive, plan);
    }

    plan.attachmentRowsToInsert = plan.outcomes['attachments']?.added ?? 0;
    plan.voiceNoteRowsToInsert = plan.outcomes['voiceNotes']?.added ?? 0;

    if (!archive.manifest.carriesPortableAttachments &&
        (archive.tables['attachments']?.isNotEmpty ?? false)) {
      plan.warnings.add(RestoreWarning.legacyAttachmentsNotPortable);
    }
    if ((archive.tables['attachments']?.isNotEmpty ?? false) &&
        archive.countFilesIn(backupAttachmentsFolder) == 0) {
      plan.warnings.add(RestoreWarning.attachmentFilesMissingFromArchive);
    }

    return plan;
  }

  // ────────────────────────── writing files ──────────────────────────

  /// Re-encrypts and stores every attachment and voice-note file that the
  /// insert step will need. Runs before the transaction, because file writes
  /// cannot be rolled back by the database.
  Future<_RestoredFiles> _restorePayloadFiles(
    _ReadArchive archive,
    _RestorePlan plan,
    List<String> writtenPaths,
  ) async {
    final fileCipher = cipher;
    final files = _RestoredFiles();
    if (fileCipher == null) return files;

    Future<void> restoreOne({
      required Map<String, dynamic> row,
      required String table,
      required String folder,
      required bool isAttachment,
    }) async {
      final oldId = BackupRestoreService._asInt(row['id']);
      if (oldId == null) return;
      if (!plan.willInsert(table, oldId)) return;

      final archiveFile =
          archive.archive.findFile('$folder/$oldId') ??
          // Format version 1 named files `<id>_<fileName>`.
          archive.findFileWithPrefix('$folder/${oldId}_');
      if (archiveFile == null) {
        isAttachment ? files.attachmentsFailed++ : files.voiceNotesFailed++;
        return;
      }

      final bytes = archiveFile.content as List<int>;
      final fileName = (row['fileName'] as String?) ?? 'file';

      try {
        if (archive.manifest.carriesPortableAttachments) {
          final stored = await fileCipher.encryptFromBytes(
            bytes: bytes,
            fileName: fileName,
          );
          writtenPaths.add(stored.encryptedPath);
          files.stored['$table:$oldId'] = stored;
        } else {
          // Version 1: the bytes are still encrypted with the original
          // device's key. Copy them unchanged and keep the row's own nonce
          // and key reference.
          final path = await fileCipher.storeRawEncryptedBytes(
            bytes: bytes,
            fileName: fileName,
          );
          writtenPaths.add(path);
          files.stored['$table:$oldId'] = BackupStoredFile(
            encryptedPath: path,
            nonceBase64: (row['nonceBase64'] as String?) ?? '',
            keyReference: (row['keyReference'] as String?) ?? '',
            sizeBytes:
                BackupRestoreService._asInt(row['sizeBytes']) ?? bytes.length,
          );
        }
        isAttachment ? files.attachmentsRestored++ : files.voiceNotesRestored++;
      } catch (_) {
        // Never log a file name or its contents.
        AppLogger.warning('Restore could not store one payload file');
        isAttachment ? files.attachmentsFailed++ : files.voiceNotesFailed++;
      }
    }

    for (final row in archive.tables['attachments'] ?? const []) {
      await restoreOne(
        row: row,
        table: 'attachments',
        folder: backupAttachmentsFolder,
        isAttachment: true,
      );
    }
    for (final row in archive.tables['voiceNotes'] ?? const []) {
      await restoreOne(
        row: row,
        table: 'voiceNotes',
        folder: backupVoiceNotesFolder,
        isAttachment: false,
      );
    }

    if (files.attachmentsFailed > 0) {
      files.warnings.add(RestoreWarning.someAttachmentFilesFailed);
    }
    if (files.voiceNotesFailed > 0) {
      files.warnings.add(RestoreWarning.someVoiceNoteFilesFailed);
    }
    return files;
  }
}
