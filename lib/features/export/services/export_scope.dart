/// What an export covers, and what to put in it.
library;

/// Which entries an export takes.
enum ExportScopeKind {
  /// One entry, named by [ExportScope.entryId].
  singleEntry,

  /// Every entry in the journal.
  wholeJournal,

  /// Entries whose date falls inside [ExportScope.from]..[ExportScope.to].
  dateRange,
}

/// The user's choice of what to export.
///
/// A value object with no behaviour beyond validation, so it is easy to pass
/// around and easy to test. Always names exactly one journal: exporting across
/// journals is deliberately not supported, because each journal can have its
/// own lock and mixing them would blur that rule.
class ExportScope {
  const ExportScope._({
    required this.kind,
    required this.journalId,
    this.entryId,
    this.from,
    this.to,
    this.includeAttachments = false,
    this.includeMetadata = true,
  });

  /// One entry.
  const ExportScope.singleEntry({
    required int journalId,
    required int entryId,
    bool includeAttachments = false,
    bool includeMetadata = true,
  }) : this._(
         kind: ExportScopeKind.singleEntry,
         journalId: journalId,
         entryId: entryId,
         includeAttachments: includeAttachments,
         includeMetadata: includeMetadata,
       );

  /// Every entry in one journal.
  const ExportScope.wholeJournal({
    required int journalId,
    bool includeAttachments = false,
    bool includeMetadata = true,
  }) : this._(
         kind: ExportScopeKind.wholeJournal,
         journalId: journalId,
         includeAttachments: includeAttachments,
         includeMetadata: includeMetadata,
       );

  /// Entries in one journal between two dates.
  ///
  /// Both ends are **inclusive**, and whole days: an export of
  /// 1 March to 3 March includes everything written on 3 March, not only the
  /// entries stamped exactly midnight. [ExportCollector] applies that widening,
  /// so callers pass plain dates.
  const ExportScope.dateRange({
    required int journalId,
    required DateTime from,
    required DateTime to,
    bool includeAttachments = false,
    bool includeMetadata = true,
  }) : this._(
         kind: ExportScopeKind.dateRange,
         journalId: journalId,
         from: from,
         to: to,
         includeAttachments: includeAttachments,
         includeMetadata: includeMetadata,
       );

  final ExportScopeKind kind;
  final int journalId;

  /// Set only for [ExportScopeKind.singleEntry].
  final int? entryId;

  /// Set only for [ExportScopeKind.dateRange].
  final DateTime? from;
  final DateTime? to;

  /// Whether to decrypt attachments and voice-note audio into the bundle.
  final bool includeAttachments;

  /// Whether each entry gets a header with its date, tags and mood.
  final bool includeMetadata;

  ExportScope copyWith({bool? includeAttachments, bool? includeMetadata}) =>
      ExportScope._(
        kind: kind,
        journalId: journalId,
        entryId: entryId,
        from: from,
        to: to,
        includeAttachments: includeAttachments ?? this.includeAttachments,
        includeMetadata: includeMetadata ?? this.includeMetadata,
      );

  @override
  String toString() => 'ExportScope($kind, journal $journalId)';
}
