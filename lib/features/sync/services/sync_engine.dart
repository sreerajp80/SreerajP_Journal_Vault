import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_id_generator.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_protocol.dart';

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

  AppDatabase get _db => db;
  SyncProtocol get _protocol => protocol;
  SyncEncryptionService get _encryption => encryption;
  String get _deviceId => deviceId;
  BackupAttachmentCipher? get _attachmentCipher => attachmentCipher;

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

  /// Encrypts and pushes all unsynced local records.
  Future<SyncPushResult> _pushLocalChanges(
    dynamic key, // SecretKey
  ) async {
    final unsynced = await _db.syncMetadataDao.getUnsyncedRecords();
    if (unsynced.isEmpty) {
      return const SyncPushResult(accepted: 0, rejected: 0, conflicts: 0);
    }

    final syncRecords = <SyncRecord>[];
    for (final meta in unsynced) {
      final data = await _getRecordData(meta.recordTable, meta.localId);
      if (data == null) continue;

      final encrypted = await _encryption.encryptRecord(data, key);
      syncRecords.add(
        SyncRecord(
          syncId: meta.syncId,
          recordTable: meta.recordTable,
          version: meta.version,
          deviceId: meta.deviceId,
          isDeleted: meta.isDeleted,
          lastModifiedAt: meta.lastModifiedAt,
          encryptedData: encrypted,
        ),
      );
    }

    final checksum = await _encryption.computeChecksum(
      syncRecords.map((r) => r.encryptedData).toList(),
    );

    final payload = SyncPayload(
      deviceId: _deviceId,
      timestamp: DateTime.now(),
      records: syncRecords,
      encryptedChecksum: checksum,
    );

    final result = await _protocol.push(payload);

    // Store conflicts for user resolution
    for (final conflictRecord in result.conflictRecords) {
      final localMeta = await _db.syncMetadataDao.getBySyncId(
        conflictRecord.syncId,
      );
      if (localMeta == null) continue;

      final localData = await _getRecordData(
        localMeta.recordTable,
        localMeta.localId,
      );

      await _db.syncConflictsDao.createConflict(
        SyncConflictsCompanion.insert(
          syncId: conflictRecord.syncId,
          recordTable: conflictRecord.recordTable,
          localVersion: localMeta.version,
          remoteVersion: conflictRecord.version,
          localDataJson: jsonEncode(localData),
          remoteDataJson: conflictRecord.encryptedData,
        ),
      );
    }

    return result;
  }

  /// Pulls and decrypts remote records, merging non-conflicting changes.
  Future<SyncPullResult> _pullRemoteChanges(
    dynamic key, // SecretKey
  ) async {
    final lastSync = await _db.syncLogsDao.getLatestSuccessful();
    final lastTimestamp = lastSync?.completedAt;

    final result = await _protocol.pull(lastTimestamp, _deviceId);

    for (final remoteRecord in result.records) {
      final localMeta = await _db.syncMetadataDao.getBySyncId(
        remoteRecord.syncId,
      );

      if (localMeta == null) {
        // New record from another device — decrypt and insert
        final decrypted = await _encryption.decryptRecord(
          remoteRecord.encryptedData,
          key,
        );
        await _insertRemoteRecord(
          remoteRecord.recordTable,
          decrypted,
          remoteRecord,
        );
      } else if (remoteRecord.version > localMeta.version) {
        // Remote is newer — check for local modifications
        final isLocallyModified =
            localMeta.lastSyncedAt != null &&
            localMeta.lastModifiedAt.isAfter(localMeta.lastSyncedAt!);

        if (isLocallyModified) {
          // Conflict: both sides modified
          final localData = await _getRecordData(
            localMeta.recordTable,
            localMeta.localId,
          );
          await _db.syncConflictsDao.createConflict(
            SyncConflictsCompanion.insert(
              syncId: remoteRecord.syncId,
              recordTable: remoteRecord.recordTable,
              localVersion: localMeta.version,
              remoteVersion: remoteRecord.version,
              localDataJson: jsonEncode(localData),
              remoteDataJson: remoteRecord.encryptedData,
            ),
          );
        } else {
          // No local conflict — apply remote version
          final decrypted = await _encryption.decryptRecord(
            remoteRecord.encryptedData,
            key,
          );
          await _updateLocalRecord(
            localMeta.recordTable,
            localMeta.localId,
            decrypted,
          );
          await _db.syncMetadataDao.markSynced(
            remoteRecord.syncId,
            DateTime.now(),
          );
        }
      }
      // If local version >= remote version, skip (local wins or already up-to-date)
    }

    return result;
  }

  // ─────────────── Table-specific helpers ───────────────

  /// Returns all local IDs for a given syncable table.
  Future<List<int>> _getLocalIdsForTable(String table) async {
    final result = await _db
        .customSelect('SELECT id FROM $table', variables: [])
        .get();
    return result.map((row) => row.read<int>('id')).toList();
  }

  /// Reads the full record data for a given table and local ID.
  Future<Map<String, dynamic>?> _getRecordData(
    String table,
    int localId,
  ) async {
    final results = await _db
        .customSelect(
          'SELECT * FROM $table WHERE id = ?',
          variables: [Variable.withInt(localId)],
        )
        .get();
    if (results.isEmpty) return null;

    // Convert QueryRow to Map
    final row = results.first;
    final data = Map<String, dynamic>.from(row.data);

    final cipher = _attachmentCipher;
    if (table == 'attachments' && cipher != null) {
      try {
        final filePath =
            data['file_path'] as String? ?? data['filePath'] as String?;
        final nonce =
            data['nonce_base64'] as String? ?? data['nonceBase64'] as String?;
        final keyRef =
            data['key_reference'] as String? ?? data['keyReference'] as String?;
        final fileName =
            data['file_name'] as String? ??
            data['fileName'] as String? ??
            'attachment.bin';
        if (filePath != null && nonce != null && keyRef != null) {
          final bytes = await cipher.decryptToBytes(
            encryptedPath: filePath,
            nonceBase64: nonce,
            keyReference: keyRef,
            fileName: fileName,
          );
          data['_attachmentBytesBase64'] = base64Encode(bytes);
        }
      } catch (_) {
        // Continue if attachment file could not be read
      }
    }

    return data;
  }

  /// Inserts a new record received from a remote device.
  Future<void> _insertRemoteRecord(
    String table,
    Map<String, dynamic> data,
    SyncRecord meta,
  ) async {
    // Remove 'id' to let auto-increment assign a local ID
    final insertData = Map<String, dynamic>.from(data)..remove('id');
    final attachmentBytesB64 =
        insertData.remove('_attachmentBytesBase64') as String?;

    final cipher = _attachmentCipher;
    if (table == 'attachments' &&
        attachmentBytesB64 != null &&
        cipher != null) {
      try {
        final bytes = base64Decode(attachmentBytesB64);
        final fileName =
            (insertData['file_name'] ??
                    insertData['fileName'] ??
                    'attachment.bin')
                as String;
        final stored = await cipher.encryptFromBytes(
          bytes: bytes,
          fileName: fileName,
        );
        if (insertData.containsKey('file_path')) {
          insertData['file_path'] = stored.encryptedPath;
        } else {
          insertData['filePath'] = stored.encryptedPath;
        }
        if (insertData.containsKey('nonce_base64')) {
          insertData['nonce_base64'] = stored.nonceBase64;
        } else {
          insertData['nonceBase64'] = stored.nonceBase64;
        }
        if (insertData.containsKey('key_reference')) {
          insertData['key_reference'] = stored.keyReference;
        } else {
          insertData['keyReference'] = stored.keyReference;
        }
        if (insertData.containsKey('file_size_bytes')) {
          insertData['file_size_bytes'] = stored.sizeBytes;
        } else {
          insertData['fileSizeBytes'] = stored.sizeBytes;
        }
      } catch (_) {
        // Fallback: keep original metadata if re-encryption fails
      }
    }

    final columns = insertData.keys.join(', ');
    final placeholders = insertData.keys.map((_) => '?').join(', ');
    final values = insertData.values.map((v) => Variable(v)).toList();

    await _db.customInsert(
      'INSERT INTO $table ($columns) VALUES ($placeholders)',
      variables: values,
    );

    // Get the inserted row's local ID
    final lastId = await _db
        .customSelect('SELECT last_insert_rowid() AS id', variables: [])
        .getSingle();
    final newLocalId = lastId.read<int>('id');

    // Create sync metadata for the new record
    await _db.syncMetadataDao.upsert(
      SyncMetadataCompanion.insert(
        recordTable: table,
        localId: newLocalId,
        syncId: meta.syncId,
        deviceId: meta.deviceId,
      ),
    );
  }

  /// Updates an existing local record with remote data.
  Future<void> _updateLocalRecord(
    String table,
    int localId,
    Map<String, dynamic> data,
  ) async {
    final updateData = Map<String, dynamic>.from(data)..remove('id');
    final attachmentBytesB64 =
        updateData.remove('_attachmentBytesBase64') as String?;

    final cipher = _attachmentCipher;
    if (table == 'attachments' &&
        attachmentBytesB64 != null &&
        cipher != null) {
      try {
        final bytes = base64Decode(attachmentBytesB64);
        final fileName =
            (updateData['file_name'] ??
                    updateData['fileName'] ??
                    'attachment.bin')
                as String;
        final stored = await cipher.encryptFromBytes(
          bytes: bytes,
          fileName: fileName,
        );
        if (updateData.containsKey('file_path')) {
          updateData['file_path'] = stored.encryptedPath;
        } else {
          updateData['filePath'] = stored.encryptedPath;
        }
        if (updateData.containsKey('nonce_base64')) {
          updateData['nonce_base64'] = stored.nonceBase64;
        } else {
          updateData['nonceBase64'] = stored.nonceBase64;
        }
        if (updateData.containsKey('key_reference')) {
          updateData['key_reference'] = stored.keyReference;
        } else {
          updateData['keyReference'] = stored.keyReference;
        }
        if (updateData.containsKey('file_size_bytes')) {
          updateData['file_size_bytes'] = stored.sizeBytes;
        } else {
          updateData['fileSizeBytes'] = stored.sizeBytes;
        }
      } catch (_) {
        // Fallback
      }
    }

    final setClause = updateData.keys.map((k) => '$k = ?').join(', ');
    final values = [
      ...updateData.values.map((v) => Variable(v)),
      Variable.withInt(localId),
    ];

    await _db.customUpdate(
      'UPDATE $table SET $setClause WHERE id = ?',
      variables: values,
      updates: {},
    );
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
