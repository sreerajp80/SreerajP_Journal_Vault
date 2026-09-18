import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/insights/providers/insights_providers.dart';
import 'package:sreerajp_journal_vault/features/insights/services/insights_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'insights_memory_cards.dart';

/// Main insights dashboard showing mood trends, streaks, tag heatmap,
/// memories, and weekly reflection.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).titleInsights)),
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
    final l10n = AppLocalizations.of(context);
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
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    l10n.titleInsightsStreak,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _streakStat(
                    l10n,
                    l10n.labelInsightsStreakCurrent,
                    '${streak.currentStreak}',
                    theme,
                  ),
                  _streakStat(
                    l10n,
                    l10n.labelInsightsStreakLongest,
                    '${streak.longestStreak}',
                    theme,
                  ),
                ],
              ),
              if (streak.lastEntryDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.labelInsightsLastEntry(
                    _formatDate(streak.lastEntryDate!),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(l10n.errorCommon(e.toString())),
        ),
      ),
    );
  }

  Widget _streakStat(
    AppLocalizations l10n,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          l10n.labelInsightsStreakStat(label, l10n.labelInsightsStreakUnitDays),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ──────────────── Mood Trends Card ────────────────

class _MoodTrendsCard extends ConsumerWidget {
  const _MoodTrendsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
                Text(
                  l10n.titleInsightsMood,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            trendsAsync.when(
              data: (trends) {
                if (trends.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        l10n.emptyInsightsMood,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return _MoodChart(data: trends);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.errorCommon(e.toString())),
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
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((point) {
          final height = (point.averageMood / 5.0) * 100;
          return Expanded(
            child: Tooltip(
              message: l10n.descInsightsMood(
                _formatDate(point.date),
                point.averageMood.toStringAsFixed(1),
                point.entryCount,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: height,
                decoration: BoxDecoration(
                  color: _moodColor(point.averageMood),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
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
    final l10n = AppLocalizations.of(context);
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
                Text(
                  l10n.titleInsightsTagHeatmap,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            heatmapAsync.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        l10n.emptyInsightsTagHeatmap,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                final maxCount = tags
                    .map((t) => t.count)
                    .reduce((a, b) => a > b ? a : b);
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    final intensity = tag.count / maxCount;
                    return Chip(
                      label: Text(
                        l10n.labelInsightsTag(tag.tagName, tag.count),
                      ),
                      backgroundColor: Colors.teal.withValues(
                        alpha: 0.1 + (intensity * 0.6),
                      ),
                      labelStyle: TextStyle(
                        fontWeight: intensity > 0.5
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.errorCommon(e.toString())),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────── Memories Card ────────────────
