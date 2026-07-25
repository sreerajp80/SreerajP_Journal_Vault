import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Data class for mood trend data points.
class MoodDataPoint {
  final DateTime date;
  final double averageMood;
  final int entryCount;

  const MoodDataPoint({
    required this.date,
    required this.averageMood,
    required this.entryCount,
  });
}

/// Data class for writing streak information.
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastEntryDate;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastEntryDate,
  });
}

/// Data class for tag usage frequency (heatmap data).
class TagFrequency {
  final int tagId;
  final String tagName;
  final int count;

  const TagFrequency({
    required this.tagId,
    required this.tagName,
    required this.count,
  });
}

/// A memory: an entry from the same date in a previous year.
class MemoryEntry {
  final int entryId;
  final int journalId;
  final String? title;
  final String? snippet;
  final DateTime entryDate;
  final int yearsAgo;

  const MemoryEntry({
    required this.entryId,
    required this.journalId,
    this.title,
    this.snippet,
    required this.entryDate,
    required this.yearsAgo,
  });
}

/// Weekly reflection summary data.
class WeeklyReflection {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalEntries;
  final double? averageMood;
  final List<String> topTags;
  final int totalWordCount;
  final StreakInfo streakInfo;

  const WeeklyReflection({
    required this.weekStart,
    required this.weekEnd,
    required this.totalEntries,
    this.averageMood,
    required this.topTags,
    required this.totalWordCount,
    required this.streakInfo,
  });
}

