import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_file_picker.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_restore_service.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_scheduler.dart';

/// Decrypts attachments on the way into a backup and re-encrypts them on the
/// way back out. Overridden in `main.dart` with the real storage; null here so
/// tests and screens that never touch files still work.
final backupAttachmentCipherProvider = Provider<BackupAttachmentCipher?>(
  (ref) => null,
);

final backupFilePickerProvider = Provider<BackupFilePicker>((ref) {
  return FilePickerBackupFilePicker();
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return BackupService(db, cipher: ref.watch(backupAttachmentCipherProvider));
});

final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return BackupRestoreService(
    db,
    cipher: ref.watch(backupAttachmentCipherProvider),
    // Lets a replace take a safety backup of the current data first.
    backupService: ref.watch(backupServiceProvider),
  );
});

final backupSchedulerProvider = Provider<BackupScheduler>((ref) {
  final backupService = ref.read(backupServiceProvider);
  final scheduler = BackupScheduler(backupService);
  ref.onDispose(() => scheduler.dispose());
  return scheduler;
});

final backupScheduleSettingsProvider = FutureProvider<BackupScheduleSettings>((
  ref,
) {
  final scheduler = ref.read(backupSchedulerProvider);
  return scheduler.getSettings();
});

final recentBackupLogsProvider = FutureProvider<List<BackupLog>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.backupLogsDao.getRecentLogs();
});

final latestSuccessfulBackupProvider = FutureProvider<BackupLog?>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.backupLogsDao.getLatestSuccessful();
});

final recentFailureCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final since = DateTime.now().subtract(const Duration(days: 7));
  return db.backupLogsDao.getFailureCountSince(since);
});

/// Backup files this app has written, newest first.
final availableBackupFilesProvider = FutureProvider<List<BackupFileInfo>>((
  ref,
) async {
  return ref.read(backupServiceProvider).listBackups();
});
