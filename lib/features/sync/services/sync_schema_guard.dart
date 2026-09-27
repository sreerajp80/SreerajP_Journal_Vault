// Layer: service. Checks table and column names that arrive from the other
// phone before they are put into SQL text. Knows nothing about widgets.

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Decides which remote table and column names sync may use.
///
/// Sync builds `INSERT`, `UPDATE` and `SELECT` statements whose table and
/// column names come from the other phone. Values are always bound as `?`
/// variables, but names cannot be. So every name is checked here against this
/// app's own schema, never against the remote data:
///
/// - a table must be one of [syncableTables];
/// - a column must be a real column of that table, as Drift knows it.
class SyncSchemaGuard {
  SyncSchemaGuard(this._db, {required this.syncableTables});

  final AppDatabase _db;

  /// The only tables sync may read or write.
  final List<String> syncableTables;

  /// True when [table] is one sync may touch.
  bool isSyncable(String table) => syncableTables.contains(table);

  /// The entries of [data] whose key is a real column of [table].
  ///
  /// Unknown keys are dropped, so a record from a newer app version that has
  /// an extra column still applies the columns this app knows. Returns an
  /// empty map when [table] is not syncable.
  Map<String, dynamic> knownColumns(String table, Map<String, dynamic> data) {
    if (!isSyncable(table)) return const {};
    final columns = _columnsOf(table);
    return {
      for (final entry in data.entries)
        if (columns.contains(entry.key)) entry.key: entry.value,
    };
  }

  Set<String> _columnsOf(String table) {
    for (final info in _db.allTables) {
      if (info.actualTableName == table) {
        return {for (final column in info.$columns) column.name};
      }
    }
    return const {};
  }
}
