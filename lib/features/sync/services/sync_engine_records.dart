part of 'sync_engine.dart';

/// What a pull did, for the acknowledgement and one log line with counts
/// only.
class _PullCounts {
  int applied = 0;
  int conflicts = 0;
  int otherTable = 0;
  int unresolved = 0;
  int noFile = 0;

  /// Records that could not be applied.
  int get total => otherTable + unresolved + noFile;

  void count(SyncApplyOutcome outcome) {
    switch (outcome) {
      case SyncApplyOutcome.applied:
        applied++;
      case SyncApplyOutcome.unresolved:
        unresolved++;
      case SyncApplyOutcome.noFile:
        noFile++;
      case SyncApplyOutcome.nothing:
        break;
    }
  }
}

/// An entry or revision whose text still holds the other phone's row IDs.
/// They are rewritten once every record of the pull is in place.
class _TextFixup {
  const _TextFixup(this.table, this.localId, this.refs);

  final String table;
  final int localId;

  /// Per table, the other phone's row ID → sync ID.
  final Map<String, dynamic> refs;
}

extension _SyncEnginePart1 on SyncEngine {
  AppDatabase get _db => db;

  SyncProtocol get _protocol => protocol;

  SyncEncryptionService get _encryption => encryption;

  String get _deviceId => deviceId;

  BackupAttachmentCipher? get _attachmentCipher => attachmentCipher;

  SyncSchemaGuard get _schemaGuard =>
      SyncSchemaGuard(_db, syncableTables: SyncEngine.syncableTables);

  SyncRecordApplier get _applier => SyncRecordApplier(
    db: _db,
    cipher: _attachmentCipher,
    syncableTables: SyncEngine.syncableTables,
  );

