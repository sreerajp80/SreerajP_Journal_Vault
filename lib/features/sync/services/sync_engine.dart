import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_id_generator.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_protocol.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_record_applier.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_references.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_schema_guard.dart';

part 'sync_engine_records.dart';

/// Sync status reported to UI listeners.
enum SyncStatus { idle, syncing, success, failed, conflict }

/// Which side of a one-way sync this phone is.
enum SyncRole {
  /// The host: sends its pending records, and nothing else.
  sender,

  /// The client: receives and applies, and sends back only an
  /// acknowledgement. Its own pending changes stay pending.
  receiver,
}

/// Orchestrates one sync, host to client.
///
/// Sync is one way: the [SyncRole.sender] (host) sends every record that
/// changed there since it was last sent, and the [SyncRole.receiver] (client)
/// applies them. For the client's changes to travel, that phone must be the
/// host.
///
/// The engine:
/// 1. Ensures every local record has a deterministic sync ID.
/// 2. Sender: encrypts and sends its pending records, waits for the client's
///    acknowledgement, and only then marks the sent records as synced.
/// 3. Receiver: decrypts and applies in one transaction, marks only what it
///    applied as synced, and acknowledges.
/// 4. Logs every sync attempt for the health dashboard.
class SyncEngine {
  final AppDatabase db;
  final SyncProtocol protocol;
  final SyncEncryptionService encryption;
  final String deviceId;
  final BackupAttachmentCipher? attachmentCipher;

  /// Whether this phone sends (host) or receives (client).
  final SyncRole role;

  /// The most file bytes one push sends; [maxFileBytesPerSync] unless a test
  /// sets a smaller limit.
  final int maxFileBytes;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  /// Number of consecutive failures for exponential back-off.
  int _consecutiveFailures = 0;

  /// The most file bytes one sync sends. The whole payload travels as one
  /// line, capped at 150 MB (`WifiSyncConstants.payloadLineCap`), and base64
  /// makes data a third larger.
  static const int maxFileBytesPerSync = 100 * 1024 * 1024;

  /// Records left out of the last push because their file did not fit or
  /// could not be read. They are not marked as synced, so a later sync sends
  /// them.
  final Set<String> _leftOutSyncIds = <String>{};

  /// Records in the last push, with the version that was sent. Only these are
  /// marked as synced, and only while their version is unchanged, so an edit
  /// made during the sync stays pending.
  final Map<String, int> _sentVersions = <String, int>{};

  /// What the last pull did, for the acknowledgement and the sync log.
  _PullCounts _lastPull = _PullCounts();

  /// Tables that participate in sync, in dependency order. The same list
  /// drives the database triggers that mark edits and deletes.
  static const syncableTables = syncTrackedTables;

  SyncEngine({
    required this.db,
    required this.protocol,
    required this.encryption,
    required this.deviceId,
    required this.role,
    this.attachmentCipher,
    this.maxFileBytes = maxFileBytesPerSync,
  });

  /// Runs one sync in this phone's [role], with retry support.
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

        if (role == SyncRole.sender) {
          // ── Phase 2: Send pending records; returns after the client's
          // acknowledgement, or throws without one ──
          final pushResult = await _pushLocalChanges(key);
          totalPushed += pushResult.accepted;
          totalConflicts += pushResult.conflicts;

          // ── Phase 3: Mark only what was sent, and only if unchanged ──
          final now = DateTime.now();
          for (final sent in _sentVersions.entries) {
            await _db.syncMetadataDao.markSyncedAtVersion(
              sent.key,
              sent.value,
              now,
            );
          }
        } else {
          // ── Phase 2: Receive and apply; marks what it applied ──
          final pullResult = await _pullRemoteChanges(key);
          totalPulled += pullResult.records.length;
          totalConflicts += _lastPull.conflicts;

          // ── Phase 3: Tell the host it may mark the records as sent ──
          await _protocol.acknowledge(
            SyncAck(
              applied: _lastPull.applied,
              skipped: _lastPull.total,
              conflicts: _lastPull.conflicts,
            ),
          );
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
