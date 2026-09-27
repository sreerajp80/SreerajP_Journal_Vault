import 'package:sreerajp_journal_vault/core/database/app_database.dart';

// Layer: domain.

/// One journal as the home screen shows it: the journal, its tags, how many
/// entries it has, and when it last changed.
class JournalSummary {
  const JournalSummary({
    required this.journal,
    required this.tags,
    required this.entryCount,
    required this.lastUpdatedAt,
  });

  final Journal journal;
  final List<Tag> tags;
  final int entryCount;

  /// The newest entry change, or the journal's own change time when it has
  /// no entries.
  final DateTime? lastUpdatedAt;
}
