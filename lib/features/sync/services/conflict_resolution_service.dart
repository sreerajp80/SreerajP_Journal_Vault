import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';

/// Conflict resolution strategy chosen by the user.
enum ConflictResolution {
  keepLocal,
  keepRemote,
  merged,
}

/// A conflict presented to the user for resolution.
class ConflictDetail {
  final int conflictId;
  final String syncId;
  final String recordTable;
  final int localVersion;
  final int remoteVersion;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime detectedAt;

  /// Field-level diffs for the UI to highlight changes.
  final List<FieldDiff> diffs;

  const ConflictDetail({
    required this.conflictId,
    required this.syncId,
    required this.recordTable,
    required this.localVersion,
    required this.remoteVersion,
    required this.localData,
    required this.remoteData,
    required this.detectedAt,
    required this.diffs,
  });
}

/// A single field difference between local and remote versions.
class FieldDiff {
  final String fieldName;
  final dynamic localValue;
  final dynamic remoteValue;

  const FieldDiff({
    required this.fieldName,
    required this.localValue,
    required this.remoteValue,
  });

  bool get hasChanged => localValue != remoteValue;
}

/// Manages conflict resolution: loading, diffing, and applying user choices.
class ConflictResolutionService {
  final AppDatabase _db;
  final SyncEncryptionService _encryption;

  ConflictResolutionService({
    required AppDatabase db,
    required SyncEncryptionService encryption,
  })  : _db = db,
        _encryption = encryption;

  /// Returns all pending conflicts with field-level diffs computed.
  Future<List<ConflictDetail>> getPendingConflicts({
    String? syncPassword,
  }) async {
    final conflicts = await _db.syncConflictsDao.getPendingConflicts();
    final details = <ConflictDetail>[];

    for (final conflict in conflicts) {
      final localData =
          jsonDecode(conflict.localDataJson) as Map<String, dynamic>;

      // Remote data may be encrypted (if it came from a push conflict) or
      // plain JSON (if it was a local snapshot). Try both.
      Map<String, dynamic> remoteData;
      try {
        remoteData =
            jsonDecode(conflict.remoteDataJson) as Map<String, dynamic>;
      } catch (_) {
        if (syncPassword != null) {
          final salt = List.generate(16, (i) => i);
          final key = await _encryption.deriveKey(syncPassword, salt);
          remoteData = await _encryption.decryptRecord(
              conflict.remoteDataJson, key);
        } else {
          remoteData = {'_encrypted': true, '_raw': conflict.remoteDataJson};
        }
      }

      final diffs = _computeDiffs(localData, remoteData);

      details.add(ConflictDetail(
        conflictId: conflict.id,
        syncId: conflict.syncId,
        recordTable: conflict.recordTable,
        localVersion: conflict.localVersion,
        remoteVersion: conflict.remoteVersion,
        localData: localData,
        remoteData: remoteData,
        detectedAt: conflict.detectedAt,
        diffs: diffs,
      ));
    }

    return details;
  }

  /// Resolves a conflict by applying the user's chosen strategy.
  Future<void> resolveConflict({
    required int conflictId,
    required ConflictResolution resolution,
    Map<String, dynamic>? mergedData,
  }) async {
    final conflict = await _db.syncConflictsDao.getConflictById(conflictId);

    switch (resolution) {
      case ConflictResolution.keepLocal:
        // No data changes needed — local version is already in the DB.
        // Just bump version so next sync pushes our version.
        await _db.syncMetadataDao.incrementVersion(conflict.syncId);
        await _db.syncConflictsDao
            .resolveConflict(conflictId, 'keep_local');
        break;

      case ConflictResolution.keepRemote:
        // Apply remote data to local record.
        Map<String, dynamic> remoteData;
        try {
          remoteData =
              jsonDecode(conflict.remoteDataJson) as Map<String, dynamic>;
        } catch (_) {
          throw ConflictResolutionException(
            'Cannot apply remote data — decryption required',
          );
        }

        final meta = await _db.syncMetadataDao.getBySyncId(conflict.syncId);
        if (meta != null) {
          await _applyDataToRecord(meta.recordTable, meta.localId, remoteData);
          await _db.syncMetadataDao.markSynced(
              conflict.syncId, DateTime.now());
        }
        await _db.syncConflictsDao
            .resolveConflict(conflictId, 'keep_remote');
        break;

      case ConflictResolution.merged:
        if (mergedData == null) {
          throw ConflictResolutionException(
            'Merged data must be provided for merge resolution',
          );
        }
        final meta = await _db.syncMetadataDao.getBySyncId(conflict.syncId);
        if (meta != null) {
          await _applyDataToRecord(
              meta.recordTable, meta.localId, mergedData);
          await _db.syncMetadataDao.incrementVersion(conflict.syncId);
        }
        await _db.syncConflictsDao
            .resolveConflict(conflictId, 'merged');
        break;
    }
  }

  /// Dismisses a conflict without applying any changes.
  Future<void> dismissConflict(int conflictId) async {
    await _db.syncConflictsDao.dismissConflict(conflictId);
  }

  // ─────────────── Helpers ───────────────

  List<FieldDiff> _computeDiffs(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final allKeys = {...local.keys, ...remote.keys};
    return allKeys
        .where((key) => key != 'id' && key != 'created_at')
        .map((key) => FieldDiff(
              fieldName: key,
              localValue: local[key],
              remoteValue: remote[key],
            ))
        .where((diff) => diff.hasChanged)
        .toList();
  }

  Future<void> _applyDataToRecord(
    String table,
    int localId,
    Map<String, dynamic> data,
  ) async {
    final updateData = Map<String, dynamic>.from(data)..remove('id');
    if (updateData.isEmpty) return;

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

class ConflictResolutionException implements Exception {
  final String message;
  const ConflictResolutionException(this.message);

  @override
  String toString() => 'ConflictResolutionException: $message';
}
