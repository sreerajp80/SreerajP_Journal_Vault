import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/conflict_resolution_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';

// ─────────────── Core service providers ───────────────

final syncEncryptionServiceProvider = Provider<SyncEncryptionService>((ref) {
  return SyncEncryptionService();
});

final conflictResolutionServiceProvider =
    Provider<ConflictResolutionService>((ref) {
  final db = ref.read(appDatabaseProvider);
  final encryption = ref.read(syncEncryptionServiceProvider);
  return ConflictResolutionService(db: db, encryption: encryption);
});

// ─────────────── Sync state providers ───────────────

/// Notifier that holds the current sync status.
class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => SyncStatus.idle;
  void set(SyncStatus value) => state = value;
}

/// Current sync status for UI binding.
final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

/// Whether a sync operation is currently in progress.
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(syncStatusProvider) == SyncStatus.syncing;
});

// ─────────────── Data providers ───────────────

/// Pending conflicts that need user resolution.
final pendingConflictsProvider =
    StreamProvider<List<SyncConflict>>((ref) {
  final db = ref.read(appDatabaseProvider);
  return db.syncConflictsDao.watchPendingConflicts();
});

/// Number of unresolved conflicts (for badge display).
///
/// Uses a one-shot DAO query rather than [pendingConflictsProvider] so the
/// home-tab badge does not hold a long-lived drift stream subscription —
/// drift's stream cleanup schedules a Timer that breaks widget-test
/// invariants on dispose.
final pendingConflictCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.syncConflictsDao.getPendingConflictCount();
});

/// Recent sync logs for the health dashboard.
final recentSyncLogsProvider =
    FutureProvider<List<SyncLog>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.syncLogsDao.getRecentLogs();
});

/// Latest successful sync for "last synced" display.
final latestSuccessfulSyncProvider =
    FutureProvider<SyncLog?>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.syncLogsDao.getLatestSuccessful();
});

/// Sync failure count in the last 7 days.
final recentSyncFailureCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final since = DateTime.now().subtract(const Duration(days: 7));
  return db.syncLogsDao.getFailureCountSince(since);
});

/// Pending conflict details with field-level diffs.
final conflictDetailsProvider =
    FutureProvider<List<ConflictDetail>>((ref) async {
  final service = ref.read(conflictResolutionServiceProvider);
  return service.getPendingConflicts();
});
