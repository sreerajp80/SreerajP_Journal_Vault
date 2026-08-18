/// Reads the database and turns an [ExportScope] into an [ExportBundle].
///
/// This is the only part of the export feature that touches the database. It
/// uses DAOs that already exist and adds no table and no column, so the export
/// feature needs no schema migration.
library;

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_scope.dart';

class ExportCollector {
  const ExportCollector(this._db);

  final AppDatabase _db;

  /// Gathers everything [scope] covers.
  ///
  /// Entries come back oldest first, so an exported journal reads forward in
  /// time. An entry with no date at all sorts last rather than being dropped —
  /// losing an entry from an export would be worse than showing it out of
  /// order.
  Future<ExportBundle> collect(ExportScope scope) async {
    final journal = await _db.journalsDao.getJournalById(scope.journalId);
    final entries = await _entriesFor(scope);
    entries.sort(_byDateOldestFirst);

    final documents = <ExportDocument>[];
    for (final entry in entries) {
      documents.add(await _documentFor(entry, scope));
    }

    return ExportBundle(
      journalId: journal.id,
      journalTitle: journal.title,
      documents: documents,
    );
  }

  Future<List<Entry>> _entriesFor(ExportScope scope) async {
    switch (scope.kind) {
      case ExportScopeKind.singleEntry:
        final entry = await _db.entriesDao.getEntryById(scope.entryId!);
        // Guard against an entry id from another journal being exported under
        // this journal's name — and, more importantly, under this journal's
        // unlock.
        if (entry.journalId != scope.journalId) return <Entry>[];
        return [entry];

      case ExportScopeKind.wholeJournal:
        return _db.entriesDao.getEntriesForJournal(scope.journalId);

      case ExportScopeKind.dateRange:
        final all = await _db.entriesDao.getEntriesForJournal(scope.journalId);
        return all.where((e) => _inRange(e, scope.from!, scope.to!)).toList();
    }
  }

  /// Whether [entry] falls inside the range, treating both ends as whole days.
  ///
  /// The user picks dates, not instants. Someone choosing "1 March to 3 March"
  /// means everything written on 3 March, so the end widens to the last moment
  /// of that day. Comparing raw `DateTime`s instead would silently drop almost
  /// every entry on the final day, which is the kind of quiet data loss an
  /// export must never have.
  bool _inRange(Entry entry, DateTime from, DateTime to) {
    final date = entry.entryDate ?? entry.createdAt;
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  int _byDateOldestFirst(Entry a, Entry b) {
    final dateA = a.entryDate ?? a.createdAt;
    final dateB = b.entryDate ?? b.createdAt;
    final byDate = dateA.compareTo(dateB);
    // A stable tie-break keeps two entries written in the same second in a
    // fixed order, so exporting twice gives byte-identical output.
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  }

  Future<ExportDocument> _documentFor(Entry entry, ExportScope scope) async {
    final blocks = parseDelta(
      entry.contentJson,
      fallbackPlainText: entry.plainText,
    );

    // Metadata is only read when it will actually be written. Skipping these
    // queries is what keeps a whole-journal export of a large vault quick.
    final tags = scope.includeMetadata
        ? await _db.tagsDao.getTagsForEntry(entry.id)
        : const <Tag>[];
    final mood = scope.includeMetadata
        ? await _db.entryMoodsDao.getMoodForEntry(entry.id)
        : null;

    // Voice notes are always listed, whether or not the audio is included:
    // their transcripts are part of the entry's content, not an extra.
    final voiceNotes = await _db.voiceNotesDao.getVoiceNotesForEntry(entry.id);

    // Attachments are only listed when they are being written out. Naming a
    // file the export does not contain would just be confusing.
    final attachments = scope.includeAttachments
        ? await _attachmentsFor(entry.id)
        : const <ExportAttachmentRef>[];

    // Images sitting in the writing are collected whether or not attachments
    // were asked for, because the HTML and PDF exports draw them into the page
    // itself. Nothing is read here beyond what is already needed to decrypt
    // them, and a locked one is still refused later by ExportService.
    final imageIds = blocks
        .whereType<ImageBlock>()
        .map((block) => block.attachmentId)
        .toSet();
    final inlineImages = imageIds.isEmpty
        ? const <ExportAttachmentRef>[]
        : (attachments.isNotEmpty
                  ? attachments
                  : await _attachmentsFor(entry.id))
              .where((ref) => imageIds.contains(ref.attachmentId))
              .toList();

    return ExportDocument(
      entryId: entry.id,
      title: entry.title,
      blocks: blocks,
      entryDate: entry.entryDate,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      tags: tags.map((t) => t.name).toList(),
      mood: mood?.mood,
      moodNote: mood?.note,
      attachments: attachments,
      inlineImages: inlineImages,
      voiceNotes: voiceNotes
          .map(
            (v) => ExportVoiceNoteRef(
              voiceNoteId: v.id,
              fileName: v.fileName,
              durationMs: v.durationMs,
              encryptedPath: v.encryptedPath,
              nonceBase64: v.nonceBase64,
              keyReference: v.keyReference,
              transcript: v.transcript,
            ),
          )
          .toList(),
    );
  }

  Future<List<ExportAttachmentRef>> _attachmentsFor(int entryId) async {
    final rows = await _db.attachmentsDao.getAttachmentsForEntry(entryId);
    final refs = <ExportAttachmentRef>[];
    for (final row in rows) {
      refs.add(
        ExportAttachmentRef(
          attachmentId: row.id,
          fileName: row.fileName,
          sizeBytes: row.sizeBytes,
          encryptedPath: row.encryptedPath,
          nonceBase64: row.nonceBase64,
          keyReference: row.keyReference,
          mimeType: row.mimeType,
          // The DAO's own helper, so the export agrees with the rest of the app
          // about what "locked" means. A row survives an unlock, so the flag
          // on the row is what counts, not the row's presence.
          isLocked: await _db.attachmentLocksDao.isAttachmentLocked(row.id),
        ),
      );
    }
    return refs;
  }
}
