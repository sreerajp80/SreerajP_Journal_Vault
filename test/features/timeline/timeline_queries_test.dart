import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late int journalId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    journalId = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertEntry(DateTime when, {String? title}) {
    return db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: Value(title ?? 'e'),
        contentJson: const Value('[]'),
        entryDate: Value(when),
      ),
    );
  }

  group('getEntryCountsForMonth', () {
    test('returns empty list when no entries match the month', () async {
      await insertEntry(DateTime.utc(2026, 4, 5, 12));
      final counts = await db.getEntryCountsForMonth(2026, 5);
      expect(counts, isEmpty);
    });

    test('groups entries by day within the month', () async {
      // Day 1: 2 entries
      await insertEntry(DateTime.utc(2026, 5, 1, 9));
      await insertEntry(DateTime.utc(2026, 5, 1, 18));
      // Day 3: 1 entry
      await insertEntry(DateTime.utc(2026, 5, 3, 12));
      // Different month — must NOT appear
      await insertEntry(DateTime.utc(2026, 4, 30, 23));

      final counts = await db.getEntryCountsForMonth(2026, 5);
      final byDay = {for (final c in counts) c.date.day: c.count};
      expect(byDay, {1: 2, 3: 1});
    });

    test('only counts entries with non-null entry_date', () async {
      // No entryDate
      await db.entriesDao.createEntry(EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('untimed'),
        contentJson: const Value('[]'),
      ));
      await insertEntry(DateTime.utc(2026, 5, 9, 12));

      final counts = await db.getEntryCountsForMonth(2026, 5);
      expect(counts, hasLength(1));
      expect(counts.single.count, 1);
    });

    test('returns rows for every day that has at least one entry', () async {
      for (var d = 1; d <= 5; d++) {
        await insertEntry(DateTime.utc(2026, 5, d, 12));
      }
      final counts = await db.getEntryCountsForMonth(2026, 5);
      expect(counts, hasLength(5));
    });
  });

  group('getEntriesForDate', () {
    test('returns the entries created on the given local day', () async {
      final target = DateTime(2026, 5, 9);
      await insertEntry(
        DateTime(target.year, target.month, target.day, 9),
        title: 'morning',
      );
      await insertEntry(
        DateTime(target.year, target.month, target.day, 21),
        title: 'evening',
      );
      await insertEntry(
        DateTime(target.year, target.month, target.day - 1, 12),
        title: 'yesterday',
      );

      final entries = await db.getEntriesForDate(target);
      expect(entries.map((e) => e.title), ['morning', 'evening']);
    });

    test('returns empty list when no entries match the day', () async {
      final entries = await db.getEntriesForDate(DateTime(2026, 5, 9));
      expect(entries, isEmpty);
    });

    test('orders entries within the day ascending by entry_date', () async {
      final target = DateTime(2026, 5, 9);
      await insertEntry(
        DateTime(target.year, target.month, target.day, 22),
        title: 'late',
      );
      await insertEntry(
        DateTime(target.year, target.month, target.day, 6),
        title: 'early',
      );
      await insertEntry(
        DateTime(target.year, target.month, target.day, 14),
        title: 'noon',
      );

      final entries = await db.getEntriesForDate(target);
      expect(entries.map((e) => e.title), ['early', 'noon', 'late']);
    });

    test('uses local-day boundaries (start and end of day are inclusive)',
        () async {
      final target = DateTime(2026, 5, 9);
      // Boundary case: midnight at start of day must be included.
      await insertEntry(
        DateTime(target.year, target.month, target.day),
        title: 'midnight',
      );
      // Just before next day midnight: included.
      await insertEntry(
        DateTime(target.year, target.month, target.day, 23, 59, 59),
        title: 'almost-midnight',
      );
      // Next day midnight: excluded.
      await insertEntry(
        DateTime(target.year, target.month, target.day + 1),
        title: 'next-day',
      );

      final entries = await db.getEntriesForDate(target);
      expect(
        entries.map((e) => e.title),
        ['midnight', 'almost-midnight'],
      );
    });
  });
}
