// Layer: service. Applies one record received over sync to this phone's
// database: insert, update or delete, with the file rules. Used by the sync
// engine and by conflict resolution, so both follow the same rules. Knows
// nothing about widgets, and never logs names or content.

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_deletion_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_reference_resolver.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_references.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_schema_guard.dart';

/// How applying one record went.
enum SyncApplyOutcome {
  /// Inserted, updated, deleted, or matched to an existing row.
  applied,

  /// A reference could not be resolved; nothing was written.
  unresolved,

  /// A record that needs a file came without one; nothing was written.
  noFile,

  /// Nothing to write (no known columns, or the row is already gone).
  nothing,
}

/// Conflict data key: a file received for the other phone's version, already
/// stored under this phone's key while the conflict is open.
const String syncConflictFileKey = '_conflictFile';

/// Record data key marking the item as deleted (a tombstone, or a conflict
/// side that was deleted).
const String syncDeletedKey = '_deleted';

/// Applies received records. All writes happen in the caller's transaction.
/// Files that must go are only **collected**; the caller deletes them after
/// its transaction commits.
class SyncRecordApplier {
  SyncRecordApplier({
    required this._db,
    required this._cipher,
    required List<String> syncableTables,
  }) : _guard = SyncSchemaGuard(_db, syncableTables: syncableTables),
       _resolver = SyncReferenceResolver(_db);

  final AppDatabase _db;
  final BackupAttachmentCipher? _cipher;
  final SyncSchemaGuard _guard;
  final SyncReferenceResolver _resolver;

  /// Inserts a received record as a new row with sync ID [syncId]. Returns
  /// the outcome and the new row's ID (null when nothing was inserted, or a
  /// tag was matched to an existing one by name).
  ///
  /// [storedFile] is a file already stored for this record (a conflict);
  /// otherwise the file bytes in [data] are stored.
  Future<(SyncApplyOutcome, int?)> insert(
    String table,
    Map<String, dynamic> data, {
    required String syncId,
    required String deviceId,
    BackupStoredFile? storedFile,
  }) async {
    final values = await _resolver.localValues(table, data);
    if (values == null) return (SyncApplyOutcome.unresolved, null);
    // The local ID is assigned here.
    values.remove('id');

    // A tag with the same name already exists: map to it, add no second one.
    if (table == 'tags') {
      final existing = await _resolver.localTagIdByName(values['name']);
      if (existing != null) {
        await _db.syncMetadataDao.upsert(
          SyncMetadataCompanion.insert(
            recordTable: table,
            localId: existing,
            syncId: syncId,
            deviceId: deviceId,
          ),
        );
        return (SyncApplyOutcome.applied, null);
      }
    }

    if (syncFileTables.contains(table)) {
      final stored = storedFile ?? await storeFile(data);
      // No row may point at a file that is not there.
      if (stored == null) return (SyncApplyOutcome.noFile, null);
      _putStoredFile(table, values, stored);
    }

    // Column names from the other phone go into SQL text: keep only real ones.
    final known = _guard.knownColumns(table, values);
    if (known.isEmpty) return (SyncApplyOutcome.nothing, null);
    final columns = known.keys.join(', ');
    final placeholders = known.keys.map((_) => '?').join(', ');

    await _db.customInsert(
      'INSERT INTO $table ($columns) VALUES ($placeholders)',
      variables: known.values.map((v) => Variable(v)).toList(),
    );
    final newLocalId =
        (await _db.customSelect('SELECT last_insert_rowid() AS id').getSingle())
            .read<int>('id');

    // Replaces a tombstone row for the same sync ID, if there was one.
    await _db.syncMetadataDao.upsert(
      SyncMetadataCompanion.insert(
        recordTable: table,
        localId: newLocalId,
        syncId: syncId,
        deviceId: deviceId,
      ),
    );
    return (SyncApplyOutcome.applied, newLocalId);
  }

  /// Updates row [localId] of [table] with a received record.
  ///
  /// With a file ([storedFile], or bytes in [data]) the file is replaced and
  /// the old path is added to [filesToDelete]. Without one, the local file
  /// columns and the size are never changed.
  Future<SyncApplyOutcome> update(
    String table,
    int localId,
    Map<String, dynamic> data,
    List<String> filesToDelete, {
    BackupStoredFile? storedFile,
  }) async {
    final values = await _resolver.localValues(table, data);
    if (values == null) return SyncApplyOutcome.unresolved;
    values.remove('id');

    if (syncFileTables.contains(table)) {
      values.remove('size_bytes');
      final stored = storedFile ?? await storeFile(data);
      if (stored != null) {
        final old = await _db
            .customSelect(
              'SELECT encrypted_path FROM $table WHERE id = ?',
              variables: [Variable.withInt(localId)],
            )
            .getSingleOrNull();
        _putStoredFile(table, values, stored);
        final oldPath = old?.read<String>('encrypted_path');
        if (oldPath != null) filesToDelete.add(oldPath);
      }
    }

    // Column names from the other phone go into SQL text: keep only real ones.
    final known = _guard.knownColumns(table, values);
    if (known.isEmpty) return SyncApplyOutcome.nothing;
    final setClause = known.keys.map((k) => '$k = ?').join(', ');

    await _db.customUpdate(
      'UPDATE $table SET $setClause WHERE id = ?',
      variables: [
        ...known.values.map((v) => Variable(v)),
        Variable.withInt(localId),
      ],
      updates: {},
    );
    return SyncApplyOutcome.applied;
  }

