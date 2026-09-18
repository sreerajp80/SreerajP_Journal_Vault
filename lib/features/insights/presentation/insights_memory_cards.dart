part of 'insights_screen.dart';

class _MemoriesCard extends ConsumerWidget {
  const _MemoriesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
                Text(
                  l10n.titleInsightsMemories,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            memoriesAsync.when(
              data: (memories) {
                if (memories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        l10n.emptyInsightsMemories,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.errorCommon(e.toString())),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.amber.withValues(alpha: 0.2),
        child: Text(
          l10n.labelInsightsYearsAgo(memory.yearsAgo),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        memory.title ?? l10n.descCommonUntitled,
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
    final l10n = AppLocalizations.of(context);
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
                Text(
                  l10n.titleInsightsReflection,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            reflectionAsync.when(
              data: (reflection) => Column(
                children: [
                  _reflectionRow(
                    l10n.labelInsightsReflectionPeriod,
                    l10n.labelInsightsDateRange(
                      _formatDate(reflection.weekStart),
                      _formatDate(reflection.weekEnd),
                    ),
                    theme,
                  ),
                  _reflectionRow(
                    l10n.labelInsightsReflectionEntries,
                    '${reflection.totalEntries}',
                    theme,
                  ),
                  _reflectionRow(
                    l10n.labelInsightsReflectionWords,
                    '${reflection.totalWordCount}',
                    theme,
                  ),
                  if (reflection.averageMood != null)
                    _reflectionRow(
                      l10n.labelInsightsReflectionAverageMood,
                      l10n.labelInsightsMoodOutOfFive(
                        reflection.averageMood!.toStringAsFixed(1),
                      ),
                      theme,
                    ),
                  if (reflection.topTags.isNotEmpty)
                    _reflectionRow(
                      l10n.labelInsightsReflectionTopTags,
                      reflection.topTags.join(', '),
                      theme,
                    ),
                  _reflectionRow(
                    l10n.labelInsightsReflectionStreak,
                    l10n.labelInsightsStreakDays(
                      reflection.streakInfo.currentStreak,
                    ),
                    theme,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.errorCommon(e.toString())),
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
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
