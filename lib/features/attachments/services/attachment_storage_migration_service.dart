import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';

/// Migrates attachment files between storage locations (app-private ↔ SD card).
class AttachmentStorageMigrationService {
  AttachmentStorageMigrationService({
    required this._database,
    required this._storage,
  });

  final AppDatabase _database;
  final AttachmentCryptoStorage _storage;

  /// Migrates all attachments to [targetLocation] and updates settings on success.
  ///
  /// Calls [onProgress] with (processed, total) before and after each file.
  /// On failure, persists migration status as 'failed' and rethrows.
  ///
  /// Pass [isCancelled] to allow soft cancellation: the loop checks the flag
  /// between files and aborts cleanly. A cancelled run leaves migration
  /// status as 'failed' with a "Migration cancelled by user" failure message,
  /// so the UI can offer a retry.
  Future<void> migrateTo({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
    String? targetTreeLabel,
    void Function(int processed, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final targetValue = targetLocation.toSettingsValue();
    await _database.appSettingsDao.updateSettings(
      AppSettingsCompanion(
        attachmentMigrationStatus: const Value('running'),
        attachmentMigrationTarget: Value(targetValue),
        attachmentMigrationFailure: const Value(null),
      ),
    );

    try {
      final all = await _database.attachmentsDao.getAllAttachments();
      final pending = all
          .where(
            (a) => !_storage.isStoredInLocation(
              encryptedPath: a.encryptedPath,
              location: targetLocation,
            ),
          )
          .toList();
      final total = pending.length;

      for (var i = 0; i < total; i++) {
        if (isCancelled?.call() ?? false) {
          throw const _MigrationCancelledException();
        }
        onProgress?.call(i, total);
        final attachment = pending[i];
        final newPath = await _storage.migrateStoredFile(
          encryptedPath: attachment.encryptedPath,
          fileName: attachment.fileName,
          targetLocation: targetLocation,
          targetTreeUri: targetTreeUri,
        );
        await _database.attachmentsDao.updateAttachment(
          AttachmentsCompanion(
            id: Value(attachment.id),
            encryptedPath: Value(newPath),
          ),
        );
        await _storage.deleteStoredFile(attachment.encryptedPath);
        onProgress?.call(i + 1, total);
      }

      await _database.appSettingsDao.updateSettings(
        AppSettingsCompanion(
          attachmentStorageLocation: Value(targetValue),
          attachmentStorageTreeUri: Value(targetTreeUri),
          attachmentStorageTreeLabel: Value(targetTreeLabel),
          attachmentMigrationStatus: const Value('idle'),
          attachmentMigrationTarget: const Value(null),
          attachmentMigrationFailure: const Value(null),
        ),
      );
    } on _MigrationCancelledException {
      await _database.appSettingsDao.updateSettings(
        const AppSettingsCompanion(
          attachmentMigrationStatus: Value('failed'),
          attachmentMigrationFailure: Value('Migration cancelled by user.'),
        ),
      );
      rethrow;
    } catch (e) {
      await _database.appSettingsDao.updateSettings(
        AppSettingsCompanion(
          attachmentMigrationStatus: const Value('failed'),
          attachmentMigrationTarget: Value(targetValue),
          attachmentMigrationFailure: Value(e.toString()),
        ),
      );
      rethrow;
    }
  }

  /// Converts an interrupted ('running') migration into a retryable 'failed' state.
  ///
  /// Call this on app startup to recover from crashes mid-migration.
  Future<AppSetting> recoverInterruptedMigrationIfNeeded() async {
    var settings = await _database.appSettingsDao.getSettings();
    if (settings.attachmentMigrationStatus == 'running') {
      await _database.appSettingsDao.updateSettings(
        const AppSettingsCompanion(
          attachmentMigrationStatus: Value('failed'),
          attachmentMigrationFailure: Value(
            'Attachment migration was interrupted. Retry to continue.',
          ),
        ),
      );
      settings = await _database.appSettingsDao.getSettings();
    }
    return settings;
  }
}

/// Thrown when a caller-supplied `isCancelled` callback returns true while
/// `migrateTo` is running. Surfaced so the UI can branch on cancellation vs.
/// other failures.
class _MigrationCancelledException implements Exception {
  const _MigrationCancelledException();

  @override
  String toString() => 'Migration cancelled by user.';
}
