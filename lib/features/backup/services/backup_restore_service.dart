import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/backup_format.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/restore_models.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';

/// Reads a backup archive back into the app.
///
/// Layer: service. Talks to the database, the archive and attachment storage;
/// knows nothing about widgets, navigation or user-facing text.
///
/// The order of operations is the safety guarantee, and it is deliberate:
///
/// 1. Password, then decrypt. A wrong password stops here.
/// 2. Format and schema version checks — a newer archive is refused, an older
///    one is accepted, because rows map onto columns by name.
/// 3. Plan the work against the current data. A dry run stops here and
///    reports what would happen.
/// 4. For a replace only: take an automatic pre-restore backup, so a bad
///    restore can be undone.
/// 5. Write the attachment files, remembering every path written.
/// 6. Apply every row change in **one transaction**. If anything fails, the
///    transaction rolls back and the files written in step 5 are deleted, so
///    the app is left exactly as it was.
/// 7. Rebuild the search index and run `PRAGMA integrity_check`.
class BackupRestoreService {
  BackupRestoreService(
    this._db, {
    this.cipher,
    VaultEnvelope? envelope,
    this.backupService,
  }) : _envelope = envelope ?? VaultEnvelope();

  final AppDatabase _db;

  /// Re-encrypts restored files for this device. Null skips file restore.
  final BackupAttachmentCipher? cipher;

  final VaultEnvelope _envelope;

  /// Used to take the pre-restore safety backup. Null disables that step.
  final BackupService? backupService;

  /// Reads what an archive contains without touching the app's data.
  Future<BackupPreview> inspect({
    required String backupPath,
    required String password,
  }) async {
    final archive = await _readArchive(
      backupPath: backupPath,
      password: password,
    );
    return BackupPreview(
      manifest: archive.manifest,
      tableCounts: {
        for (final entry in archive.tables.entries)
          entry.key: entry.value.length,
      },
      attachmentFileCount: archive.countFilesIn(backupAttachmentsFolder),
      voiceNoteFileCount: archive.countFilesIn(backupVoiceNotesFolder),
      sizeBytes: await File(backupPath).length(),
    );
  }

  /// Restores [backupPath] into the app.
  ///
  /// With [dryRun] true nothing is written: the returned [RestoreResult] says
  /// what a real run would add and skip.
  Future<RestoreResult> restore({
    required String backupPath,
    required String password,
    required RestoreMode mode,
    bool dryRun = false,
  }) async {
    final archive = await _readArchive(
      backupPath: backupPath,
      password: password,
    );

    final plan = await _buildPlan(archive, mode);

    if (dryRun) {
      return RestoreResult(
        mode: mode,
        wasDryRun: true,
        tables: plan.outcomes,
        rowsCleared: plan.rowsToClear,
        attachmentFilesRestored: plan.attachmentRowsToInsert,
        voiceNoteFilesRestored: plan.voiceNoteRowsToInsert,
        warnings: plan.warnings,
      );
    }

    final logId = await _db.backupLogsDao.createLog(
      BackupLogsCompanion.insert(
        status: 'in_progress',
        trigger: const Value('restore'),
      ),
    );

    // Files written during this restore. Deleted again if the transaction
    // rolls back, so a failed restore leaves nothing behind.
    final writtenPaths = <String>[];

    try {
      String? safetyBackupPath;
      if (mode == RestoreMode.replace && backupService != null) {
        final safety = await backupService!.createBackup(
          password: password,
          triggerType: 'pre_restore',
        );
        safetyBackupPath = safety.path;
      }

      // Paths currently in use. A replace drops these rows, so their files
      // become orphans — deleted after the transaction commits.
      final orphanPaths = mode == RestoreMode.replace
          ? await _currentPayloadPaths()
          : <String>[];

      final files = await _restorePayloadFiles(archive, plan, writtenPaths);

      await _db.transaction(() async {
        if (mode == RestoreMode.replace) {
          await _clearUserData();
        }
        await _insertRows(archive, plan, files);
      });

      await _rebuildSearchIndex();
      await _assertIntegrity();

      if (mode == RestoreMode.replace) {
        await _deleteFiles(orphanPaths);
      }

      final result = RestoreResult(
        mode: mode,
        wasDryRun: false,
        tables: plan.outcomes,
        rowsCleared: plan.rowsToClear,
        attachmentFilesRestored: files.attachmentsRestored,
        attachmentFilesFailed: files.attachmentsFailed,
        voiceNoteFilesRestored: files.voiceNotesRestored,
        voiceNoteFilesFailed: files.voiceNotesFailed,
        safetyBackupPath: safetyBackupPath,
        warnings: [...plan.warnings, ...files.warnings],
      );

      await _db.backupLogsDao.updateLog(
        logId,
        BackupLogsCompanion(
          status: const Value('success'),
          backupPath: Value(backupPath),
          entryCount: Value(result.entriesAdded),
          attachmentCount: Value(files.attachmentsRestored),
          completedAt: Value(DateTime.now()),
        ),
      );

      return result;
    } catch (e) {
      await _deleteFiles(writtenPaths);
      await _db.backupLogsDao.updateLog(
        logId,
        BackupLogsCompanion(
          status: const Value('failed'),
          backupPath: Value(backupPath),
          errorMessage: Value(e.toString()),
          completedAt: Value(DateTime.now()),
        ),
      );
      rethrow;
    }
  }

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

