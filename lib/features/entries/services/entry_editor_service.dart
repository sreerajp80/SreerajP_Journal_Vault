// Layer: service. Everything the entry editor reads from or writes to the
// database. Knows nothing about widgets, navigation or UI strings.

import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlink_parser.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_revision_service.dart';

/// Loads, creates and saves entries for the editor, and the lists it shows
/// around the text (attachments, backlinks).
class EntryEditorService {
  EntryEditorService({
    required this._db,
    required this._importService,
    required this._revisionService,
  });

  final AppDatabase _db;

  /// Looked up only when an attachment is added, so the editor can open
  /// without the attachment storage being ready.
  final AttachmentImportService Function() _importService;
  final EntryRevisionService _revisionService;

  /// The entry [entryId]. Throws when it does not exist.
  Future<Entry> loadEntry(int entryId) => _db.entriesDao.getEntryById(entryId);

  /// The journal [journalId]. Throws when it does not exist.
  Future<Journal> loadJournal(int journalId) =>
      _db.journalsDao.getJournalById(journalId);

  /// Creates an entry in [journalId] and returns its ID.
  Future<int> createEntry({
    required int journalId,
    required String? title,
    required String? contentJson,
  }) => _db.entriesDao.createEntry(
    EntriesCompanion.insert(
      journalId: journalId,
      title: Value(title),
      contentJson: Value(contentJson),
    ),
  );

  /// Replaces only the stored text of entry [entryId].
  Future<void> updateContentJson(int entryId, String contentJson) =>
      _db.entriesDao.updateEntryById(
        entryId,
        EntriesCompanion(contentJson: Value(contentJson)),
      );

  /// Encrypts [picked] and adds it to entry [entryId]. Returns the new
  /// attachment's ID.
  Future<int> addAttachment(int entryId, PickedAttachmentData picked) =>
      _importService().importToEntry(
        database: _db,
        entryId: entryId,
        picked: picked,
      );

  /// Saves the editor's text for entry [entryId].
  ///
  /// In one transaction: keeps the stored version as a revision (when it has
  /// any content), writes the new title, text and search text, and refreshes
  /// the entry's outgoing backlinks from [plainText].
  Future<void> saveContent(
    int entryId, {
    required String title,
    required String contentJson,
    required String plainText,
  }) => _db.transaction(() async {
    try {
      final current = await _db.entriesDao.getEntryById(entryId);
      final stored = current.contentJson;
      if (stored != null && stored.isNotEmpty && stored != '[]') {
        await _revisionService.createRevision(current);
      }
    } catch (_) {
      // Entry may not exist yet on first save — skip revision.
    }

    await _db.entriesDao.updateEntryById(
      entryId,
      EntriesCompanion(
        title: Value(title),
        contentJson: Value(contentJson),
        plainText: Value(plainText),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final targets = VaultBacklinkParser.parse(plainText);
    await _db.backlinksDao.replaceBacklinksForEntry(entryId, targets);
  });

  /// The backlinks that point at entry [entryId].
  Future<List<Backlink>> backlinksTo(int entryId) =>
      _db.backlinksDao.getBacklinksForEntryTarget(entryId);

  /// The attachments of entry [entryId].
  Future<List<Attachment>> attachmentsForEntry(int entryId) =>
      _db.attachmentsDao.getAttachmentsForEntry(entryId);
}
