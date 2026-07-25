import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/insights/services/insights_service.dart';

/// D5 verification: setMood + getMoodTrends round-trips through the
/// EntryMoods + Entries tables so the InsightsScreen mood card has data
/// once the user starts rating entries from the editor.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late InsightsService service;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    service = InsightsService(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> createEntry(DateTime when, {required int journalId}) {
    return database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('e'),
        contentJson: const Value('[]'),
        entryDate: Value(when),
      ),
    );
  }

  test('setMood is upsert — setting twice keeps a single row', () async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final entryId = await createEntry(DateTime.now(), journalId: journalId);

    await service.setMood(entryId: entryId, mood: 3);
    await service.setMood(entryId: entryId, mood: 5);

    final mood = await service.getMoodForEntry(entryId);
    expect(mood?.mood, 5);
    final all = await database.entryMoodsDao.getAllMoods();
    expect(all, hasLength(1));
  });

  test('getAllMoods returns one row per entry after multiple setMood calls',
      () async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final e1 = await createEntry(DateTime.now(), journalId: journalId);
    final e2 = await createEntry(DateTime.now(), journalId: journalId);
    await service.setMood(entryId: e1, mood: 2);
    await service.setMood(entryId: e2, mood: 4);

    final moods = await database.entryMoodsDao.getAllMoods();
    expect(moods, hasLength(2));
    expect(moods.map((m) => m.mood).toSet(), {2, 4});
  });

  test('deleteMood removes the mood row', () async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final entryId = await createEntry(DateTime.now(), journalId: journalId);
    await service.setMood(entryId: entryId, mood: 3);
    expect(await service.getMoodForEntry(entryId), isNotNull);

    await service.deleteMood(entryId);
    expect(await service.getMoodForEntry(entryId), isNull);
  });

  test('getMoodTrends returns a data point for entries inside the range',
      () async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final today = DateTime.utc(2026, 5, 9, 12);
    final yesterday = today.subtract(const Duration(days: 1));

    final e1 = await createEntry(yesterday, journalId: journalId);
    final e2 = await createEntry(today, journalId: journalId);
    await service.setMood(entryId: e1, mood: 2);
    await service.setMood(entryId: e2, mood: 4);

    final trends = await service.getMoodTrends(
      from: today.subtract(const Duration(days: 7)),
      to: today.add(const Duration(days: 1)),
    );

    expect(trends, isNotEmpty);
    final values = trends.map((d) => d.averageMood).toSet();
    expect(values, containsAll([2.0, 4.0]));
  });

  test('asserts mood is between 1 and 5', () async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final entryId = await createEntry(DateTime.now(), journalId: journalId);
    expect(
      () => service.setMood(entryId: entryId, mood: 0),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => service.setMood(entryId: entryId, mood: 6),
      throwsA(isA<AssertionError>()),
    );
  });
}
