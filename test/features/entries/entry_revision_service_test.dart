import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_revision_service.dart';

void main() {
  group('EntryRevisionService', () {
    late AppDatabase database;
    late EntryRevisionService service;
    late int journalId;
    late int entryId;

    setUp(() async {
      database = AppDatabase.forExecutor(NativeDatabase.memory());
      service = EntryRevisionService(database);

      journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Test Journal'),
      );
      entryId = await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: const Value('Original Title'),
          contentJson: const Value('[{"insert":"Original content\\n"}]'),
          plainText: const Value('Original content'),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('createRevision snapshots current entry state', () async {
      final entry = await database.entriesDao.getEntryById(entryId);
      final revisionId = await service.createRevision(entry);

      expect(revisionId, isPositive);

      final revisions = await service.getRevisions(entryId);
      expect(revisions, hasLength(1));
      expect(revisions.single.title, 'Original Title');
      expect(revisions.single.contentJson,
          '[{"insert":"Original content\\n"}]');
      expect(revisions.single.plainText, 'Original content');
    });

    test('getRevisions returns all revisions', () async {
      final entry = await database.entriesDao.getEntryById(entryId);
      await service.createRevision(entry);

      // Modify and create another revision.
      await database.entriesDao.updateEntryById(
        entryId,
        const EntriesCompanion(
          title: Value('Updated Title'),
          contentJson: Value('[{"insert":"Updated content\\n"}]'),
          plainText: Value('Updated content'),
        ),
      );
      final updatedEntry = await database.entriesDao.getEntryById(entryId);
      await service.createRevision(updatedEntry);

      final revisions = await service.getRevisions(entryId);
      expect(revisions, hasLength(2));
      final titles = revisions.map((r) => r.title).toSet();
      expect(titles, contains('Original Title'));
      expect(titles, contains('Updated Title'));
    });

    test('restoreRevision overwrites entry with revision content', () async {
      // Snapshot original.
      final entry = await database.entriesDao.getEntryById(entryId);
      await service.createRevision(entry);

      // Modify the entry.
      await database.entriesDao.updateEntryById(
        entryId,
        const EntriesCompanion(
          title: Value('Changed Title'),
          contentJson: Value('[{"insert":"Changed\\n"}]'),
          plainText: Value('Changed'),
        ),
      );

      // Find the original revision.
      final revisions = await service.getRevisions(entryId);
      final originalRevision = revisions.single;

      // Restore the original revision.
      await service.restoreRevision(
        entryId: entryId,
        revisionId: originalRevision.id,
      );

      // Entry should now have original content.
      final restored = await database.entriesDao.getEntryById(entryId);
      expect(restored.title, 'Original Title');
      expect(restored.contentJson, '[{"insert":"Original content\\n"}]');
      expect(restored.plainText, 'Original content');
    });

    test('restoreRevision creates backup of current state first', () async {
      final entry = await database.entriesDao.getEntryById(entryId);
      await service.createRevision(entry);

      // Modify.
      await database.entriesDao.updateEntryById(
        entryId,
        const EntriesCompanion(
          title: Value('Changed Title'),
          plainText: Value('Changed'),
        ),
      );

      final revisions = await service.getRevisions(entryId);
      expect(revisions, hasLength(1));

      // Restore creates a backup first.
      await service.restoreRevision(
        entryId: entryId,
        revisionId: revisions.single.id,
      );

      final afterRestore = await service.getRevisions(entryId);
      // Should have 2 revisions: original snapshot + backup of "Changed" state.
      expect(afterRestore, hasLength(2));
      // One of the revisions should have the backed-up "Changed" title.
      final titles = afterRestore.map((r) => r.title).toList();
      expect(titles, contains('Changed Title'));
      expect(titles, contains('Original Title'));
    });

    test('revisions are cascade-deleted when entry is deleted', () async {
      final entry = await database.entriesDao.getEntryById(entryId);
      await service.createRevision(entry);
      await service.createRevision(entry);

      expect(await service.getRevisions(entryId), hasLength(2));

      await database.entriesDao.deleteEntryById(entryId);

      expect(await service.getRevisions(entryId), isEmpty);
    });
  });
}
