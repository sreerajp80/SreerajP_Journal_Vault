import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_record_applier.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_references.dart';

/// Conflict resolution strategy chosen by the user.
enum ConflictResolution { keepLocal, keepRemote, merged }

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

  /// True when the item was deleted on this phone.
  bool get isLocalDeleted => localData[syncDeletedKey] == true;

  /// True when the item was deleted on the other phone.
  bool get isRemoteDeleted => remoteData[syncDeletedKey] == true;

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
///
/// A conflict is a record that changed on both phones, or was deleted on one
/// and changed on the other. Both versions are stored as decoded JSON (the
/// database is encrypted with SQLCipher); a deleted side is
/// `{"_deleted": true}`.
class ConflictResolutionService {
  final AppDatabase _db;
  final SyncEncryptionService _encryption;
  final BackupAttachmentCipher? _cipher;

  ConflictResolutionService({
    required this._db,
    required this._encryption,
    this._cipher,
  });

  SyncRecordApplier get _applier => SyncRecordApplier(
    db: _db,
    cipher: _cipher,
    syncableTables: SyncEngine.syncableTables,
  );

  /// Returns all pending conflicts with field-level diffs computed.
  ///
  /// [syncPassword] only matters for a conflict stored by an older app
  /// version, whose other-phone data was still sealed with the pairing code.
  Future<List<ConflictDetail>> getPendingConflicts({
    String? syncPassword,
  }) async {
    final conflicts = await _db.syncConflictsDao.getPendingConflicts();
    final details = <ConflictDetail>[];

    for (final conflict in conflicts) {
      final localData =
          jsonDecode(conflict.localDataJson) as Map<String, dynamic>;

      Map<String, dynamic> remoteData;
      try {
        remoteData =
            jsonDecode(conflict.remoteDataJson) as Map<String, dynamic>;
      } catch (_) {
        if (syncPassword != null) {
          final salt = List.generate(16, (i) => i);
          final key = await _encryption.deriveKey(syncPassword, salt);
          remoteData = await _encryption.decryptRecord(
            conflict.remoteDataJson,
            key,
          );
        } else {
          remoteData = {'_encrypted': true, '_raw': conflict.remoteDataJson};
        }
      }

      details.add(
        ConflictDetail(
          conflictId: conflict.id,
          syncId: conflict.syncId,
          recordTable: conflict.recordTable,
          localVersion: conflict.localVersion,
          remoteVersion: conflict.remoteVersion,
          localData: localData,
          remoteData: remoteData,
          detectedAt: conflict.detectedAt,
          diffs: _computeDiffs(localData, remoteData),
        ),
      );
    }

    return details;
  }

  /// Resolves a conflict by applying the user's chosen strategy.
  ///
  /// - [ConflictResolution.keepLocal]: this phone's version stays, and stays
  ///   pending, so it reaches the other phone the next time this phone is the
  ///   host.
  /// - [ConflictResolution.keepRemote]: the other phone's version is applied
  ///   here, with the same rules as a sync; a deleted side deletes the item.
  ///   Throws a [ConflictResolutionException] with `missingParent` when an
  ///   item it points at is missing; the conflict then stays open.
  /// - [ConflictResolution.merged]: [mergedData] is applied and stays pending.
  Future<void> resolveConflict({
    required int conflictId,
    required ConflictResolution resolution,
    Map<String, dynamic>? mergedData,
  }) async {
    final conflict = await _db.syncConflictsDao.getConflictById(conflictId);

    switch (resolution) {
      case ConflictResolution.keepLocal:
        await _db.syncMetadataDao.incrementVersion(conflict.syncId);
        await _db.syncConflictsDao.resolveConflict(conflictId, 'keep_local');
        await _deleteConflictFile(conflict);

      case ConflictResolution.keepRemote:
        final Map<String, dynamic> remoteData;
        try {
          remoteData =
              jsonDecode(conflict.remoteDataJson) as Map<String, dynamic>;
        } catch (_) {
          throw const ConflictResolutionException(
            'Cannot apply remote data — decryption required',
          );
        }
        await _applyRemote(conflict, remoteData);

      case ConflictResolution.merged:
        if (mergedData == null) {
          throw const ConflictResolutionException(
            'Merged data must be provided for merge resolution',
          );
        }
        final meta = await _db.syncMetadataDao.getBySyncId(conflict.syncId);
        if (meta != null && !meta.isDeleted) {
          final filesToDelete = <String>[];
          final outcome = await _applier.update(
            meta.recordTable,
            meta.localId,
            // A merge never carries a file; the local file stays.
            Map<String, dynamic>.from(mergedData)..remove(syncFileKey),
            filesToDelete,
          );
          if (outcome == SyncApplyOutcome.unresolved) {
            throw const ConflictResolutionException(
              'An item this record points at is missing',
              missingParent: true,
            );
          }
          await _db.syncMetadataDao.incrementVersion(conflict.syncId);
        }
        await _db.syncConflictsDao.resolveConflict(conflictId, 'merged');
        await _deleteConflictFile(conflict);
    }
  }

