// Layer: service. Deletes entries, journals and attachments together with
// their encrypted files. Knows nothing about widgets or UI strings, and never
// logs a file name, path or any journal content.

import 'dart:convert';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/attachment_ids_in_delta.dart';

/// Deletes one stored (encrypted) attachment or voice note file.
typedef StoredFileDeleter = Future<void> Function(String encryptedPath);

/// Removes entries, journals and attachments, rows and files alike.
///
/// Why this exists rather than the plain DAO deletes:
///
/// - `attachments.entry_id` has no `ON DELETE CASCADE`, and foreign keys are
///   on. Deleting an entry that has an attachment therefore fails unless the
///   attachment rows go first. Everything else that points at an entry
///   cascades.
/// - A database row only points at a file. Without this service the
///   encrypted file stayed on the device after its row was gone.
///
/// Rows are deleted inside one transaction, so a failure leaves the database
/// exactly as it was. Files are deleted only after the transaction commits: a
/// file whose row survived must never be lost. A file that cannot be deleted
/// is left for the startup orphan sweep.
class EntryDeletionService {
  EntryDeletionService({required this._db, required this._deleteStoredFile});

  final AppDatabase _db;
  final StoredFileDeleter _deleteStoredFile;

  /// Deletes the entry [entryId], its attachments and voice notes.
  Future<void> deleteEntry(int entryId) async {
    final paths = await _db.transaction(() => deleteEntryRows(entryId));
    await _deleteFiles(paths);
  }

  /// Deletes the journal [journalId] with every entry in it, all or nothing.
  Future<void> deleteJournal(int journalId) async {
    final paths = await _db.transaction(() => deleteJournalRows(journalId));
    await _deleteFiles(paths);
  }

  /// Deletes the rows of entry [entryId] and its attachments and voice notes,
  /// but **not** their files: returns the file paths instead.
  ///
  /// For a caller that runs its own transaction (Wi-Fi Sync) and must delete
  /// the files only after it commits, so a rolled-back transaction never
  /// loses a file whose row came back.
  Future<List<String>> deleteEntryRows(int entryId) async {
    final paths = await _storedFilePaths([entryId]);
    await _deleteEntryRows([entryId]);
    return paths;
  }

  /// Like [deleteEntryRows], for the journal [journalId] and every entry in
  /// it.
  Future<List<String>> deleteJournalRows(int journalId) async {
    final entries = await _db.entriesDao.getEntriesForJournal(journalId);
    final entryIds = [for (final entry in entries) entry.id];
    final paths = await _storedFilePaths(entryIds);
    await (_db.delete(
      _db.journalTags,
    )..where((t) => t.journalId.equals(journalId))).go();
    await _deleteEntryRows(entryIds);
    await _db.journalsDao.deleteJournalById(journalId);
    return paths;
  }

  /// Deletes one attachment. Its lock and search text cascade.
  ///
  /// Does nothing when the attachment no longer exists.
  Future<void> deleteAttachment(int attachmentId) async {
    final path = await _db.transaction(() async {
      final row = await (_db.select(
        _db.attachments,
      )..where((t) => t.id.equals(attachmentId))).getSingleOrNull();
      if (row == null) return null;
      await _db.attachmentsDao.deleteAttachmentById(attachmentId);
      return row.encryptedPath;
    });
    if (path != null) await _deleteFiles([path]);
  }

  /// Deletes those of [attachmentIds] that the saved text of entry [entryId]
  /// no longer shows. Returns how many were deleted. Never throws.
  ///
  /// Used when the editor closes, for drawings that were replaced while it was
  /// open. They are kept until then so that Undo can bring them back. The
  /// entry's **saved** content is read, not the screen, so nothing the saved
  /// entry still shows is ever deleted. Only attachments of that entry are
  /// touched.
  Future<int> deleteUnreferencedAttachments(
    int entryId,
    Set<int> attachmentIds,
  ) async {
    if (attachmentIds.isEmpty) return 0;
    try {
      final entry = await (_db.select(
        _db.entries,
      )..where((t) => t.id.equals(entryId))).getSingleOrNull();
      if (entry == null) return 0;
      final content = entry.contentJson;
      final shown = content == null || content.isEmpty
          ? const <int>{}
          : attachmentIdsInDelta(jsonDecode(content));
      final ofEntry = await (_db.select(
        _db.attachments,
      )..where((t) => t.entryId.equals(entryId))).get();
      var deleted = 0;
      for (final attachment in ofEntry) {
        if (!attachmentIds.contains(attachment.id)) continue;
        if (shown.contains(attachment.id)) continue;
        await deleteAttachment(attachment.id);
        deleted++;
      }
      return deleted;
    } catch (e) {
      // A drawing left behind is harmless: the user can delete it from the
      // attachment tray.
      AppLogger.warning(
        'EntryDeletionService: replaced drawings not cleaned up',
        error: e,
      );
      return 0;
    }
  }

  Future<List<String>> _storedFilePaths(List<int> entryIds) async {
    if (entryIds.isEmpty) return const [];
    final attachments = await (_db.select(
      _db.attachments,
    )..where((t) => t.entryId.isIn(entryIds))).get();
    final voiceNotes = await (_db.select(
      _db.voiceNotes,
    )..where((t) => t.entryId.isIn(entryIds))).get();
    return [
      for (final a in attachments) a.encryptedPath,
      for (final v in voiceNotes) v.encryptedPath,
    ];
  }

  Future<void> _deleteEntryRows(List<int> entryIds) async {
    if (entryIds.isEmpty) return;
    // Attachments first: they are the one child without a cascade.
    await (_db.delete(
      _db.attachments,
    )..where((t) => t.entryId.isIn(entryIds))).go();
    await (_db.delete(_db.entries)..where((t) => t.id.isIn(entryIds))).go();
  }

  Future<void> _deleteFiles(List<String> paths) async {
    var failed = 0;
    for (final path in paths) {
      if (path.isEmpty) continue;
      try {
        await _deleteStoredFile(path);
      } catch (_) {
        failed++;
      }
    }
    if (failed > 0) {
      AppLogger.warning(
        'EntryDeletionService: $failed stored files could not be deleted',
      );
    }
  }
}
