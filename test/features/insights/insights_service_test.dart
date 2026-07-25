import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/insights/services/insights_service.dart';

/// Slice E backfill for streak / tag heatmap / memories.
/// Mood aggregation lives in `mood_persistence_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late InsightsService service;
  late int journalId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = InsightsService(database: db);
    journalId = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> createEntry({
    String? title,
    DateTime? entryDate,
    String? plainText,
  }) {
    return db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: Value(title),
        contentJson: const Value('[]'),
        plainText: Value(plainText),
        entryDate: Value(entryDate),
      ),
    );
  }

  // ──────────────── Streaks ────────────────

  group('getStreakInfo', () {
    test('zeros + null when no entries exist', () async {
      final info = await service.getStreakInfo();
      expect(info.currentStreak, 0);
      expect(info.longestStreak, 0);
      expect(info.lastEntryDate, isNull);
    });

    test('returns currentStreak=1 for a single entry today', () async {
      final today = DateTime.now();
      await createEntry(entryDate: DateTime(today.year, today.month, today.day));

      final info = await service.getStreakInfo();
      expect(info.currentStreak, 1);
      expect(info.longestStreak, 1);
      expect(info.lastEntryDate, isNotNull);
    });

    test('extends current streak across consecutive days', () async {
      final today = DateTime.now();
      final t = DateTime(today.year, today.month, today.day);
      for (var i = 0; i < 4; i++) {
        await createEntry(entryDate: t.subtract(Duration(days: i)));
      }

      final info = await service.getStreakInfo();
      expect(info.currentStreak, 4);
      expect(info.longestStreak, greaterThanOrEqualTo(4));
    });

    test('breaks current streak when a day is missing', () async {
      final today = DateTime.now();
      final t = DateTime(today.year, today.month, today.day);
      await createEntry(entryDate: t);
      await createEntry(entryDate: t.subtract(const Duration(days: 1)));
      // Skip day 2.
      await createEntry(entryDate: t.subtract(const Duration(days: 3)));

      final info = await service.getStreakInfo();
      expect(info.currentStreak, 2);
      expect(info.longestStreak, 2);
    });

    test('current streak is 0 when most recent entry is older than yesterday',
        () async {
      final today = DateTime.now();
      final t = DateTime(today.year, today.month, today.day);
      await createEntry(entryDate: t.subtract(const Duration(days: 5)));

      final info = await service.getStreakInfo();
      expect(info.currentStreak, 0);
      expect(info.longestStreak, 1);
    });
  });

  // ──────────────── Tag heatmap ────────────────

  group('getTagHeatmap', () {
    test('returns empty list when no entries are tagged', () async {
      expect(await service.getTagHeatmap(), isEmpty);
    });

    test('counts tag usage and orders most-used first', () async {
      final tagAlpha = await db.tagsDao.getOrCreateTag('alpha');
      final tagBeta = await db.tagsDao.getOrCreateTag('beta');
      final tagGamma = await db.tagsDao.getOrCreateTag('gamma');

      // alpha tagged 3 times, beta 2, gamma 1.
      for (var i = 0; i < 3; i++) {
        final e = await createEntry(title: 'a$i');
        await db.tagsDao.addTagToEntry(e, tagAlpha);
      }
      for (var i = 0; i < 2; i++) {
        final e = await createEntry(title: 'b$i');
        await db.tagsDao.addTagToEntry(e, tagBeta);
      }
      final eGamma = await createEntry(title: 'g');
      await db.tagsDao.addTagToEntry(eGamma, tagGamma);

      final heatmap = await service.getTagHeatmap();
      expect(heatmap.map((t) => t.tagName).toList(),
          ['alpha', 'beta', 'gamma']);
      expect(heatmap.map((t) => t.count).toList(), [3, 2, 1]);
    });

    test('ignores tags that are not attached to any entry', () async {
      await db.tagsDao.getOrCreateTag('orphan');
      final tagId = await db.tagsDao.getOrCreateTag('used');
      final e = await createEntry(title: 't');
      await db.tagsDao.addTagToEntry(e, tagId);

      final heatmap = await service.getTagHeatmap();
      expect(heatmap.map((t) => t.tagName).toList(), ['used']);
    });
  });

  // ──────────────── Memories ────────────────

  group('getMemories', () {
    test('returns prior-year entries that match the target month/day',
        () async {
      // Use a fixed UTC noon date so timezone offsets cannot push the entry
      // into a different day in the SQL strftime() comparison.
      final target = DateTime.utc(2026, 5, 9, 12);
      await createEntry(
        title: 'one year ago',
        entryDate: DateTime.utc(2025, 5, 9, 12),
        plainText: 'a memory',
      );
      await createEntry(
        title: 'two years ago',
        entryDate: DateTime.utc(2024, 5, 9, 12),
        plainText: 'older memory',
      );
      await createEntry(
        title: 'last week, last year',
        entryDate: DateTime.utc(2025, 5, 2, 12),
        plainText: 'unrelated',
      );

      final memories = await service.getMemories(date: target);
      expect(
        memories.map((m) => m.title).toList(),
        ['one year ago', 'two years ago'],
      );
      expect(memories.map((m) => m.yearsAgo).toList(), [1, 2]);
    });

    test('does not include entries from the current year', () async {
      final target = DateTime.utc(2026, 5, 9, 12);
      await createEntry(
        title: 'this year',
        entryDate: DateTime.utc(2026, 5, 9, 12),
      );

      final memories = await service.getMemories(date: target);
      expect(memories, isEmpty);
    });

    test('truncates long snippets to 150 chars + ellipsis', () async {
      final target = DateTime.utc(2026, 5, 9, 12);
      final longText = 'X' * 200;
      await createEntry(
        title: 'long',
        entryDate: DateTime.utc(2025, 5, 9, 12),
        plainText: longText,
      );

      final memory = (await service.getMemories(date: target)).single;
      expect(memory.snippet, endsWith('...'));
      expect(memory.snippet!.length, 153);
    });
  });
}
