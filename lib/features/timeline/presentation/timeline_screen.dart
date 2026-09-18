import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_sealed_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/time_capsule_providers.dart';
import 'package:sreerajp_journal_vault/features/timeline/providers/timeline_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final focusedMonth = ref.watch(focusedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final countsAsync = ref.watch(monthEntryCountsProvider);
    final entriesAsync = ref.watch(selectedDateEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleTimeline)),
      body: Column(
        children: [
          countsAsync.when(
            loading: () => const SizedBox(
              height: 360,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 360,
              child: Center(child: Text(l10n.errorCommon(e.toString()))),
            ),
            data: (counts) => _Calendar(
              focusedDay: focusedMonth,
              selectedDay: selectedDate,
              entryCounts: counts,
              onDaySelected: (day) {
                ref.read(selectedDateProvider.notifier).set(day);
              },
              onPageChanged: (focusedDay) {
                ref.read(focusedMonthProvider.notifier).set(focusedDay);
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text(l10n.errorCommon(e.toString()))),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(l10n.emptyTimelineNoEntriesForDate),
                  );
                }
                return _EntryList(entries: entries);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.entryCounts,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, int> entryCounts;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return TableCalendar<void>(
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) =>
          selectedDay != null && isSameDay(day, selectedDay),
      onDaySelected: (selected, focused) => onDaySelected(selected),
      onPageChanged: onPageChanged,
      availableCalendarFormats: {
        CalendarFormat.month: l10n.labelTimelineCalendarFormatMonth,
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, _) {
          final normalised = DateTime(day.year, day.month, day.day);
          final count = entryCounts[normalised];
          if (count == null || count == 0) return null;
          return Positioned(
            bottom: 1,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? l10n.labelTimelineDayCountOverflow : '$count',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EntryList extends ConsumerWidget {
  const _EntryList({required this.entries});

  final List<Entry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final capsuleAsync = ref.watch(timeCapsuleForEntryProvider(entry.id));
        final capsule = capsuleAsync.asData?.value;
        final isSealed = capsule != null && !capsule.isOpened;

        Widget? leading;
        Widget? subtitleWidget;
        if (isSealed) {
          final isReady = !DateTime.now().isBefore(capsule.unlockDate);
          leading = Icon(
            isReady ? Icons.lock_open_rounded : Icons.hourglass_bottom_rounded,
            color: isReady
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
            size: 20,
          );
          subtitleWidget = Text(
            isReady
                ? l10n.actionTimeCapsuleReadyToOpen
                : l10n.labelTimeCapsuleSealedBadge,
            style: TextStyle(
              color: isReady
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              fontWeight: isReady ? FontWeight.bold : FontWeight.normal,
            ),
          );
        } else if (entry.plainText != null && entry.plainText!.isNotEmpty) {
          subtitleWidget = Text(
            entry.plainText!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }

        return ListTile(
          leading: leading,
          title: Text(
            entry.title ?? l10n.descCommonUntitledEntry,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: subtitleWidget,
          onTap: () {
            if (isSealed) {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => TimeCapsuleSealedScreen(entryId: entry.id),
                ),
              );
            } else {
              Navigator.of(context).pop(entry.id);
            }
          },
        );
      },
    );
  }
}
