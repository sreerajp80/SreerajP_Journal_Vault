import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set of journal IDs that have been session-unlocked by the user.
class UnlockedJournalIdsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};
  void set(Set<int> v) => state = v;
}

final unlockedJournalIdsProvider =
    NotifierProvider<UnlockedJournalIdsNotifier, Set<int>>(
      UnlockedJournalIdsNotifier.new,
    );
