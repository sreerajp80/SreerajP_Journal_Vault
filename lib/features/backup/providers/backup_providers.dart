import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_scheduler.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return BackupService(db);
});

final backupSchedulerProvider = Provider<BackupScheduler>((ref) {
  final backupService = ref.read(backupServiceProvider);
  final scheduler = BackupScheduler(backupService);
  ref.onDispose(() => scheduler.dispose());
  return scheduler;
});

final backupScheduleSettingsProvider =
    FutureProvider<BackupScheduleSettings>((ref) {
  final scheduler = ref.read(backupSchedulerProvider);
  return scheduler.getSettings();
});

final recentBackupLogsProvider =
    FutureProvider<List<BackupLog>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.backupLogsDao.getRecentLogs();
});

final latestSuccessfulBackupProvider =
    FutureProvider<BackupLog?>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.backupLogsDao.getLatestSuccessful();
});

final recentFailureCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final since = DateTime.now().subtract(const Duration(days: 7));
  return db.backupLogsDao.getFailureCountSince(since);
});
