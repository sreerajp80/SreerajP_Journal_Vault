import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_id_generator.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_protocol.dart';

part 'sync_engine_records.dart';

/// Sync status reported to UI listeners.
enum SyncStatus { idle, syncing, success, failed, conflict }

/// Orchestrates the full sync lifecycle: track → push → pull → resolve.
///
/// The engine:
/// 1. Ensures every local record has a deterministic sync ID.
/// 2. Collects records modified since the last sync.
/// 3. Encrypts and pushes them via the [SyncProtocol].
/// 4. Pulls remote changes, decrypts, and merges or flags conflicts.
/// 5. Logs every sync attempt for the health dashboard.
class SyncEngine {
  final AppDatabase db;
  final SyncProtocol protocol;
  final SyncEncryptionService encryption;
  final String deviceId;
  final BackupAttachmentCipher? attachmentCipher;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  /// Number of consecutive failures for exponential back-off.
  int _consecutiveFailures = 0;

  /// Tables that participate in sync, in dependency order.
  static const syncableTables = [
    'journals',
    'entries',
    'tags',
    'journal_tags',
    'entry_tags',
    'attachments',
    'backlinks',
    'entry_revisions',
    'voice_notes',
  ];

  SyncEngine({
    required this.db,
    required this.protocol,
    required this.encryption,
    required this.deviceId,
    this.attachmentCipher,
  });

  /// Runs a full bidirectional sync cycle with retry support.
  ///
  /// Returns the final [SyncStatus]. On transient failures, the engine
  /// retries up to [maxRetries] times with exponential back-off.
  Future<SyncStatus> performSync({
    required String syncPassword,
    int maxRetries = 3,
  }) async {
    _status = SyncStatus.syncing;
    final salt = List.generate(16, (i) => i); // Matches backup salt scheme
    final key = await _encryption.deriveKey(syncPassword, salt);

    final logId = await _db.syncLogsDao.createLog(
      SyncLogsCompanion.insert(status: 'in_progress'),
    );

    int totalPushed = 0;
    int totalPulled = 0;
    int totalConflicts = 0;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (!await _protocol.isAvailable()) {
          throw const SyncException('Remote endpoint is not reachable');
        }

        // ── Phase 1: Ensure all local records have sync metadata ──
        await _ensureSyncMetadata();

        // ── Phase 2: Push local changes ──
        final pushResult = await _pushLocalChanges(key);
        totalPushed += pushResult.accepted;
        totalConflicts += pushResult.conflicts;

        // ── Phase 3: Pull remote changes ──
        final pullResult = await _pullRemoteChanges(key);
        totalPulled += pullResult.records.length;

        // ── Phase 4: Update sync timestamps ──
        final now = DateTime.now();
        final unsynced = await _db.syncMetadataDao.getUnsyncedRecords();
        for (final record in unsynced) {
          await _db.syncMetadataDao.markSynced(record.syncId, now);
        }

        _consecutiveFailures = 0;
        _status = totalConflicts > 0 ? SyncStatus.conflict : SyncStatus.success;

        await _db.syncLogsDao.updateLog(
          logId,
          SyncLogsCompanion(
            status: Value(
              _status == SyncStatus.conflict ? 'partial' : 'success',
            ),
            recordsPushed: Value(totalPushed),
            recordsPulled: Value(totalPulled),
            conflictsDetected: Value(totalConflicts),
            completedAt: Value(DateTime.now()),
          ),
        );

        return _status;
      } catch (e) {
        _consecutiveFailures++;
        if (attempt < maxRetries) {
          // Exponential back-off: 1s, 2s, 4s
          await Future.delayed(Duration(seconds: 1 << attempt));
          continue;
        }

        _status = SyncStatus.failed;
        await _db.syncLogsDao.updateLog(
          logId,
          SyncLogsCompanion(
            status: const Value('failed'),
            recordsPushed: Value(totalPushed),
            recordsPulled: Value(totalPulled),
            conflictsDetected: Value(totalConflicts),
            errorMessage: Value(e.toString()),
            completedAt: Value(DateTime.now()),
          ),
        );

        return SyncStatus.failed;
      }
    }

    return _status;
  }

  /// The recommended delay before the next retry, based on failure count.
  Duration get retryDelay =>
      Duration(seconds: 1 << _consecutiveFailures.clamp(0, 6));

  // ─────────────── Internal sync phases ───────────────

  /// Ensures every syncable record in the local DB has a [SyncMetadata] row.
  Future<void> _ensureSyncMetadata() async {
    for (final table in syncableTables) {
      final localIds = await _getLocalIdsForTable(table);
      for (final localId in localIds) {
        final existing = await _db.syncMetadataDao.getByRecord(table, localId);
        if (existing == null) {
          final syncId = SyncIdGenerator.generate(
            deviceId: _deviceId,
            table: table,
            localId: localId,
          );
          await _db.syncMetadataDao.upsert(
            SyncMetadataCompanion.insert(
              recordTable: table,
              localId: localId,
              syncId: syncId,
              deviceId: _deviceId,
            ),
          );
        }
      }
    }
  }

  // ─────────────── Table-specific helpers ───────────────

  /// Returns all local IDs for a given syncable table.
  Future<List<int>> _getLocalIdsForTable(String table) async {
    final result = await _db
        .customSelect('SELECT id FROM $table', variables: [])
        .get();
    return result.map((row) => row.read<int>('id')).toList();
  }
}

/// Thrown when a sync operation fails in a recoverable way.
class SyncException implements Exception {
  final String message;
  final Object? cause;

  const SyncException(this.message, [this.cause]);

  @override
  String toString() =>
      'SyncException: $message${cause != null ? ' ($cause)' : ''}';
}