  /// Deletes row [localId] of [table] the way the app does: an entry with its
  /// attachments, a journal with its entries, a tag with its links. Files
  /// are added to [filesToDelete], not deleted.
  Future<SyncApplyOutcome> delete(
    String table,
    int localId,
    List<String> filesToDelete,
  ) async {
    if (!_guard.isSyncable(table)) return SyncApplyOutcome.nothing;
    final exists = await _db
        .customSelect(
          'SELECT id FROM $table WHERE id = ?',
          variables: [Variable.withInt(localId)],
        )
        .getSingleOrNull();
    if (exists == null) return SyncApplyOutcome.nothing;

    // Files are deleted by the caller after commit, never here.
    final deletion = EntryDeletionService(
      db: _db,
      deleteStoredFile: (_) async {},
    );
    switch (table) {
      case 'journals':
        filesToDelete.addAll(await deletion.deleteJournalRows(localId));
      case 'entries':
        filesToDelete.addAll(await deletion.deleteEntryRows(localId));
      case 'tags':
        await _db.tagsDao.deleteTagWithLinks(localId);
      case 'attachments' || 'voice_notes':
        final row = await _db
            .customSelect(
              'SELECT encrypted_path FROM $table WHERE id = ?',
              variables: [Variable.withInt(localId)],
            )
            .getSingle();
        filesToDelete.add(row.read<String>('encrypted_path'));
        await _deleteRow(table, localId);
      default:
        await _deleteRow(table, localId);
    }
    return SyncApplyOutcome.applied;
  }

  /// Rewrites the other phone's row IDs in the text of row [localId] of
  /// [table] (an entry or a revision) into this phone's IDs. [refs] is the
  /// record's `_textRefs`: per table, the other phone's row ID → sync ID. A
  /// target that has not arrived keeps its number.
  Future<void> rewriteTextIds(
    String table,
    int localId,
    Map<String, dynamic> refs,
  ) async {
    if (!syncTextTables.contains(table)) return;
    final idMaps = <String, Map<int, int>>{};
    for (final entry in refs.entries) {
      final ids = entry.value;
      if (ids is! Map) continue;
      for (final pair in ids.entries) {
        final remoteId = int.tryParse('${pair.key}');
        final syncId = pair.value;
        if (remoteId == null || syncId is! String) continue;
        final id = await _resolver.localIdOf(syncId, entry.key);
        if (id != null) (idMaps[entry.key] ??= {})[remoteId] = id;
      }
    }
    if (idMaps.isEmpty) return;

    final row = await _db
        .customSelect(
          'SELECT content_json, plain_text FROM $table WHERE id = ?',
          variables: [Variable.withInt(localId)],
        )
        .getSingleOrNull();
    if (row == null) return;
    final content = row.read<String?>('content_json');
    final plain = row.read<String?>('plain_text');
    final newContent = rewriteContentJson(content, idMaps);
    final newPlain = rewriteWikiLinks(plain, idMaps);
    if (newContent == content && newPlain == plain) return;

    await _db.customUpdate(
      'UPDATE $table SET content_json = ?, plain_text = ? WHERE id = ?',
      variables: [
        Variable(newContent),
        Variable(newPlain),
        Variable.withInt(localId),
      ],
      updates: {},
    );
  }

  /// Stores the file bytes sent with a record under this phone's key, or
  /// returns null when there are none or no cipher.
  Future<BackupStoredFile?> storeFile(Map<String, dynamic> data) async {
    final cipher = _cipher;
    final encoded = data[syncFileKey];
    if (cipher == null || encoded is! String) return null;
    final fileName = data['file_name'];
    return cipher.encryptFromBytes(
      bytes: base64Decode(encoded),
      fileName: fileName is String ? fileName : 'attachment.bin',
    );
  }

  Future<void> _deleteRow(String table, int localId) => _db.customUpdate(
    'DELETE FROM $table WHERE id = ?',
    variables: [Variable.withInt(localId)],
    updates: {},
  );

  void _putStoredFile(
    String table,
    Map<String, dynamic> values,
    BackupStoredFile stored,
  ) {
    values['encrypted_path'] = stored.encryptedPath;
    values['nonce_base64'] = stored.nonceBase64;
    values['key_reference'] = stored.keyReference;
    if (table == 'attachments') values['size_bytes'] = stored.sizeBytes;
  }
}

/// A stored file as kept in conflict data, and back.
Map<String, dynamic> storedFileToJson(BackupStoredFile f) => {
  'encrypted_path': f.encryptedPath,
  'nonce_base64': f.nonceBase64,
  'key_reference': f.keyReference,
  'size_bytes': f.sizeBytes,
};

/// Reads a stored file from conflict data, or null when [json] is not one.
BackupStoredFile? storedFileFromJson(Object? json) {
  if (json is! Map) return null;
  final path = json['encrypted_path'];
  final nonce = json['nonce_base64'];
  final key = json['key_reference'];
  final size = json['size_bytes'];
  if (path is! String || nonce is! String || key is! String || size is! int) {
    return null;
  }
  return BackupStoredFile(
    encryptedPath: path,
    nonceBase64: nonce,
    keyReference: key,
    sizeBytes: size,
  );
}

/// The files stored for the other phone's version of every open sync
/// conflict. The startup orphan sweep counts them as in use.
Future<List<String>> conflictStoredFilePaths(AppDatabase db) async {
  final paths = <String>[];
  for (final conflict in await db.syncConflictsDao.getPendingConflicts()) {
    try {
      final data = jsonDecode(conflict.remoteDataJson);
      if (data is! Map) continue;
      final file = storedFileFromJson(data[syncConflictFileKey]);
      if (file != null) paths.add(file.encryptedPath);
    } catch (_) {
      // An older conflict whose data is still sealed holds no stored file.
    }
  }
  return paths;
}
