import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Service for managing entry version history.
///
/// Creates snapshot revisions before significant edits so the user
/// can browse and deterministically restore any previous version.
class EntryRevisionService {
  const EntryRevisionService(this._db);

  final AppDatabase _db;

  /// Creates a snapshot revision of the current entry state.
  ///
  /// Call this before applying changes to preserve the current version.
  Future<int> createRevision(Entry entry) async {
    return _db.entryRevisionsDao.createRevision(
      EntryRevisionsCompanion.insert(
        entryId: entry.id,
        title: Value(entry.title),
        contentJson: Value(entry.contentJson),
        plainText: Value(entry.plainText),
      ),
    );
  }

  /// Lists all revisions for an entry, newest first.
  Future<List<EntryRevision>> getRevisions(int entryId) =>
      _db.entryRevisionsDao.getRevisionsForEntry(entryId);

  /// Watches revisions for an entry (for reactive UI).
  Stream<List<EntryRevision>> watchRevisions(int entryId) =>
      _db.entryRevisionsDao.watchRevisionsForEntry(entryId);

  /// Restores an entry to a specific revision.
  ///
  /// This is deterministic: the entry content is replaced with an exact
  /// copy of the revision's content. A new revision is created first to
  /// preserve the current state before the restore, so the operation is
  /// always reversible.
  Future<void> restoreRevision({
    required int entryId,
    required int revisionId,
  }) async {
    // Fetch the current entry to snapshot it before restoring.
    final currentEntry = await _db.entriesDao.getEntryById(entryId);
    await createRevision(currentEntry);

    // Fetch the target revision.
    final revision = await _db.entryRevisionsDao.getRevisionById(revisionId);

    // Overwrite the entry with the revision's content.
    await _db.entriesDao.updateEntryById(
      entryId,
      EntriesCompanion(
        title: Value(revision.title),
        contentJson: Value(revision.contentJson),
        plainText: Value(revision.plainText),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
