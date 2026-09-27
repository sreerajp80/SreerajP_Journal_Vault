import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/tags/services/tag_service.dart';

void main() {
  late AppDatabase db;
  late TagService service;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = TagService(db);
  });

  tearDown(() => db.close());

  Future<Tag> tag(int id) async =>
      (await db.tagsDao.getAllTags()).firstWhere((t) => t.id == id);

  test('renameTag renames, and refuses a name another tag has', () async {
    final a = await db.tagsDao.getOrCreateTag('a');
    await db.tagsDao.getOrCreateTag('b');

    expect(await service.renameTag(a, 'Alpha'), isTrue);
    expect((await tag(a)).name, 'alpha');
    expect(await service.renameTag(a, 'b'), isFalse);
  });

  test('setTagColor sets and clears the colour', () async {
    final a = await db.tagsDao.getOrCreateTag('a');

    await service.setTagColor(a, 0xFF112233);
    expect((await tag(a)).colorArgb, 0xFF112233);
    await service.setTagColor(a, null);
    expect((await tag(a)).colorArgb, isNull);
  });

  test(
    'addTagToEntry tags the entry, deleteTag removes tag and links',
    () async {
      final journal = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'J'),
      );
      final entry = await db.entriesDao.createEntry(
        EntriesCompanion.insert(journalId: journal),
      );
      final a = await db.tagsDao.getOrCreateTag('a');

      await service.addTagToEntry(entry, a);
      expect(await db.select(db.entryTags).get(), hasLength(1));

      await service.deleteTag(a);
      expect(await db.tagsDao.getAllTags(), isEmpty);
      expect(await db.select(db.entryTags).get(), isEmpty);
    },
  );
}
