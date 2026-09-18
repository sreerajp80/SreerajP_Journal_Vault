import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/links/vault_backlinks.dart';

part 'app_database_daos.dart';
part 'app_database_daos_sync_security.dart';
part 'app_database_tables.dart';

part 'app_database.g.dart';

// ──────────────────────────── Tables ────────────────────────────

/// Result of a full-text search query.
class FtsSearchResult {
  final int entryId;
  final int journalId;
  final String? title;
  final String snippet;
  final double rank;

  const FtsSearchResult({
    required this.entryId,
    required this.journalId,
    this.title,
    required this.snippet,
    required this.rank,
  });
}

/// Entry count on a specific date for the timeline/calendar view.
class DateEntryCount {
  final DateTime date;
  final int count;

  const DateEntryCount({required this.date, required this.count});
}

// ──────────────────────────── Database ────────────────────────────

@DriftDatabase(
  tables: [
    Journals,
    Entries,
    Tags,
    JournalTags,
    EntryTags,
    Attachments,
    AttachmentTexts,
    Backlinks,
    SearchPresets,
    AppSettings,
    AppSecurity,
    EntryRevisions,
    VoiceNotes,
    BackupLogs,
    SyncMetadata,
    SyncConflicts,
    SyncLogs,
    AutoLockProfiles,
    AttachmentLocks,
    SecurityEvents,
    EntryMoods,
    UserTemplates,
    TimeCapsules,
    UserRitualCards,
  ],
  daos: [
    JournalsDao,
    EntriesDao,
    TagsDao,
    AttachmentsDao,
    AttachmentTextsDao,
    BacklinksDao,
    BackupLogsDao,
    SearchPresetsDao,
    AppSettingsDao,
    AppSecurityDao,
    JournalTagsDao,
    EntryRevisionsDao,
    VoiceNotesDao,
    SyncMetadataDao,
    SyncConflictsDao,
    SyncLogsDao,
    AutoLockProfilesDao,
    AttachmentLocksDao,
    SecurityEventsDao,
    EntryMoodsDao,
    UserTemplatesDao,
    TimeCapsulesDao,
    UserRitualCardsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createFts5Tables();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(entryTags);
        await m.createTable(attachmentTexts);
        await _createFts5Tables();
        await customStatement('''
              INSERT INTO entries_fts (rowid, title, plain_text)
              SELECT id, COALESCE(title, ''), COALESCE(plain_text, '')
              FROM entries
            ''');
      }
      if (from < 3) {
        await m.createTable(entryRevisions);
        await m.createTable(voiceNotes);
      }
      if (from < 4) {
        await m.createTable(backupLogs);
      }
      if (from < 5) {
        await m.createTable(syncMetadata);
        await m.createTable(syncConflicts);
        await m.createTable(syncLogs);
      }
      if (from < 6) {
        await m.createTable(autoLockProfiles);
        await m.createTable(attachmentLocks);
        await m.createTable(securityEvents);
        await m.createTable(entryMoods);
      }
      if (from < 7) {
        await m.addColumn(appSettings, appSettings.attachmentStorageTreeLabel);
        await m.addColumn(appSettings, appSettings.attachmentMigrationTarget);
        await m.addColumn(appSettings, appSettings.attachmentMigrationFailure);
        await m.addColumn(appSettings, appSettings.updatedAt);
      }
      if (from < 8) {
        await m.addColumn(tags, tags.colorArgb);
      }
      if (from < 9) {
        await m.createTable(userTemplates);
      }
      if (from < 10) {
        await m.createTable(timeCapsules);
      }
      if (from < 11) {
        await m.createTable(userRitualCards);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Creates the FTS5 virtual table and synchronisation triggers.
  ///
  /// The FTS5 index covers:
  /// - Entry title and plain_text (from the entries table).
  /// - Attachment extracted text (from attachment_texts, joined via a
  ///   separate content-sync trigger on attachment_texts).
  Future<void> _createFts5Tables() async {
    // Main FTS5 table for entry content.
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts
      USING fts5(
        title,
        plain_text,
        content='entries',
        content_rowid='id'
      )
    ''');

    // Keep FTS in sync when entries change.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ai AFTER INSERT ON entries BEGIN
        INSERT INTO entries_fts(rowid, title, plain_text)
        VALUES (new.id, COALESCE(new.title, ''), COALESCE(new.plain_text, ''));
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ad AFTER DELETE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, title, plain_text)
        VALUES ('delete', old.id, COALESCE(old.title, ''), COALESCE(old.plain_text, ''));
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_au AFTER UPDATE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, title, plain_text)
        VALUES ('delete', old.id, COALESCE(old.title, ''), COALESCE(old.plain_text, ''));
        INSERT INTO entries_fts(rowid, title, plain_text)
        VALUES (new.id, COALESCE(new.title, ''), COALESCE(new.plain_text, ''));
      END
    ''');

    // Separate FTS5 table for attachment extracted text.
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS attachment_text_fts
      USING fts5(
        extracted_text,
        content='attachment_texts',
        content_rowid='id'
      )
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS att_text_ai AFTER INSERT ON attachment_texts BEGIN
        INSERT INTO attachment_text_fts(rowid, extracted_text)
        VALUES (new.id, new.extracted_text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS att_text_ad AFTER DELETE ON attachment_texts BEGIN
        INSERT INTO attachment_text_fts(attachment_text_fts, rowid, extracted_text)
        VALUES ('delete', old.id, old.extracted_text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS att_text_au AFTER UPDATE ON attachment_texts BEGIN
        INSERT INTO attachment_text_fts(attachment_text_fts, rowid, extracted_text)
        VALUES ('delete', old.id, old.extracted_text);
        INSERT INTO attachment_text_fts(rowid, extracted_text)
        VALUES (new.id, new.extracted_text);
      END
    ''');
  }

  // ────────────── Full-text search queries ──────────────

  /// Searches entry content and attachment text using FTS5.
  ///
  /// Returns results ranked by relevance with highlighted snippets.
  /// Unopened sealed time capsules are excluded until their unlock date.
  Future<List<FtsSearchResult>> searchEntries(String query) async {
    if (query.trim().isEmpty) return [];

    // Sanitise user input for FTS5 — wrap each token in double quotes
    // so special characters are treated as literals.
    final sanitised = query
        .trim()
        .split(RegExp(r'\s+'))
        .map((t) => '"$t"')
        .join(' ');

    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Search entry content.
    final entryResults = await customSelect(
      '''
      SELECT e.id AS entry_id,
             e.journal_id,
             e.title,
             snippet(entries_fts, 1, '<b>', '</b>', '...', 32) AS snippet,
             entries_fts.rank
      FROM entries_fts
      INNER JOIN entries e ON e.id = entries_fts.rowid
      LEFT JOIN time_capsules tc ON tc.entry_id = e.id
      WHERE entries_fts MATCH ?
        AND (tc.id IS NULL OR tc.is_opened = 1 OR tc.unlock_date <= ?)
      ORDER BY entries_fts.rank
      LIMIT 100
      ''',
      variables: [Variable.withString(sanitised), Variable.withInt(nowSec)],
    ).get();

    // Search attachment extracted text.
    final attachmentResults = await customSelect(
      '''
      SELECT e.id AS entry_id,
             e.journal_id,
             e.title,
             snippet(attachment_text_fts, 0, '<b>', '</b>', '...', 32) AS snippet,
             attachment_text_fts.rank
      FROM attachment_text_fts
      INNER JOIN attachment_texts at2 ON at2.id = attachment_text_fts.rowid
      INNER JOIN attachments a ON a.id = at2.attachment_id
      INNER JOIN entries e ON e.id = a.entry_id
      LEFT JOIN time_capsules tc ON tc.entry_id = e.id
      WHERE attachment_text_fts MATCH ?
        AND (tc.id IS NULL OR tc.is_opened = 1 OR tc.unlock_date <= ?)
      ORDER BY attachment_text_fts.rank
      LIMIT 50
      ''',
      variables: [Variable.withString(sanitised), Variable.withInt(nowSec)],
    ).get();

    // Merge and deduplicate by entry id, keeping best rank.
    final Map<int, FtsSearchResult> merged = {};
    for (final row in [...entryResults, ...attachmentResults]) {
      final entryId = row.read<int>('entry_id');
      final rank = row.read<double>('rank');
      final existing = merged[entryId];
      if (existing == null || rank < existing.rank) {
        merged[entryId] = FtsSearchResult(
          entryId: entryId,
          journalId: row.read<int>('journal_id'),
          title: row.readNullable<String>('title'),
          snippet: row.read<String>('snippet'),
          rank: rank,
        );
      }
    }

    final results = merged.values.toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    return results;
  }

  // ────────────── Timeline queries ──────────────

  /// Returns entry counts grouped by date for a given month.
  Future<List<DateEntryCount>> getEntryCountsForMonth(
    int year,
    int month,
  ) async {
    // entry_date is stored as Unix seconds by drift's default DateTime
    // mapping, so feed it directly to unixepoch (no extra divide).
    final results = await customSelect(
      '''
      SELECT DATE(entry_date, 'unixepoch') AS day,
             COUNT(*) AS cnt
      FROM entries
      WHERE entry_date IS NOT NULL
        AND strftime('%Y', entry_date, 'unixepoch') = ?
        AND strftime('%m', entry_date, 'unixepoch') = ?
      GROUP BY day
      ''',
      variables: [
        Variable.withString(year.toString()),
        Variable.withString(month.toString().padLeft(2, '0')),
      ],
    ).get();

    return results.map((row) {
      final dayStr = row.read<String>('day');
      return DateEntryCount(
        date: DateTime.parse(dayStr),
        count: row.read<int>('cnt'),
      );
    }).toList();
  }

  /// Returns all entries for a specific date.
  Future<List<Entry>> getEntriesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(entries)
          ..where(
            (t) =>
                t.entryDate.isBiggerOrEqualValue(startOfDay) &
                t.entryDate.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.entryDate)]))
        .get();
  }
}
