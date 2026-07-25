import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/insights/services/insights_service.dart';

// ──────────────── Service ────────────────

final insightsServiceProvider = Provider<InsightsService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return InsightsService(database: db);
});

// ──────────────── Mood ────────────────

final entryMoodProvider =
    StreamProvider.family<EntryMood?, int>((ref, entryId) {
  final service = ref.read(insightsServiceProvider);
  return service.watchMoodForEntry(entryId);
});

/// Mood trends for the last 30 days by default.
final moodTrendsProvider =
    FutureProvider.family<List<MoodDataPoint>, ({DateTime from, DateTime to})>(
        (ref, range) async {
  final service = ref.read(insightsServiceProvider);
  return service.getMoodTrends(from: range.from, to: range.to);
});

final defaultMoodTrendsProvider =
    FutureProvider<List<MoodDataPoint>>((ref) async {
  final service = ref.read(insightsServiceProvider);
  final now = DateTime.now();
  return service.getMoodTrends(
    from: now.subtract(const Duration(days: 30)),
    to: now,
  );
});

// ──────────────── Streaks ────────────────

final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  final service = ref.read(insightsServiceProvider);
  return service.getStreakInfo();
});

// ──────────────── Tag Heatmap ────────────────

final tagHeatmapProvider =
    FutureProvider<List<TagFrequency>>((ref) async {
  final service = ref.read(insightsServiceProvider);
  return service.getTagHeatmap();
});

// ──────────────── Memories ────────────────

final memoriesProvider =
    FutureProvider<List<MemoryEntry>>((ref) async {
  final service = ref.read(insightsServiceProvider);
  return service.getMemories();
});

final memoriesForDateProvider =
    FutureProvider.family<List<MemoryEntry>, DateTime>(
        (ref, date) async {
  final service = ref.read(insightsServiceProvider);
  return service.getMemories(date: date);
});

// ──────────────── Weekly Reflection ────────────────

final weeklyReflectionProvider =
    FutureProvider<WeeklyReflection>((ref) async {
  final service = ref.read(insightsServiceProvider);
  return service.generateWeeklyReflection();
});

final weeklyReflectionForDateProvider =
    FutureProvider.family<WeeklyReflection, DateTime>(
        (ref, weekStart) async {
  final service = ref.read(insightsServiceProvider);
  return service.generateWeeklyReflection(weekStart: weekStart);
});
