// Layer: service. Full-text search and saved search presets. Knows nothing
// about widgets or UI strings.

import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Searches entries and keeps the user's saved searches.
class SearchService {
  SearchService(this._db);

  final AppDatabase _db;

  /// Entries whose text matches [query], from the full-text index.
  Future<List<FtsSearchResult>> searchEntries(String query) =>
      _db.searchEntries(query);

  /// Every saved search.
  Future<List<SearchPreset>> allPresets() =>
      _db.searchPresetsDao.getAllPresets();

  /// Saves a search. [entriesOnly] stores the "entries" result filter.
  Future<int> createPreset({
    required String name,
    required String query,
    required bool entriesOnly,
  }) => _db.searchPresetsDao.createPreset(
    SearchPresetsCompanion.insert(
      name: name,
      query: query,
      resultType: Value(entriesOnly ? 'entries' : null),
    ),
  );
}