  /// Encrypts and sends every pending record, tombstones included, and
  /// returns once the client has acknowledged them.
  ///
  /// A record with a file is sent with the file's bytes. Files are added only
  /// while their total stays under [SyncEngine.maxFileBytes]; a record
  /// whose file does not fit, or cannot be read, is left out and stays
  /// pending, so a later sync sends it. The payload is sent even when it is
  /// empty, so the client is never left waiting.
  Future<SyncPushResult> _pushLocalChanges(
    dynamic key, // SecretKey
  ) async {
    _leftOutSyncIds.clear();
    _sentVersions.clear();
    final pending = await _db.syncMetadataDao.getUnsyncedRecords();

    var fileBudget = maxFileBytes;
    final syncRecords = <SyncRecord>[];
    for (final meta in pending) {
      final Map<String, dynamic> data;
      if (meta.isDeleted) {
        // A tombstone carries no content, only which record to delete.
        data = const {};
      } else {
        final row = await _getRecordData(meta.recordTable, meta.localId);
        if (row == null) continue;
        data = row;

        if (syncFileTables.contains(meta.recordTable)) {
          final bytes = await _readStoredFile(meta.recordTable, meta.localId);
          if (bytes == null || bytes.length > fileBudget) {
            _leftOutSyncIds.add(meta.syncId);
            continue;
          }
          fileBudget -= bytes.length;
          data[syncFileKey] = base64Encode(bytes);
        }
      }

      final encrypted = await _encryption.encryptRecord(data, key);
      _sentVersions[meta.syncId] = meta.version;
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
    if (_leftOutSyncIds.isNotEmpty) {
      AppLogger.info(
        'SyncEngine: ${_leftOutSyncIds.length} files left for a later sync',
      );
    }

    final checksum = await _encryption.computeChecksum(
      syncRecords.map((r) => r.encryptedData).toList(),
    );

    return _protocol.push(
      SyncPayload(
        deviceId: _deviceId,
        timestamp: DateTime.now(),
        records: syncRecords,
        encryptedChecksum: checksum,
      ),
    );
  }

  /// Receives the host's records and applies them in one transaction.
  ///
  /// - Edits and new records are applied parents first, in the order of
  ///   [SyncEngine.syncableTables]. Tombstones are applied after them,
  ///   children first.
  /// - A record that also changed here since the last sync is not applied:
  ///   both versions go to the conflict screen.
  /// - Every reference becomes this phone's own row ID; a record whose
  ///   reference cannot be resolved is skipped.
  /// - Files replaced or deleted are removed only after the transaction
  ///   commits.
  Future<SyncPullResult> _pullRemoteChanges(
    dynamic key, // SecretKey
  ) async {
    final lastSync = await _db.syncLogsDao.getLatestSuccessful();
    final lastTimestamp = lastSync?.completedAt;

    final result = await _protocol.pull(lastTimestamp, _deviceId);
    final guard = _schemaGuard;
    final applier = _applier;
    final counts = _PullCounts();

    // A table name from the other phone goes into SQL text, so only the
    // tables this app syncs are accepted.
    const order = SyncEngine.syncableTables;
    final upserts = <(int, int, SyncRecord)>[];
    final tombstones = <(int, int, SyncRecord)>[];
    for (var i = 0; i < result.records.length; i++) {
      final record = result.records[i];
      if (!guard.isSyncable(record.recordTable)) {
        counts.otherTable++;
        continue;
      }
      final item = (order.indexOf(record.recordTable), i, record);
      (record.isDeleted ? tombstones : upserts).add(item);
    }
    // Parents first for upserts, children first for deletes; records of one
    // table keep the order they came in.
    upserts.sort(
      (a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
    );
    tombstones.sort(
      (a, b) => a.$1 != b.$1 ? b.$1.compareTo(a.$1) : a.$2.compareTo(b.$2),
    );

    final filesToDelete = <String>[];
    await _db.transaction(() async {
      // Records already changed here before this pull. They stay pending:
      // they are this phone's own changes, to send when it is the host.
      final pendingBefore = await _db.syncMetadataDao.pendingSyncIds();
      final fixups = <_TextFixup>[];

      for (final (_, _, remote) in upserts) {
        final localMeta = await _db.syncMetadataDao.getBySyncId(remote.syncId);
        if (localMeta != null && localMeta.recordTable != remote.recordTable) {
          counts.otherTable++;
          continue;
        }
        final data = await _encryption.decryptRecord(remote.encryptedData, key);

        if (localMeta != null && pendingBefore.contains(remote.syncId)) {
          // Changed on both phones: the user decides.
          await _storeConflict(localMeta, remote, data);
          counts.conflicts++;
          continue;
        }

        int? localId;
        if (localMeta == null || localMeta.isDeleted) {
          // New here, or deleted here earlier while the host kept it.
          final (outcome, newId) = await applier.insert(
            remote.recordTable,
            data,
            syncId: remote.syncId,
            deviceId: remote.deviceId,
          );
          counts.count(outcome);
          localId = newId;
        } else {
          final outcome = await applier.update(
            remote.recordTable,
            localMeta.localId,
            data,
            filesToDelete,
          );
          counts.count(outcome);
          if (outcome == SyncApplyOutcome.applied) localId = localMeta.localId;
        }

        final refs = data[syncTextRefsKey];
        if (localId != null && refs is Map<String, dynamic>) {
          fixups.add(_TextFixup(remote.recordTable, localId, refs));
        }
      }

      for (final fixup in fixups) {
        await applier.rewriteTextIds(fixup.table, fixup.localId, fixup.refs);
      }

      for (final (_, _, remote) in tombstones) {
        final localMeta = await _db.syncMetadataDao.getBySyncId(remote.syncId);
        // Unknown here, or already gone here: nothing to delete.
        if (localMeta == null || localMeta.isDeleted) continue;
        if (localMeta.recordTable != remote.recordTable) {
          counts.otherTable++;
          continue;
        }
        if (pendingBefore.contains(remote.syncId)) {
          // Deleted there, changed here: the user decides.
          await _storeConflict(localMeta, remote, const {});
          counts.conflicts++;
          continue;
        }
        counts.count(
          await applier.delete(
            localMeta.recordTable,
            localMeta.localId,
            filesToDelete,
          ),
        );
      }

      // Applying fired this phone's change triggers on every row it touched,
      // cascades included. Those rows now match the host, so they are synced;
      // only what was pending before stays pending.
      await _db.syncMetadataDao.markPendingSyncedExcept(
        pendingBefore,
        DateTime.now(),
      );
    });
    _lastPull = counts;

    await _deleteFilesAfterCommit(filesToDelete);

    if (counts.total > 0) {
      AppLogger.warning(
        'SyncEngine: skipped ${counts.total} records '
        '(${counts.otherTable} other table, ${counts.unresolved} missing '
        'parent, ${counts.noFile} missing file)',
      );
    }
    return result;
  }

  /// Stores a record that changed on both phones, for the conflict screen.
  ///
  /// Both sides are kept as decoded JSON: the database is encrypted with
  /// SQLCipher, and the pairing code that sealed the payload does not outlive
  /// the session. A deleted side is `{"_deleted": true}`. A file sent with
  /// the other phone's version is stored now, under this phone's key, and
  /// its details kept in the conflict. An older open conflict for the same
  /// record is replaced.
  Future<void> _storeConflict(
    SyncMetadataData localMeta,
    SyncRecord remote,
    Map<String, dynamic> remoteData,
  ) async {
    final local = localMeta.isDeleted
        ? null
        : await _getRecordData(localMeta.recordTable, localMeta.localId);
    final localJson = local ?? const {syncDeletedKey: true};

    final Map<String, dynamic> remoteJson;
    if (remote.isDeleted) {
      remoteJson = const {syncDeletedKey: true};
    } else {
      remoteJson = Map<String, dynamic>.from(remoteData)..remove(syncFileKey);
      if (syncFileTables.contains(remote.recordTable)) {
        final stored = await _applier.storeFile(remoteData);
        if (stored != null) {
          remoteJson[syncConflictFileKey] = storedFileToJson(stored);
        }
      }
    }

    await _db.syncConflictsDao.replaceOpenConflict(
      SyncConflictsCompanion.insert(
        syncId: remote.syncId,
        recordTable: remote.recordTable,
        localVersion: localMeta.version,
        remoteVersion: remote.version,
        localDataJson: jsonEncode(localJson),
        remoteDataJson: jsonEncode(remoteJson),
      ),
      onReplaced: (old) async {
        final file = storedFileFromJson(
          _decodeOrEmpty(old.remoteDataJson)[syncConflictFileKey],
        );
        final cipher = _attachmentCipher;
        if (file != null && cipher != null) {
          try {
            await cipher.deleteStoredFile(file.encryptedPath);
          } catch (_) {
            // Left for the startup orphan sweep.
          }
        }
      },
    );
  }

  Future<void> _deleteFilesAfterCommit(List<String> paths) async {
    final cipher = _attachmentCipher;
    if (cipher == null) return;
    for (final path in paths) {
      try {
        await cipher.deleteStoredFile(path);
      } catch (_) {
        // Left for the startup orphan sweep.
      }
    }
  }

  /// Reads a record as it is sent to the other phone.
  ///
  /// Every row ID that points at another row is replaced by that row's sync
  /// ID (`{"$ref": ...}`); an entry's or revision's text references are
  /// listed under [syncTextRefsKey]; and the columns that describe a file on
  /// this phone are left out. File bytes are added by the caller.
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

    final data = Map<String, dynamic>.from(results.first.data);
    if (syncFileTables.contains(table)) {
      data.removeWhere((column, _) => syncDeviceFileColumns.contains(column));
    }

    for (final column in (syncReferenceColumns[table] ?? const {}).entries) {
      final value = data[column.key];
      data[column.key] = value is int
          ? syncRef(await _syncIdOf(column.value, value))
          : null;
    }

    if (table == 'backlinks') {
      final targetTable = backlinkTargetTable[data['target_type']];
      final value = data['target_id'];
      data['target_id'] = targetTable != null && value is int
          ? syncRef(await _syncIdOf(targetTable, value))
          : null;
    }

    if (syncTextTables.contains(table)) {
      final refs = textReferences(
        contentJson: data['content_json'] as String?,
        plainText: data['plain_text'] as String?,
      );
      final sent = <String, Map<String, String>>{};
      for (final entry in refs.entries) {
        for (final id in entry.value) {
          final syncId = await _syncIdOf(entry.key, id);
          if (syncId != null) {
            (sent[entry.key] ??= {})['$id'] = syncId;
          }
        }
      }
      if (sent.isNotEmpty) data[syncTextRefsKey] = sent;
    }

    return data;
  }

  /// The sync ID of row [localId] in [table], or null when it has none.
  Future<String?> _syncIdOf(String table, int localId) async =>
      (await _db.syncMetadataDao.getByRecord(table, localId))?.syncId;

  /// The plain bytes of the file behind row [localId] of [table], or null
  /// when there is no cipher or the file cannot be read.
  Future<Uint8List?> _readStoredFile(String table, int localId) async {
    final cipher = _attachmentCipher;
    if (cipher == null) return null;
    try {
      final row = await _db
          .customSelect(
            'SELECT encrypted_path, nonce_base64, key_reference, file_name '
            'FROM $table WHERE id = ?',
            variables: [Variable.withInt(localId)],
          )
          .getSingle();
      return await cipher.decryptToBytes(
        encryptedPath: row.read<String>('encrypted_path'),
        nonceBase64: row.read<String>('nonce_base64'),
        keyReference: row.read<String>('key_reference'),
        fileName: row.read<String>('file_name'),
      );
    } catch (_) {
      return null;
    }
  }
}

Map<String, dynamic> _decodeOrEmpty(String json) {
  try {
    final decoded = jsonDecode(json);
    return decoded is Map<String, dynamic> ? decoded : const {};
  } catch (_) {
    return const {};
  }
}
