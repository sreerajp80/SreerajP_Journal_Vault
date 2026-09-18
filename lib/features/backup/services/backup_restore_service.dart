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

part 'backup_restore_models.dart';

part 'backup_restore_steps.dart';
part 'backup_restore_rows.dart';
part 'backup_restore_rows_2.dart';

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