  /// Decides, row by row, what a merge would add.
  ///
  /// Matching is by content, never by id: the archive's ids are dropped on
  /// import, so an id can never point at the wrong row. Rows the app already
  /// holds are recorded in [_RestorePlan.existingIds], which also gives the
  /// insert step its old-to-new id map for free.
  Future<void> _planMerge(_ReadArchive archive, _RestorePlan plan) async {
    Future<void> planTable({
      required String table,
      required Future<Map<String, int>> Function() existingKeys,
      required String? Function(Map<String, dynamic> row) keyOf,
    }) async {
      final rows = archive.tables[table] ?? const [];
      if (rows.isEmpty) return;

      final existing = await existingKeys();
      var added = 0;
      var skipped = 0;

      for (final row in rows) {
        final oldId = _asInt(row['id']);
        final key = keyOf(row);
        final match = key == null ? null : existing[key];
        if (match != null) {
          skipped++;
          if (oldId != null) plan.mapExisting(table, oldId, match);
        } else {
          added++;
          if (oldId != null) plan.markForInsert(table, oldId);
        }
      }

      plan.outcomes[table] = RestoreTableOutcome(
        added: added,
        skipped: skipped,
      );
    }

    await planTable(
      table: 'journals',
      existingKeys: () async {
        final rows = await _db.select(_db.journals).get();
        return {
          for (final j in rows)
            '${j.title}|${j.createdAt.toIso8601String()}': j.id,
        };
      },
      keyOf: (row) => '${row['title']}|${row['createdAt']}',
    );

    await planTable(
      table: 'tags',
      existingKeys: () async {
        final rows = await _db.select(_db.tags).get();
        return {for (final t in rows) t.name.toLowerCase(): t.id};
      },
      keyOf: (row) => (row['name'] as String?)?.toLowerCase(),
    );

    await planTable(
      table: 'entries',
      existingKeys: () async {
        final rows = await _db.select(_db.entries).get();
        return {
          for (final e in rows)
            '${e.journalId}|${e.title}|${e.createdAt.toIso8601String()}': e.id,
        };
      },
      keyOf: (row) {
        final journalId = plan.mappedId('journals', _asInt(row['journalId']));
        if (journalId == null) return null; // new journal ⇒ new entry
        return '$journalId|${row['title']}|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'attachments',
      existingKeys: () async {
        final rows = await _db.select(_db.attachments).get();
        return {
          for (final a in rows)
            '${a.entryId}|${a.fileName}|${a.createdAt.toIso8601String()}': a.id,
        };
      },
      keyOf: (row) {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        return '$entryId|${row['fileName']}|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'voiceNotes',
      existingKeys: () async {
        final rows = await _db.select(_db.voiceNotes).get();
        return {
          for (final v in rows)
            '${v.entryId}|${v.fileName}|${v.createdAt.toIso8601String()}': v.id,
        };
      },
      keyOf: (row) {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        return '$entryId|${row['fileName']}|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'revisions',
      existingKeys: () async {
        final rows = await _db.select(_db.entryRevisions).get();
        return {
          for (final r in rows)
            '${r.entryId}|${r.createdAt.toIso8601String()}': r.id,
        };
      },
      keyOf: (row) {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        return '$entryId|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'entryMoods',
      existingKeys: () async {
        final rows = await _db.select(_db.entryMoods).get();
        return {for (final m in rows) '${m.entryId}': m.id};
      },
      keyOf: (row) {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        return entryId?.toString();
      },
    );

    await planTable(
      table: 'searchPresets',
      existingKeys: () async {
        final rows = await _db.select(_db.searchPresets).get();
        return {for (final s in rows) '${s.name}|${s.query}': s.id};
      },
      keyOf: (row) => '${row['name']}|${row['query']}',
    );

    await planTable(
      table: 'timeCapsules',
      existingKeys: () async {
        final rows = await _db.select(_db.timeCapsules).get();
        return {for (final tc in rows) '${tc.entryId}': tc.id};
      },
      keyOf: (row) {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        return entryId?.toString();
      },
    );

    await planTable(
      table: 'journalTags',
      existingKeys: () async {
        final rows = await _db.select(_db.journalTags).get();
        return {for (final jt in rows) '${jt.journalId}|${jt.tagId}': jt.id};
      },
      keyOf: (row) {
        final journalId = plan.mappedId('journals', _asInt(row['journalId']));
        final tagId = plan.mappedId('tags', _asInt(row['tagId']));
        if (journalId == null || tagId == null) return null;
        return '$journalId|$tagId';
      },
    );

    await planTable(
      table: 'entryTags',
      existingKeys: () async {
        final rows = await _db.select(_db.entryTags).get();
        return {for (final et in rows) '${et.entryId}|${et.tagId}': et.id};
      },
      keyOf: (row) {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        final tagId = plan.mappedId('tags', _asInt(row['tagId']));
        if (entryId == null || tagId == null) return null;
        return '$entryId|$tagId';
      },
    );

    await planTable(
      table: 'backlinks',
      existingKeys: () async {
        final rows = await _db.select(_db.backlinks).get();
        return {
          for (final b in rows)
            '${b.sourceEntryId}|${b.targetType}|${b.targetId}': b.id,
        };
      },
      keyOf: (row) {
        final sourceId = plan.mappedId('entries', _asInt(row['sourceEntryId']));
        final targetId = _mappedBacklinkTarget(plan, row);
        if (sourceId == null || targetId == null) return null;
        return '$sourceId|${row['targetType']}|$targetId';
      },
    );

    await planTable(
      table: 'syncMetadata',
      existingKeys: () async {
        final rows = await _db.select(_db.syncMetadata).get();
        return {for (final s in rows) '${s.recordTable}|${s.syncId}': s.id};
      },
      keyOf: (row) => '${row['recordTable']}|${row['syncId']}',
    );
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
      final oldId = _asInt(row['id']);
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
            sizeBytes: _asInt(row['sizeBytes']) ?? bytes.length,
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

  // ───────────────────────── writing rows ─────────────────────────

  /// Inserts every planned row inside the caller's transaction, dropping the
  /// archive's primary keys and rewriting foreign keys as it goes.
  Future<void> _insertRows(
    _ReadArchive archive,
    _RestorePlan plan,
    _RestoredFiles files,
  ) async {
    Future<void> insertTable({
      required String table,
      required Future<int?> Function(Map<String, dynamic> row) insert,
    }) async {
      for (final row in archive.tables[table] ?? const []) {
        final oldId = _asInt(row['id']);
        if (oldId != null && !plan.willInsert(table, oldId)) continue;
        final newId = await insert(row);
        if (oldId != null && newId != null) {
          plan.mapExisting(table, oldId, newId);
        }
      }
    }

    await insertTable(
      table: 'journals',
      insert: (row) => _db
          .into(_db.journals)
          .insert(
            JournalsCompanion.insert(
              title: (row['title'] as String?) ?? '',
              description: Value(row['description'] as String?),
              isLocked: Value((row['isLocked'] as bool?) ?? false),
              credentialReference: Value(row['credentialReference'] as String?),
              passwordSaltBase64: Value(row['passwordSaltBase64'] as String?),
              passwordVerifierBase64: Value(
                row['passwordVerifierBase64'] as String?,
              ),
              passwordIterations: Value(_asInt(row['passwordIterations'])),
              createdAt: _dateValue(row['createdAt']),
              updatedAt: _dateValue(row['updatedAt']),
            ),
          ),
    );

    await insertTable(
      table: 'tags',
      insert: (row) => _db
          .into(_db.tags)
          .insert(
            TagsCompanion.insert(
              name: (row['name'] as String?) ?? '',
              colorArgb: Value(_asInt(row['colorArgb'])),
              createdAt: _dateValue(row['createdAt']),
              updatedAt: _dateValue(row['updatedAt']),
            ),
          ),
    );

    await insertTable(
      table: 'entries',
      insert: (row) async {
        final journalId = plan.mappedId('journals', _asInt(row['journalId']));
        if (journalId == null) return null;
        return _db
            .into(_db.entries)
            .insert(
              EntriesCompanion.insert(
                journalId: journalId,
                title: Value(row['title'] as String?),
                contentJson: Value(row['contentJson'] as String?),
                plainText: Value(row['plainText'] as String?),
                entryDate: _nullableDateValue(row['entryDate']),
                createdAt: _dateValue(row['createdAt']),
                updatedAt: _dateValue(row['updatedAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'journalTags',
      insert: (row) async {
        final journalId = plan.mappedId('journals', _asInt(row['journalId']));
        final tagId = plan.mappedId('tags', _asInt(row['tagId']));
        if (journalId == null || tagId == null) return null;
        return _db
            .into(_db.journalTags)
            .insert(
              JournalTagsCompanion.insert(journalId: journalId, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );

    await insertTable(
      table: 'entryTags',
      insert: (row) async {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        final tagId = plan.mappedId('tags', _asInt(row['tagId']));
        if (entryId == null || tagId == null) return null;
        return _db
            .into(_db.entryTags)
            .insert(
              EntryTagsCompanion.insert(entryId: entryId, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );

    await insertTable(
      table: 'attachments',
      insert: (row) async {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        final oldId = _asInt(row['id']);
        final stored = files.stored['attachments:$oldId'];
        return _db
            .into(_db.attachments)
            .insert(
              AttachmentsCompanion.insert(
                entryId: entryId,
                fileName: (row['fileName'] as String?) ?? 'file',
                mimeType: Value(row['mimeType'] as String?),
                // Without the file, the row still restores: the entry keeps its
                // record of the attachment even though the bytes are gone.
                encryptedPath:
                    stored?.encryptedPath ??
                    (row['encryptedPath'] as String? ?? ''),
                nonceBase64:
                    stored?.nonceBase64 ??
                    (row['nonceBase64'] as String? ?? ''),
                keyReference:
                    stored?.keyReference ??
                    (row['keyReference'] as String? ?? ''),
                sizeBytes: stored?.sizeBytes ?? (_asInt(row['sizeBytes']) ?? 0),
                createdAt: _dateValue(row['createdAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'voiceNotes',
      insert: (row) async {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        final oldId = _asInt(row['id']);
        final stored = files.stored['voiceNotes:$oldId'];
        return _db
            .into(_db.voiceNotes)
            .insert(
              VoiceNotesCompanion.insert(
                entryId: entryId,
                fileName: (row['fileName'] as String?) ?? 'voice_note',
                encryptedPath:
                    stored?.encryptedPath ??
                    (row['encryptedPath'] as String? ?? ''),
                nonceBase64:
                    stored?.nonceBase64 ??
                    (row['nonceBase64'] as String? ?? ''),
                keyReference:
                    stored?.keyReference ??
                    (row['keyReference'] as String? ?? ''),
                durationMs: _asInt(row['durationMs']) ?? 0,
                transcript: Value(row['transcript'] as String?),
                createdAt: _dateValue(row['createdAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'revisions',
      insert: (row) async {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        return _db
            .into(_db.entryRevisions)
            .insert(
              EntryRevisionsCompanion.insert(
                entryId: entryId,
                title: Value(row['title'] as String?),
                contentJson: Value(row['contentJson'] as String?),
                plainText: Value(row['plainText'] as String?),
                createdAt: _dateValue(row['createdAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'backlinks',
      insert: (row) async {
        final sourceId = plan.mappedId('entries', _asInt(row['sourceEntryId']));
        final targetId = _mappedBacklinkTarget(plan, row);
        if (sourceId == null || targetId == null) return null;
        return _db
            .into(_db.backlinks)
            .insert(
              BacklinksCompanion.insert(
                sourceEntryId: sourceId,
                targetType: (row['targetType'] as String?) ?? 'entry',
                targetId: targetId,
              ),
            );
      },
    );

    await insertTable(
      table: 'entryMoods',
      insert: (row) async {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        return _db
            .into(_db.entryMoods)
            .insert(
              EntryMoodsCompanion.insert(
                entryId: entryId,
                mood: _asInt(row['mood']) ?? 3,
                note: Value(row['note'] as String?),
                createdAt: _dateValue(row['createdAt']),
                updatedAt: _dateValue(row['updatedAt']),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );

    await insertTable(
      table: 'searchPresets',
      insert: (row) => _db
          .into(_db.searchPresets)
          .insert(
            SearchPresetsCompanion.insert(
              name: (row['name'] as String?) ?? '',
              query: (row['query'] as String?) ?? '',
              resultType: Value(row['resultType'] as String?),
              createdAt: _dateValue(row['createdAt']),
              updatedAt: _dateValue(row['updatedAt']),
            ),
          ),
    );

    await insertTable(
      table: 'syncMetadata',
      insert: (row) async {
        final recordTable = (row['recordTable'] as String?) ?? '';
        final localId = plan.mappedId(recordTable, _asInt(row['localId']));
        if (localId == null) return null;
        return _db
            .into(_db.syncMetadata)
            .insert(
              SyncMetadataCompanion.insert(
                recordTable: recordTable,
                localId: localId,
                syncId: (row['syncId'] as String?) ?? '',
                version: Value(_asInt(row['version']) ?? 1),
                deviceId: (row['deviceId'] as String?) ?? '',
                isDeleted: Value((row['isDeleted'] as bool?) ?? false),
                lastSyncedAt: _nullableDateValue(row['lastSyncedAt']),
                lastModifiedAt: _dateValue(row['lastModifiedAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'timeCapsules',
      insert: (row) async {
        final entryId = plan.mappedId('entries', _asInt(row['entryId']));
        if (entryId == null) return null;
        return _db
            .into(_db.timeCapsules)
            .insert(
              TimeCapsulesCompanion.insert(
                entryId: entryId,
                unlockDate: _dateValue(row['unlockDate']).value,
                sealedAt: _dateValue(row['sealedAt']),
                isOpened: Value((row['isOpened'] as bool?) ?? false),
                openedAt: _nullableDateValue(row['openedAt']),
                sealedCiphertext: (row['sealedCiphertext'] as String?) ?? '',
                ivBase64: (row['ivBase64'] as String?) ?? '',
                macBase64: (row['macBase64'] as String?) ?? '',
                sealedKeyCiphertext: Value(
                  row['sealedKeyCiphertext'] as String?,
                ),
                teaserMessage: Value(row['teaserMessage'] as String?),
                createdAt: _dateValue(row['createdAt']),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );
  }

  // ───────────────────────── database helpers ─────────────────────────

  /// Deletes user data in an order that respects foreign keys.
  Future<void> _clearUserData() async {
    await _db.delete(_db.syncMetadata).go();
    await _db.delete(_db.timeCapsules).go();
    await _db.delete(_db.entryMoods).go();
    await _db.delete(_db.backlinks).go();
    await _db.delete(_db.entryRevisions).go();
    await _db.delete(_db.voiceNotes).go();
    await _db.delete(_db.attachmentTexts).go();
    await _db.delete(_db.attachments).go();
    await _db.delete(_db.entryTags).go();
    await _db.delete(_db.journalTags).go();
    await _db.delete(_db.entries).go();
    await _db.delete(_db.tags).go();
    await _db.delete(_db.journals).go();
    await _db.delete(_db.searchPresets).go();
  }

  Future<int> _countUserRows() async {
    var total = 0;
    total += (await _db.select(_db.journals).get()).length;
    total += (await _db.select(_db.entries).get()).length;
    total += (await _db.select(_db.tags).get()).length;
    total += (await _db.select(_db.journalTags).get()).length;
    total += (await _db.select(_db.entryTags).get()).length;
    total += (await _db.select(_db.attachments).get()).length;
    total += (await _db.select(_db.voiceNotes).get()).length;
    total += (await _db.select(_db.entryRevisions).get()).length;
    total += (await _db.select(_db.backlinks).get()).length;
    total += (await _db.select(_db.entryMoods).get()).length;
    total += (await _db.select(_db.searchPresets).get()).length;
    total += (await _db.select(_db.syncMetadata).get()).length;
    return total;
  }

  Future<List<String>> _currentPayloadPaths() async {
    final paths = <String>[];
    for (final a in await _db.select(_db.attachments).get()) {
      paths.add(a.encryptedPath);
    }
    for (final v in await _db.select(_db.voiceNotes).get()) {
      paths.add(v.encryptedPath);
    }
    return paths;
  }

  Future<void> _deleteFiles(List<String> paths) async {
    final fileCipher = cipher;
    if (fileCipher == null) return;
    for (final path in paths) {
      if (path.isEmpty) continue;
      try {
        await fileCipher.deleteStoredFile(path);
      } catch (_) {
        // A file we cannot delete is wasted space, not a failed restore.
      }
    }
  }

  /// Rebuilds the FTS index from the tables it mirrors.
  ///
  /// The triggers keep it in step row by row, but a restore inserts in bulk
  /// and a replace deletes in bulk, so rebuilding is both cheaper and safer
  /// than trusting every trigger fired.
  Future<void> _rebuildSearchIndex() async {
    try {
      await _db.customStatement(
        "INSERT INTO entries_fts(entries_fts) VALUES('rebuild')",
      );
      await _db.customStatement(
        "INSERT INTO attachment_text_fts(attachment_text_fts) VALUES('rebuild')",
      );
    } catch (e) {
      // Search being stale is not worth failing a restore over.
      AppLogger.warning('Search index rebuild after restore failed', error: e);
    }
  }

  Future<void> _assertIntegrity() async {
    final rows = await _db.customSelect('PRAGMA integrity_check').get();
    final status = rows.isEmpty ? null : rows.first.data.values.first;
    if (status != 'ok') {
      throw const BackupCorruptedException(backupIntegrityCheckFailedDetails);
    }
  }

  static int? _mappedBacklinkTarget(
    _RestorePlan plan,
    Map<String, dynamic> row,
  ) {
    final targetType = row['targetType'] as String?;
    final targetId = _asInt(row['targetId']);
    return switch (targetType) {
      'journal' => plan.mappedId('journals', targetId),
      'entry' => plan.mappedId('entries', targetId),
      _ => null,
    };
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static Value<DateTime> _dateValue(Object? value) {
    final parsed = value is String ? DateTime.tryParse(value) : null;
    return parsed == null ? const Value.absent() : Value(parsed);
  }

  static Value<DateTime?> _nullableDateValue(Object? value) {
    final parsed = value is String ? DateTime.tryParse(value) : null;
    return parsed == null ? const Value.absent() : Value(parsed);
  }
}

/// A decrypted archive, parsed and version-checked.
class _ReadArchive {
  _ReadArchive({
    required this.manifest,
    required this.tables,
    required this.archive,
  });

  final BackupManifest manifest;
  final Map<String, List<Map<String, dynamic>>> tables;
  final Archive archive;

  int countFilesIn(String folder) =>
      archive.files.where((f) => f.name.startsWith('$folder/')).length;

  ArchiveFile? findFileWithPrefix(String prefix) {
    for (final file in archive.files) {
      if (file.name.startsWith(prefix)) return file;
    }
    return null;
  }
}

/// What a restore intends to do, decided before anything is written.
class _RestorePlan {
  _RestorePlan({required this.mode});

  final RestoreMode mode;
  final Map<String, RestoreTableOutcome> outcomes = {};
  final List<RestoreWarning> warnings = [];

  /// Old archive id → the id it maps to in this database. Filled in during
  /// planning for rows that already exist, and during insertion for new ones.
  final Map<String, Map<int, int>> _idMap = {};

  /// Old archive ids that are new here and must be inserted. A replace has no
  /// entry for a table, which means "insert everything".
  final Map<String, Set<int>> _toInsert = {};

  int rowsToClear = 0;
  int attachmentRowsToInsert = 0;
  int voiceNoteRowsToInsert = 0;

  void mapExisting(String table, int oldId, int newId) {
    (_idMap[table] ??= {})[oldId] = newId;
  }

  void markForInsert(String table, int oldId) {
    (_toInsert[table] ??= {}).add(oldId);
  }

  int? mappedId(String table, int? oldId) {
    if (oldId == null) return null;
    return _idMap[table]?[oldId];
  }

  bool willInsert(String table, int oldId) {
    if (mode == RestoreMode.replace) return true;
    return _toInsert[table]?.contains(oldId) ?? false;
  }
}

/// Files written to storage during a restore, keyed `<table>:<old id>`.
class _RestoredFiles {
  final Map<String, BackupStoredFile> stored = {};
  final List<RestoreWarning> warnings = [];

  int attachmentsRestored = 0;
  int attachmentsFailed = 0;
  int voiceNotesRestored = 0;
  int voiceNotesFailed = 0;
}