/// Service providing journal insights: mood trends, streaks, tag heatmaps,
/// memories, and weekly reflections.
///
/// All calculations are reproducible — they derive from stored entry data
/// and mood ratings. Users can edit mood ratings to correct calculations.
class InsightsService {
  InsightsService({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  // ──────────────── Mood ────────────────

  /// Sets or updates the mood rating for an entry.
  Future<void> setMood({
    required int entryId,
    required int mood,
    String? note,
  }) {
    assert(mood >= 1 && mood <= 5, 'Mood must be between 1 and 5');
    return _db.entryMoodsDao.upsertMood(
      EntryMoodsCompanion.insert(
        entryId: entryId,
        mood: mood,
        note: Value(note),
      ),
    );
  }

  /// Gets the mood for a specific entry.
  Future<EntryMood?> getMoodForEntry(int entryId) =>
      _db.entryMoodsDao.getMoodForEntry(entryId);

  /// Watches mood changes for an entry (reactive UI).
  Stream<EntryMood?> watchMoodForEntry(int entryId) =>
      _db.entryMoodsDao.watchMoodForEntry(entryId);

  /// Deletes the mood rating for an entry.
  Future<void> deleteMood(int entryId) =>
      _db.entryMoodsDao.deleteMoodForEntry(entryId);

  // ──────────────── Mood Trends ────────────────

  /// Returns daily average mood over a date range.
  Future<List<MoodDataPoint>> getMoodTrends({
    required DateTime from,
    required DateTime to,
  }) async {
    final moods = await _db.entryMoodsDao.getAllMoods();
    final entries = await _getAllEntriesInRange(from, to);

    // Map entryId -> entryDate
    final entryDates = <int, DateTime>{};
    for (final e in entries) {
      if (e.entryDate != null) {
        entryDates[e.id] = e.entryDate!;
      }
    }

    // Group moods by date
    final Map<String, List<int>> dailyMoods = {};
    for (final mood in moods) {
      final date = entryDates[mood.entryId];
      if (date == null) continue;
      if (date.isBefore(from) || date.isAfter(to)) continue;
      final key = _dateKey(date);
      dailyMoods.putIfAbsent(key, () => []).add(mood.mood);
    }

    // Compute averages
    final results = <MoodDataPoint>[];
    for (final entry in dailyMoods.entries) {
      final avg =
          entry.value.reduce((a, b) => a + b) / entry.value.length;
      results.add(MoodDataPoint(
        date: DateTime.parse(entry.key),
        averageMood: avg,
        entryCount: entry.value.length,
      ));
    }
    results.sort((a, b) => a.date.compareTo(b.date));
    return results;
  }

  // ──────────────── Streaks ────────────────

  /// Calculates writing streak information.
  Future<StreakInfo> getStreakInfo() async {
    // entry_date is stored as Unix seconds by drift's default DateTime
    // mapping, so feed it directly to unixepoch (no extra divide).
    final rows = await _db.customSelect(
      '''
      SELECT DISTINCT DATE(entry_date, 'unixepoch') AS day
      FROM entries
      WHERE entry_date IS NOT NULL
      ORDER BY day DESC
      ''',
    ).get();

    if (rows.isEmpty) {
      return const StreakInfo(
          currentStreak: 0, longestStreak: 0, lastEntryDate: null);
    }

    final dates = rows
        .map((r) => DateTime.parse(r.read<String>('day')))
        .toList();

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    // Calculate current streak
    int currentStreak = 0;
    DateTime expectedDate = todayKey;

    // Allow current day or yesterday to count
    if (dates.first == todayKey ||
        dates.first ==
            todayKey.subtract(const Duration(days: 1))) {
      expectedDate = dates.first;
      for (final date in dates) {
        if (date == expectedDate) {
          currentStreak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i - 1].difference(dates[i]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        longestStreak =
            tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
    longestStreak =
        currentStreak > longestStreak ? currentStreak : longestStreak;

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastEntryDate: dates.first,
    );
  }

  // ──────────────── Tag Heatmap ────────────────

  /// Returns tag usage frequencies for heatmap visualization.
  Future<List<TagFrequency>> getTagHeatmap() async {
    final results = await _db.customSelect(
      '''
      SELECT t.id AS tag_id, t.name AS tag_name, COUNT(et.id) AS cnt
      FROM tags t
      INNER JOIN entry_tags et ON et.tag_id = t.id
      GROUP BY t.id, t.name
      ORDER BY cnt DESC
      ''',
    ).get();

    return results.map((row) {
      return TagFrequency(
        tagId: row.read<int>('tag_id'),
        tagName: row.read<String>('tag_name'),
        count: row.read<int>('cnt'),
      );
    }).toList();
  }

  // ──────────────── Memories ────────────────

  /// Returns "On This Day" memories — entries from previous years.
  Future<List<MemoryEntry>> getMemories({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final month = targetDate.month.toString().padLeft(2, '0');
    final day = targetDate.day.toString().padLeft(2, '0');

    final results = await _db.customSelect(
      '''
      SELECT id, journal_id, title, plain_text, entry_date
      FROM entries
      WHERE entry_date IS NOT NULL
        AND strftime('%m', entry_date, 'unixepoch') = ?
        AND strftime('%d', entry_date, 'unixepoch') = ?
        AND strftime('%Y', entry_date, 'unixepoch') != ?
      ORDER BY entry_date DESC
      ''',
      variables: [
        Variable.withString(month),
        Variable.withString(day),
        Variable.withString(targetDate.year.toString()),
      ],
    ).get();

    return results.map((row) {
      final entryDate = DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('entry_date') * 1000,
      );
      final plainText = row.readNullable<String>('plain_text');
      return MemoryEntry(
        entryId: row.read<int>('id'),
        journalId: row.read<int>('journal_id'),
        title: row.readNullable<String>('title'),
        snippet: plainText != null && plainText.length > 150
            ? '${plainText.substring(0, 150)}...'
            : plainText,
        entryDate: entryDate,
        yearsAgo: targetDate.year - entryDate.year,
      );
    }).toList();
  }

  // ──────────────── Weekly Reflection ────────────────

  /// Generates a weekly reflection summary for the given week.
  ///
  /// If [weekStart] is null, uses the current week (Monday–Sunday).
  Future<WeeklyReflection> generateWeeklyReflection({
    DateTime? weekStart,
  }) async {
    final now = DateTime.now();
    final start = weekStart ??
        DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));

    // Get entries for the week
    final entries = await _getAllEntriesInRange(start, end);

    // Calculate total word count
    int totalWords = 0;
    for (final entry in entries) {
      if (entry.plainText != null) {
        totalWords += entry.plainText!
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .length;
      }
    }

    // Get moods for the week's entries
    double? avgMood;
    if (entries.isNotEmpty) {
      final moodValues = <int>[];
      for (final entry in entries) {
        final mood = await _db.entryMoodsDao.getMoodForEntry(entry.id);
        if (mood != null) moodValues.add(mood.mood);
      }
      if (moodValues.isNotEmpty) {
        avgMood =
            moodValues.reduce((a, b) => a + b) / moodValues.length;
      }
    }

    // Get top tags for the week
    final entryIds = entries.map((e) => e.id).toList();
    final topTags = await _getTopTagsForEntries(entryIds);

    // Get streak info
    final streakInfo = await getStreakInfo();

    return WeeklyReflection(
      weekStart: start,
      weekEnd: end.subtract(const Duration(seconds: 1)),
      totalEntries: entries.length,
      averageMood: avgMood,
      topTags: topTags,
      totalWordCount: totalWords,
      streakInfo: streakInfo,
    );
  }

  // ──────────────── Helpers ────────────────

  Future<List<Entry>> _getAllEntriesInRange(
      DateTime from, DateTime to) async {
    // entry_date is stored as Unix seconds by drift's default mapping.
    return (await _db.customSelect(
      '''
      SELECT * FROM entries
      WHERE entry_date IS NOT NULL
        AND entry_date >= ?
        AND entry_date < ?
      ORDER BY entry_date ASC
      ''',
      variables: [
        Variable.withInt(from.millisecondsSinceEpoch ~/ 1000),
        Variable.withInt(to.millisecondsSinceEpoch ~/ 1000),
      ],
    ).get())
        .map((row) => Entry(
              id: row.read<int>('id'),
              journalId: row.read<int>('journal_id'),
              title: row.readNullable<String>('title'),
              contentJson: row.readNullable<String>('content_json'),
              plainText: row.readNullable<String>('plain_text'),
              // Drift stores DateTime as Unix seconds, multiply back to ms.
              entryDate: DateTime.fromMillisecondsSinceEpoch(
                  row.read<int>('entry_date') * 1000),
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  row.read<int>('created_at') * 1000),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                  row.read<int>('updated_at') * 1000),
            ))
        .toList();
  }

  Future<List<String>> _getTopTagsForEntries(List<int> entryIds,
      {int limit = 5}) async {
    if (entryIds.isEmpty) return [];
    final placeholders = entryIds.map((_) => '?').join(', ');
    final results = await _db.customSelect(
      '''
      SELECT t.name, COUNT(et.id) AS cnt
      FROM tags t
      INNER JOIN entry_tags et ON et.tag_id = t.id
      WHERE et.entry_id IN ($placeholders)
      GROUP BY t.id, t.name
      ORDER BY cnt DESC
      LIMIT ?
      ''',
      variables: [
        ...entryIds.map((id) => Variable.withInt(id)),
        Variable.withInt(limit),
      ],
    ).get();
    return results.map((r) => r.read<String>('name')).toList();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
