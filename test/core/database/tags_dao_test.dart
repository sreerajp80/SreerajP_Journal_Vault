import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('setTagColor', () {
    test('stores and clears a colour', () async {
      final id = await db.tagsDao.getOrCreateTag('work');

      await db.tagsDao.setTagColor(id, 0xFF4A7FD4);
      var tag = (await db.tagsDao.getAllTags()).single;
      expect(tag.colorArgb, 0xFF4A7FD4);

      await db.tagsDao.setTagColor(id, null);
      tag = (await db.tagsDao.getAllTags()).single;
      expect(tag.colorArgb, isNull);
    });
  });

  group('renameTag', () {
    test('renames and normalises the new name', () async {
      final id = await db.tagsDao.getOrCreateTag('work');

      expect(await db.tagsDao.renameTag(id, '  Day Job '), isTrue);

      expect((await db.tagsDao.getAllTags()).single.name, 'day job');
    });

    test('refuses an empty name', () async {
      final id = await db.tagsDao.getOrCreateTag('work');

      expect(await db.tagsDao.renameTag(id, '   '), isFalse);

      expect((await db.tagsDao.getAllTags()).single.name, 'work');
    });

    test('refuses a name another tag already uses', () async {
      final work = await db.tagsDao.getOrCreateTag('work');
      await db.tagsDao.getOrCreateTag('health');

      expect(await db.tagsDao.renameTag(work, 'health'), isFalse);

      final names = (await db.tagsDao.getAllTags()).map((t) => t.name);
      expect(names, containsAll(['work', 'health']));
    });

    test('allows renaming a tag to its own name', () async {
      final id = await db.tagsDao.getOrCreateTag('work');

      expect(await db.tagsDao.renameTag(id, 'Work'), isTrue);
    });
  });

  group('deleteTagWithLinks', () {
    test('removes the tag and every link to it', () async {
      final journalId = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Diary'),
      );
      final entryId = await db.entriesDao.createEntry(
        EntriesCompanion.insert(journalId: journalId),
      );
      final tagId = await db.tagsDao.getOrCreateTag('work');

      await db.journalTagsDao.addTagToJournal(journalId, tagId);
      await db.tagsDao.addTagToEntry(entryId, tagId);

      await db.tagsDao.deleteTagWithLinks(tagId);

      expect(await db.tagsDao.getAllTags(), isEmpty);
      expect(await db.journalTagsDao.getTagsForJournal(journalId), isEmpty);
      expect(await db.tagsDao.getTagsForEntry(entryId), isEmpty);
      expect(await db.select(db.journalTags).get(), isEmpty);
      expect(await db.select(db.entryTags).get(), isEmpty);
    });

    test('leaves other tags alone', () async {
      final keep = await db.tagsDao.getOrCreateTag('health');
      final drop = await db.tagsDao.getOrCreateTag('work');

      await db.tagsDao.deleteTagWithLinks(drop);

      expect((await db.tagsDao.getAllTags()).single.id, keep);
    });
  });
}
