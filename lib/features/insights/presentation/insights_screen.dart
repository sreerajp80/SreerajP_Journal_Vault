import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/insights/providers/insights_providers.dart';
import 'package:sreerajp_journal_vault/features/insights/services/insights_service.dart';

/// Main insights dashboard showing mood trends, streaks, tag heatmap,
/// memories, and weekly reflection.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _StreakCard(),
          SizedBox(height: 16),
          _MoodTrendsCard(),
          SizedBox(height: 16),
          _TagHeatmapCard(),
          SizedBox(height: 16),
          _MemoriesCard(),
          SizedBox(height: 16),
          _WeeklyReflectionCard(),
        ],
      ),
    );
  }
}

// ──────────────── Streak Card ────────────────

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakInfoProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: streakAsync.when(
          data: (streak) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Writing Streak',
                      style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _streakStat(
                    'Current',
                    '${streak.currentStreak}',
                    'days',
                    theme,
                  ),
                  _streakStat(
                    'Longest',
                    '${streak.longestStreak}',
                    'days',
                    theme,
                  ),
                ],
              ),
              if (streak.lastEntryDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last entry: ${_formatDate(streak.lastEntryDate!)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ],
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }

  Widget _streakStat(
      String label, String value, String unit, ThemeData theme) {
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text('$label ($unit)', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

// ──────────────── Mood Trends Card ────────────────

class _MoodTrendsCard extends ConsumerWidget {
  const _MoodTrendsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(defaultMoodTrendsProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Mood Trends (30 days)',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            trendsAsync.when(
              data: (trends) {
                if (trends.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No mood data yet.\nRate your mood on entries to see trends.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return _MoodChart(data: trends);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple bar-style mood visualization.
class _MoodChart extends StatelessWidget {
  const _MoodChart({required this.data});

  final List<MoodDataPoint> data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((point) {
          final height = (point.averageMood / 5.0) * 100;
          return Expanded(
            child: Tooltip(
              message:
                  '${_formatDate(point.date)}\nMood: ${point.averageMood.toStringAsFixed(1)}\nEntries: ${point.entryCount}',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: height,
                decoration: BoxDecoration(
                  color: _moodColor(point.averageMood),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _moodColor(double mood) {
    if (mood >= 4) return Colors.green;
    if (mood >= 3) return Colors.lightGreen;
    if (mood >= 2) return Colors.orange;
    return Colors.red;
  }
}

// ──────────────── Tag Heatmap Card ────────────────

class _TagHeatmapCard extends ConsumerWidget {
  const _TagHeatmapCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(tagHeatmapProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view, color: Colors.teal),
                const SizedBox(width: 8),
                Text('Tag Heatmap',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            heatmapAsync.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No tags used yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                final maxCount =
                    tags.map((t) => t.count).reduce((a, b) => a > b ? a : b);
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    final intensity = tag.count / maxCount;
                    return Chip(
                      label: Text('${tag.tagName} (${tag.count})'),
                      backgroundColor: Colors.teal
                          .withValues(alpha: 0.1 + (intensity * 0.6)),
                      labelStyle: TextStyle(
                        fontWeight: intensity > 0.5
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────── Memories Card ────────────────

class _MemoriesCard extends ConsumerWidget {
  const _MemoriesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber),
                const SizedBox(width: 8),
                Text('On This Day', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            memoriesAsync.when(
              data: (memories) {
                if (memories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No memories for today.\nKeep journaling to build memories!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Column(
                  children: memories
                      .map((m) => _MemoryTile(memory: m))
                      .toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.memory});

  final MemoryEntry memory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.amber.withValues(alpha: 0.2),
        child: Text(
          '${memory.yearsAgo}y',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        memory.title ?? 'Untitled',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: memory.snippet != null
          ? Text(
              memory.snippet!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            )
          : null,
    );
  }
}

// ──────────────── Weekly Reflection Card ────────────────

class _WeeklyReflectionCard extends ConsumerWidget {
  const _WeeklyReflectionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflectionAsync = ref.watch(weeklyReflectionProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories, color: Colors.indigo),
                const SizedBox(width: 8),
                Text('Weekly Reflection',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            reflectionAsync.when(
              data: (reflection) => Column(
                children: [
                  _reflectionRow(
                    'Period',
                    '${_formatDate(reflection.weekStart)} – ${_formatDate(reflection.weekEnd)}',
                    theme,
                  ),
                  _reflectionRow(
                    'Entries',
                    '${reflection.totalEntries}',
                    theme,
                  ),
                  _reflectionRow(
                    'Words Written',
                    '${reflection.totalWordCount}',
                    theme,
                  ),
                  if (reflection.averageMood != null)
                    _reflectionRow(
                      'Average Mood',
                      '${reflection.averageMood!.toStringAsFixed(1)} / 5',
                      theme,
                    ),
                  if (reflection.topTags.isNotEmpty)
                    _reflectionRow(
                      'Top Tags',
                      reflection.topTags.join(', '),
                      theme,
                    ),
                  _reflectionRow(
                    'Current Streak',
                    '${reflection.streakInfo.currentStreak} days',
                    theme,
                  ),
                ],
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reflectionRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────── Helpers ────────────────

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
