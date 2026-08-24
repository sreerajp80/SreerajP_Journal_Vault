import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_sealed_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/time_capsule_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen listing all time capsules in the vault.
class TimeCapsulesListScreen extends ConsumerWidget {
  const TimeCapsulesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final capsulesAsync = ref.watch(allTimeCapsulesProvider);

    return Scaffold(
      key: const Key('time-capsules-list-screen'),
      appBar: AppBar(title: Text(l10n.timeCapsuleTitle)),
      body: capsulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (capsules) {
          if (capsules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.timeCapsuleEmptyState,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final now = DateTime.now();
          final ready = <TimeCapsule>[];
          final sealed = <TimeCapsule>[];
          final opened = <TimeCapsule>[];

          for (final c in capsules) {
            if (c.isOpened) {
              opened.add(c);
            } else if (!now.isBefore(c.unlockDate)) {
              ready.add(c);
            } else {
              sealed.add(c);
            }
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (ready.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.timeCapsuleCategoryReady,
                  icon: Icons.lock_open_rounded,
                  color: theme.colorScheme.primary,
                  count: ready.length,
                ),
                for (final capsule in ready)
                  _CapsuleTile(capsule: capsule, isReady: true),
                const SizedBox(height: 16),
              ],
              if (sealed.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.timeCapsuleCategorySealed,
                  icon: Icons.hourglass_bottom_rounded,
                  color: theme.colorScheme.secondary,
                  count: sealed.length,
                ),
                for (final capsule in sealed) _CapsuleTile(capsule: capsule),
                const SizedBox(height: 16),
              ],
              if (opened.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.timeCapsuleCategoryOpened,
                  icon: Icons.mark_email_read_outlined,
                  color: theme.colorScheme.tertiary,
                  count: opened.length,
                ),
                for (final capsule in opened)
                  _CapsuleTile(capsule: capsule, isOpened: true),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleTile extends ConsumerWidget {
  const _CapsuleTile({
    required this.capsule,
    this.isReady = false,
    this.isOpened = false,
  });

  final TimeCapsule capsule;
  final bool isReady;
  final bool isOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();

    final remaining = capsule.unlockDate.difference(now);
    final days = remaining.inDays;
    final hours = remaining.inHours;

    String subtitleText;
    if (isOpened) {
      final openedDate = capsule.openedAt != null
          ? DateFormat.yMMMMd().format(capsule.openedAt!)
          : DateFormat.yMMMMd().format(capsule.unlockDate);
      subtitleText = 'Opened on $openedDate';
    } else if (isReady) {
      subtitleText = l10n.timeCapsuleReadyToOpen;
    } else if (days > 1) {
      subtitleText = l10n.timeCapsuleOpensInDays(days);
    } else if (hours > 1) {
      subtitleText = l10n.timeCapsuleOpensInHours(hours);
    } else {
      subtitleText = l10n.timeCapsuleOpensToday;
    }

    final unlockDateStr = DateFormat.yMMMMd().format(capsule.unlockDate);

    return FutureBuilder<Entry>(
      future: ref
          .read(appDatabaseProvider)
          .entriesDao
          .getEntryById(capsule.entryId),
      builder: (context, snapshot) {
        final entry = snapshot.data;
        final title = entry?.title != null && entry!.title!.isNotEmpty
            ? entry.title!
            : l10n.commonUntitled;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: isReady ? 2 : 0,
          color: isReady
              ? colors.primaryContainer.withValues(alpha: 0.4)
              : colors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isReady
                  ? colors.primary.withValues(alpha: 0.5)
                  : colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isOpened
                  ? colors.tertiaryContainer
                  : isReady
                  ? colors.primaryContainer
                  : colors.secondaryContainer,
              child: Icon(
                isOpened
                    ? Icons.mark_email_read_rounded
                    : isReady
                    ? Icons.lock_open_rounded
                    : Icons.hourglass_bottom_rounded,
                color: isOpened
                    ? colors.onTertiaryContainer
                    : isReady
                    ? colors.primary
                    : colors.secondary,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isReady ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: TextStyle(
                    color: isReady ? colors.primary : colors.onSurfaceVariant,
                    fontWeight: isReady ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (capsule.teaserMessage != null &&
                    capsule.teaserMessage!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '“${capsule.teaserMessage!}”',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Text(
              unlockDateStr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            onTap: () {
              if (isOpened && entry != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => EntryEditorScreen(
                      journalId: entry.journalId,
                      entryId: entry.id,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TimeCapsuleSealedScreen(entryId: capsule.entryId),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