  /// Dismisses a conflict without applying any changes.
  Future<void> dismissConflict(int conflictId) async {
    final conflict = await _db.syncConflictsDao.getConflictById(conflictId);
    await _db.syncConflictsDao.dismissConflict(conflictId);
    await _deleteConflictFile(conflict);
  }

  // ─────────────── Helpers ───────────────

  Future<void> _applyRemote(
    SyncConflict conflict,
    Map<String, dynamic> remoteData,
  ) async {
    final table = conflict.recordTable;
    if (!SyncEngine.syncableTables.contains(table)) {
      AppLogger.warning(
        'ConflictResolutionService: skipped a table that does not sync',
      );
      await _db.syncConflictsDao.resolveConflict(conflict.id, 'keep_remote');
      return;
    }
    final storedFile = storedFileFromJson(remoteData[syncConflictFileKey]);
    final filesToDelete = <String>[];
    var fileUsed = false;

    await _db.transaction(() async {
      // Changes already pending here, other than this record, stay pending.
      final pendingBefore = await _db.syncMetadataDao.pendingSyncIds()
        ..remove(conflict.syncId);
      final meta = await _db.syncMetadataDao.getBySyncId(conflict.syncId);
      final applier = _applier;

      if (remoteData[syncDeletedKey] == true) {
        if (meta != null && !meta.isDeleted) {
          await applier.delete(meta.recordTable, meta.localId, filesToDelete);
        }
      } else {
        final SyncApplyOutcome outcome;
        int? localId;
        final exists =
            meta != null &&
            !meta.isDeleted &&
            await _rowExists(table, meta.localId);
        if (exists) {
          outcome = await applier.update(
            table,
            meta.localId,
            remoteData,
            filesToDelete,
            storedFile: storedFile,
          );
          localId = meta.localId;
        } else {
          final (inserted, newId) = await applier.insert(
            table,
            remoteData,
            syncId: conflict.syncId,
            deviceId: meta?.deviceId ?? 'remote',
            storedFile: storedFile,
          );
          outcome = inserted;
          localId = newId;
        }
        if (outcome == SyncApplyOutcome.unresolved ||
            outcome == SyncApplyOutcome.noFile) {
          // Rolls the transaction back; the conflict stays open.
          throw const ConflictResolutionException(
            'An item this record points at is missing',
            missingParent: true,
          );
        }
        fileUsed = storedFile != null;
        final refs = remoteData[syncTextRefsKey];
        if (localId != null && refs is Map<String, dynamic>) {
          await applier.rewriteTextIds(table, localId, refs);
        }
      }

      // This record, and anything the apply cascaded to, now matches the
      // other phone.
      await _db.syncMetadataDao.markPendingSyncedExcept(
        pendingBefore,
        DateTime.now(),
      );
      await _db.syncConflictsDao.resolveConflict(conflict.id, 'keep_remote');
    });

    final cipher = _cipher;
    if (cipher == null) return;
    for (final path in [
      ...filesToDelete,
      if (!fileUsed && storedFile != null) storedFile.encryptedPath,
    ]) {
      try {
        await cipher.deleteStoredFile(path);
      } catch (_) {
        // Left for the startup orphan sweep.
      }
    }
  }

  Future<bool> _rowExists(String table, int localId) async =>
      (await _db
          .customSelect(
            'SELECT id FROM $table WHERE id = ?',
            variables: [Variable.withInt(localId)],
          )
          .getSingleOrNull()) !=
      null;

  /// Deletes the file stored for the other phone's version, if any.
  Future<void> _deleteConflictFile(SyncConflict conflict) async {
    final cipher = _cipher;
    if (cipher == null) return;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(conflict.remoteDataJson) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final file = storedFileFromJson(data[syncConflictFileKey]);
    if (file == null) return;
    try {
      await cipher.deleteStoredFile(file.encryptedPath);
    } catch (_) {
      // Left for the startup orphan sweep.
    }
  }

  List<FieldDiff> _computeDiffs(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final allKeys = {...local.keys, ...remote.keys};
    return allKeys
        .where((key) => key != 'id' && key != 'created_at')
        // Internal sync keys (file bytes, text references) are not fields.
        .where((key) => !key.startsWith('_') || key == syncDeletedKey)
        .map(
          (key) => FieldDiff(
            fieldName: key,
            localValue: local[key],
            remoteValue: remote[key],
          ),
        )
        .where((diff) => diff.hasChanged)
        .toList();
  }
}

class ConflictResolutionException implements Exception {
  final String message;

  /// True when the other phone's version points at an item that is not on
  /// this phone. The conflict stays open.
  final bool missingParent;

  const ConflictResolutionException(this.message, {this.missingParent = false});

  @override
  String toString() => 'ConflictResolutionException: $message';
}
