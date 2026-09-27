import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/search/services/search_service.dart';

/// Full-text search and saved search presets.
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(appDatabaseProvider));
});

/// Notifier that holds the current search query.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

/// The current search query entered by the user.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// FTS search results for the current query.
final searchResultsProvider = FutureProvider<List<FtsSearchResult>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final db = ref.read(appDatabaseProvider);
  return db.searchEntries(query);
});
