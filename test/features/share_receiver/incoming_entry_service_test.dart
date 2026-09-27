import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/incoming_entry_service.dart';

void main() {
  late AppDatabase db;
  late IncomingEntryService service;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = IncomingEntryService(
      db: db,
      importService: () =>
          throw StateError('attachment storage must not be read'),
    );
  });

  tearDown(() => db.close());

  Future<int> journal(String title) =>
      db.journalsDao.createJournal(JournalsCompanion.insert(title: title));

  test('saveSharedEntry with text only stores it as one line', () async {
    final j = await journal('Inbox');

    final id = await service.saveSharedEntry(
      journalId: j,
      title: 'Shared',
      text: 'hello',
      media: const [],
      imageInsert: (_, _) => throw StateError('no pictures here'),
    );

    final entry = await db.entriesDao.getEntryById(id);
    expect(entry.journalId, j);
    expect(entry.title, 'Shared');
    expect(jsonDecode(entry.contentJson!), [
      {'insert': 'hello\n'},
    ]);
  });

  test('saveSharedEntry with no text stores an empty line', () async {
    final id = await service.saveSharedEntry(
      journalId: await journal('Inbox'),
      title: '',
      text: '',
      media: const [],
      imageInsert: (_, _) => throw StateError('no pictures here'),
    );

    final entry = await db.entriesDao.getEntryById(id);
    expect(jsonDecode(entry.contentJson!), [
      {'insert': '\n'},
    ]);
  });

  test(
    'importReceivedEntry goes to the first journal, keeps a valid mood',
    () async {
      final first = await journal('First');
      await journal('Second');

      final id = await service.importReceivedEntry(
        title: 'From QR',
        contentJson: '[]',
        plainText: 'text',
        mood: '4',
        fallbackJournalTitle: 'Imported journal',
      );

      final entry = await db.entriesDao.getEntryById(id);
      expect(entry.journalId, first);
      // Journals exist, so none is made.
      expect(await db.journalsDao.getAllJournals(), hasLength(2));
      expect(entry.plainText, 'text');
      final moods = await db.select(db.entryMoods).get();
      expect(moods.single.mood, 4);
    },
  );

  test('importReceivedEntry drops a mood outside 1 to 5', () async {
    await journal('First');

    await service.importReceivedEntry(
      title: 'T',
      contentJson: '[]',
      plainText: '',
      mood: '9',
      fallbackJournalTitle: 'Imported journal',
    );

    expect(await db.select(db.entryMoods).get(), isEmpty);
  });

  test('importReceivedEntry makes a journal when there is none', () async {
    final id = await service.importReceivedEntry(
      title: 'From QR',
      contentJson: '[]',
      plainText: 'text',
      mood: null,
      fallbackJournalTitle: 'Imported journal',
    );

    final journals = await db.journalsDao.getAllJournals();
    expect(journals.single.title, 'Imported journal');
    final entry = await db.entriesDao.getEntryById(id);
    expect(entry.journalId, journals.single.id);
    expect(entry.title, 'From QR');
  });

  test('importReceivedJournal creates the journal and its entries', () async {
    final id = await service.importReceivedJournal(
      title: 'Trip',
      description: 'd',
      entries: [
        {'title': 'Day 1', 'contentJson': '[]', 'plainText': 'a'},
        {'contentJson': '[]'},
        'not a map',
      ],
      fallbackEntryTitle: 'Untitled',
    );

    final j = await db.journalsDao.getJournalById(id);
    expect(j.title, 'Trip');
    expect(j.description, 'd');
    final entries = await db.entriesDao.getEntriesForJournal(id);
    expect(entries.map((e) => e.title), unorderedEquals(['Day 1', 'Untitled']));
  });
}
