import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlinks.dart';

void main() {
  group('AppDatabase CRUD smoke tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forExecutor(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('journals create, read, update, delete', () async {
      final createdId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(
          title: 'Work',
          description: const Value('Daily work notes'),
        ),
      );

      final journalsAfterCreate = await database.journalsDao.getAllJournals();
      expect(journalsAfterCreate.length, 1);
      expect(journalsAfterCreate.single.id, createdId);
      expect(journalsAfterCreate.single.title, 'Work');

      await database.journalsDao.updateJournalById(
        createdId,
        JournalsCompanion(
          title: const Value('Work Updated'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final journalsAfterUpdate = await database.journalsDao.getAllJournals();
      expect(journalsAfterUpdate.single.title, 'Work Updated');

      await database.journalsDao.deleteJournalById(createdId);
      final journalsAfterDelete = await database.journalsDao.getAllJournals();
      expect(journalsAfterDelete, isEmpty);
    });

    test('entries create, read, update, delete', () async {
      final journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Travel'),
      );

      final createdEntryId = await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: const Value('Day 1'),
          contentJson: const Value('{"ops":[]}'),
          plainText: const Value('Landing and first impressions'),
        ),
      );

      final entriesAfterCreate = await database.entriesDao.getEntriesForJournal(
        journalId,
      );
      expect(entriesAfterCreate.length, 1);
      expect(entriesAfterCreate.single.id, createdEntryId);
      expect(entriesAfterCreate.single.title, 'Day 1');

      await database.entriesDao.updateEntryById(
        createdEntryId,
        EntriesCompanion(
          title: const Value('Day 1 Updated'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final entriesAfterUpdate = await database.entriesDao.getEntriesForJournal(
        journalId,
      );
      expect(entriesAfterUpdate.single.title, 'Day 1 Updated');

      await database.entriesDao.deleteEntryById(createdEntryId);
      final entriesAfterDelete = await database.entriesDao.getEntriesForJournal(
        journalId,
      );
      expect(entriesAfterDelete, isEmpty);
    });

    test('backlinks persist and update by target type and id', () async {
      final sourceJournalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Travel'),
      );
      final targetJournalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Ideas'),
      );
      final sourceEntryId = await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: sourceJournalId,
          title: const Value('Trip plan'),
          contentJson: const Value('[{"insert":"Trip plan\\n"}]'),
          plainText: const Value('Trip plan'),
        ),
      );
      final targetEntryId = await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: targetJournalId,
          title: const Value('Idea seed'),
          contentJson: const Value('[{"insert":"Idea seed\\n"}]'),
          plainText: const Value('Idea seed'),
        ),
      );

      await database.backlinksDao.replaceBacklinksForEntry(sourceEntryId, [
        VaultBacklinkTarget(
          type: VaultBacklinkTargetType.journal,
          targetId: targetJournalId,
        ),
        VaultBacklinkTarget(
          type: VaultBacklinkTargetType.entry,
          targetId: targetEntryId,
        ),
      ]);

      final journalBacklinks = await database.backlinksDao
          .watchBacklinksForJournalTarget(targetJournalId)
          .first;
      final entryBacklinks = await database.backlinksDao
          .watchBacklinksForEntryTarget(targetEntryId)
          .first;
      expect(journalBacklinks, hasLength(1));
      expect(journalBacklinks.single.sourceEntryId, sourceEntryId);
      expect(entryBacklinks, hasLength(1));
      expect(entryBacklinks.single.sourceEntryId, sourceEntryId);

      await database.backlinksDao.replaceBacklinksForEntry(sourceEntryId, [
        VaultBacklinkTarget(
          type: VaultBacklinkTargetType.entry,
          targetId: targetEntryId,
        ),
      ]);

      expect(
        await database.backlinksDao
            .watchBacklinksForJournalTarget(targetJournalId)
            .first,
        isEmpty,
      );
      expect(
        await database.backlinksDao
            .watchBacklinksForEntryTarget(targetEntryId)
            .first,
        hasLength(1),
      );

      await database.entriesDao.deleteEntryById(sourceEntryId);
      expect(
        await database.backlinksDao
            .watchBacklinksForEntryTarget(targetEntryId)
            .first,
        isEmpty,
      );
    });

    test('tags create, read, update, delete', () async {
      final createdTagId = await database.tagsDao.createTag(
        TagsCompanion.insert(name: 'important'),
      );

      final tagsAfterCreate = await database.tagsDao.getAllTags();
      expect(tagsAfterCreate.length, 1);
      expect(tagsAfterCreate.single.id, createdTagId);
      expect(tagsAfterCreate.single.name, 'important');

      await database.tagsDao.updateTagById(
        createdTagId,
        const TagsCompanion(name: Value('urgent')),
      );

      final tagsAfterUpdate = await database.tagsDao.getAllTags();
      expect(tagsAfterUpdate.single.name, 'urgent');

      await database.tagsDao.deleteTagById(createdTagId);
      final tagsAfterDelete = await database.tagsDao.getAllTags();
      expect(tagsAfterDelete, isEmpty);
    });

    test(
      'app settings include attachment storage migration defaults',
      () async {
        final settings = await database.appSettingsDao.getSettings();

        expect(settings.attachmentStorageLocation, 'app_private');
        expect(settings.attachmentStorageTreeUri, isNull);
        expect(settings.attachmentMigrationStatus, 'idle');
        expect(settings.attachmentMigrationProcessedCount, 0);
        expect(settings.attachmentMigrationTotalCount, 0);
      },
    );

    test('search presets persist and update by name', () async {
      await database.searchPresetsDao.createPreset(
        SearchPresetsCompanion.insert(
          name: 'Travel notes',
          query: 'travel',
          resultType: const Value('entries'),
        ),
      );

      final initialPresets = await database.searchPresetsDao.getAllPresets();
      expect(initialPresets, hasLength(1));
      expect(initialPresets.single.name, 'Travel notes');
      expect(initialPresets.single.query, 'travel');
      expect(initialPresets.single.resultType, 'entries');

      await database.searchPresetsDao.updatePresetById(
        initialPresets.single.id,
        SearchPresetsCompanion(
          query: const Value('passport'),
          resultType: const Value('all'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updatedPresets = await database.searchPresetsDao.getAllPresets();
      expect(updatedPresets, hasLength(1));
      expect(updatedPresets.single.query, 'passport');
      expect(updatedPresets.single.resultType, 'all');
    });
  });
}
