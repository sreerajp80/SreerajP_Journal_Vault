import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden before use.',
  );
});

final homeJournalsProvider = FutureProvider<List<JournalListItem>>((ref) async {
  final database = ref.read(appDatabaseProvider);
  final journals = await database.journalsDao.getAllJournals();
  return journals
      .map((j) => JournalListItem(journal: j, tags: const []))
      .toList();
});

/// All tags in the database, for tag management screens.
final allTagsProvider = FutureProvider<List<Tag>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.tagsDao.getAllTags();
});

/// Tags assigned to a specific entry.
final entryTagsProvider = FutureProvider.family<List<Tag>, int>((ref, entryId) {
  final db = ref.read(appDatabaseProvider);
  return db.tagsDao.getTagsForEntry(entryId);
});

/// All user-created templates in the database.
final allUserTemplatesProvider = FutureProvider<List<UserTemplate>>((
  ref,
) async {
  final db = ref.read(appDatabaseProvider);
  return db.userTemplatesDao.getAllUserTemplates();
});

/// Stream of all user-created templates for live UI updates.
final userTemplatesStreamProvider = StreamProvider<List<UserTemplate>>((ref) {
  final db = ref.read(appDatabaseProvider);
  return db.userTemplatesDao.watchAllUserTemplates();
});

class JournalListItem {
  const JournalListItem({required this.journal, required this.tags});

  final Journal journal;
  final List<Tag> tags;
}
