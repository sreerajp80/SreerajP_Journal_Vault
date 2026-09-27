import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/journals/services/journal_service.dart';

void main() {
  late AppDatabase db;
  late JournalService service;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = JournalService(db);
  });

  tearDown(() => db.close());

  Future<List<String>> tagNames(int journalId) async => [
    for (final t in await db.journalTagsDao.getTagsForJournal(journalId))
      t.name,
  ]..sort();

  test(
    'createJournal stores title, empty description as none, and tags',
    () async {
      final id = await service.createJournal(
        title: 'Travel',
        description: '',
        tagsText: ' Trips, family ,,trips',
      );

      final journal = await db.journalsDao.getJournalById(id);
      expect(journal.title, 'Travel');
      expect(journal.description, isNull);
      expect(await tagNames(id), ['family', 'trips']);
    },
  );

  test('updateJournal changes fields and only the tag difference', () async {
    final id = await service.createJournal(
      title: 'Old',
      description: 'd',
      tagsText: 'a, b',
    );
    final tagB = (await db.journalTagsDao.getTagsForJournal(
      id,
    )).firstWhere((t) => t.name == 'b');

    await service.updateJournal(
      id,
      title: 'New',
      description: 'desc',
      tagsText: 'b, c',
    );

    final journal = await db.journalsDao.getJournalById(id);
    expect(journal.title, 'New');
    expect(journal.description, 'desc');
    expect(await tagNames(id), ['b', 'c']);
    // Unlinking never deletes the tag itself.
    expect((await db.tagsDao.getAllTags()).map((t) => t.name), contains('a'));
    // The kept tag is the same row.
    expect(
      (await db.journalTagsDao.getTagsForJournal(
        id,
      )).firstWhere((t) => t.name == 'b').id,
      tagB.id,
    );
  });

  test('lockJournal stores the credential', () async {
    final id = await service.createJournal(
      title: 'Private',
      description: '',
      tagsText: '',
    );

    await service.lockJournal(
      id,
      const JournalCredential(
        credentialReference: 'ref',
        passwordSaltBase64: 'salt',
        passwordVerifierBase64: 'verifier',
        passwordIterations: 1000,
      ),
    );

    final journal = await db.journalsDao.getJournalById(id);
    expect(journal.isLocked, isTrue);
    expect(journal.credentialReference, 'ref');
    expect(journal.passwordIterations, 1000);
  });

  test('journalSummaries counts entries and uses the newest change', () async {
    final withEntries = await service.createJournal(
      title: 'A',
      description: '',
      tagsText: 'x',
    );
    final empty = await service.createJournal(
      title: 'B',
      description: '',
      tagsText: '',
    );
    final newest = DateTime(2030, 1, 2);
    await db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: withEntries,
        updatedAt: Value(DateTime(2029, 5, 5)),
      ),
    );
    await db.entriesDao.createEntry(
      EntriesCompanion.insert(journalId: withEntries, updatedAt: Value(newest)),
    );

    final summaries = await service.journalSummaries();
    final a = summaries.firstWhere((s) => s.journal.id == withEntries);
    final b = summaries.firstWhere((s) => s.journal.id == empty);

    expect(a.entryCount, 2);
    expect(a.lastUpdatedAt, newest);
    expect(a.tags.map((t) => t.name), ['x']);
    expect(b.entryCount, 0);
    expect(b.lastUpdatedAt, b.journal.updatedAt);
  });
}
