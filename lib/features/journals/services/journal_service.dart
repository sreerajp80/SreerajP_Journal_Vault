// Layer: service. Reads and writes journals and their tags. Knows nothing
// about widgets, navigation or UI strings.

import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/journals/domain/journal_summary.dart';

/// Journals, their tags and their entry lists.
///
/// Deleting a journal is not here: `EntryDeletionService.deleteJournal` does
/// it, because it must also remove the entries' files.
class JournalService {
  JournalService(this._db);

  final AppDatabase _db;

  /// Every journal, in the DAO's order.
  Future<List<Journal>> allJournals() => _db.journalsDao.getAllJournals();

  /// The entries of [journalId], in the DAO's order.
  Future<List<Entry>> entriesForJournal(int journalId) =>
      _db.entriesDao.getEntriesForJournal(journalId);

  /// Every journal with its tags, entry count and last change time.
  Future<List<JournalSummary>> journalSummaries() async {
    final journals = await allJournals();
    final items = <JournalSummary>[];
    for (final j in journals) {
      final tags = await _db.journalTagsDao.getTagsForJournal(j.id);
      final entries = await entriesForJournal(j.id);
      DateTime? lastUpdated;
      for (final e in entries) {
        if (lastUpdated == null || e.updatedAt.isAfter(lastUpdated)) {
          lastUpdated = e.updatedAt;
        }
      }
      lastUpdated ??= j.updatedAt;
      items.add(
        JournalSummary(
          journal: j,
          tags: tags,
          entryCount: entries.length,
          lastUpdatedAt: lastUpdated,
        ),
      );
    }
    return items;
  }

  /// Creates a journal and returns its ID. An empty [description] is stored
  /// as none. [tagsText] is a comma separated tag list.
  Future<int> createJournal({
    required String title,
    required String description,
    required String tagsText,
  }) async {
    final journalId = await _db.journalsDao.createJournal(
      JournalsCompanion.insert(
        title: title,
        description: Value(description.isEmpty ? null : description),
      ),
    );
    await applyJournalTags(journalId, tagsText);
    return journalId;
  }

  /// Changes a journal's title, description and tags.
  Future<void> updateJournal(
    int journalId, {
    required String title,
    required String description,
    required String tagsText,
  }) async {
    await _db.journalsDao.updateJournalById(
      journalId,
      JournalsCompanion(
        title: Value(title),
        description: Value(description.isEmpty ? null : description),
      ),
    );
    await applyJournalTags(journalId, tagsText);
  }

  /// Marks a journal as locked with [credential].
  Future<void> lockJournal(int journalId, JournalCredential credential) =>
      _db.journalsDao.updateJournalById(
        journalId,
        JournalsCompanion(
          isLocked: const Value(true),
          credentialReference: Value(credential.credentialReference),
          passwordSaltBase64: Value(credential.passwordSaltBase64),
          passwordVerifierBase64: Value(credential.passwordVerifierBase64),
          passwordIterations: Value(credential.passwordIterations),
        ),
      );

  /// Makes the journal's tags match [tagsText], a comma separated list.
  ///
  /// Only the difference is written: tags already on the journal are left
  /// alone, names that were removed from the text are unlinked, and new names
  /// are created if they do not exist yet. Unlinking never deletes the tag
  /// itself — tags are global and may be in use elsewhere.
  Future<void> applyJournalTags(int journalId, String tagsText) async {
    final wanted = tagsText
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    final current = await _db.journalTagsDao.getTagsForJournal(journalId);
    final currentNames = {for (final tag in current) tag.name: tag};

    for (final tag in current) {
      if (!wanted.contains(tag.name)) {
        await _db.journalTagsDao.removeTagFromJournal(journalId, tag.id);
      }
    }
    for (final name in wanted) {
      if (currentNames.containsKey(name)) continue;
      final tagId = await _db.tagsDao.getOrCreateTag(name);
      await _db.journalTagsDao.addTagToJournal(journalId, tagId);
    }
  }
}
