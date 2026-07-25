import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';

class FocusedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month);

  void set(DateTime month) => state = month;
}

/// Currently focused month on the calendar.
final focusedMonthProvider = NotifierProvider<FocusedMonthNotifier, DateTime>(
  FocusedMonthNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => DateTime.now();

  void set(DateTime? date) => state = date;
}

/// The currently selected date on the calendar.
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime?>(
  SelectedDateNotifier.new,
);

/// Entry counts per date for the currently focused month.
final monthEntryCountsProvider =
    FutureProvider<Map<DateTime, int>>((ref) async {
  final focused = ref.watch(focusedMonthProvider);
  final db = ref.read(appDatabaseProvider);
  final counts = await db.getEntryCountsForMonth(focused.year, focused.month);

  return {for (final c in counts) c.date: c.count};
});

/// Entries for the currently selected date.
final selectedDateEntriesProvider = FutureProvider<List<Entry>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  if (date == null) return [];
  final db = ref.read(appDatabaseProvider);
  return db.getEntriesForDate(date);
});
