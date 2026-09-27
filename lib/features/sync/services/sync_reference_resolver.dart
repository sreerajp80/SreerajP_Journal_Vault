// Layer: service. Turns a record received over sync into column values for
// this phone: every reference becomes this phone's own row ID. Knows nothing
// about widgets.

import 'package:drift/drift.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_references.dart';

/// Resolves the references in received records through `sync_metadata`.
class SyncReferenceResolver {
  SyncReferenceResolver(this._db);

  final AppDatabase _db;

  /// The column values of a received [table] record, with each reference
  /// replaced by this phone's row ID.
  ///
  /// Keys starting with `_` (file bytes, text references) and the columns
  /// that describe a file on the other phone are left out. Returns null when
  /// a reference cannot be resolved — its row never arrived, or it is not in
  /// the new `$ref` form — so the record must be skipped, never stored with
  /// a guessed ID.
  Future<Map<String, dynamic>?> localValues(
    String table,
    Map<String, dynamic> data,
  ) async {
    final values = <String, dynamic>{
      for (final entry in data.entries)
        if (!entry.key.startsWith('_') &&
            !syncDeviceFileColumns.contains(entry.key))
          entry.key: entry.value,
    };

    for (final column in (syncReferenceColumns[table] ?? const {}).entries) {
      final localId = await _resolve(values[column.key], column.value);
      if (localId == null) return null;
      values[column.key] = localId;
    }

    if (table == 'backlinks') {
      final targetTable = backlinkTargetTable[values['target_type']];
      if (targetTable == null) return null;
      final localId = await _resolve(values['target_id'], targetTable);
      if (localId == null) return null;
      values['target_id'] = localId;
    }
    return values;
  }

  /// This phone's row ID for the record with [syncId] in [table], or null.
  Future<int?> localIdOf(String syncId, String table) async {
    final meta = await _db.syncMetadataDao.getBySyncId(syncId);
    if (meta == null || meta.recordTable != table) return null;
    return meta.localId;
  }

  /// The ID of the local tag named like [name] (trimmed, lower case), or
  /// null. Tag names are unique in practice; see `TagsDao.getOrCreateTag`.
  Future<int?> localTagIdByName(Object? name) async {
    if (name is! String) return null;
    final rows = await _db
        .customSelect(
          'SELECT id FROM tags WHERE name = ? LIMIT 1',
          variables: [Variable.withString(name.trim().toLowerCase())],
        )
        .get();
    return rows.isEmpty ? null : rows.first.read<int>('id');
  }

  Future<int?> _resolve(Object? value, String table) async {
    final syncId = syncIdOfRef(value);
    if (syncId == null) return null;
    return localIdOf(syncId, table);
  }
}
