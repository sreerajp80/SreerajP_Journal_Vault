// Layer: service. Saves content that arrives from outside the editor — text
// and files shared from another app, and entries or journals received by
// AirQR. Knows nothing about widgets or UI strings: fallback titles and the
// shape of a picture embed are passed in by the caller.

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';

/// Builds the Quill insert for a picture, from its attachment ID and file
/// name. The editor's embed classes live in `presentation/`, so the caller
/// supplies this.
typedef ImageInsertBuilder =
    Map<String, dynamic> Function(int attachmentId, String fileName);

/// Creates entries and journals from shared or received content.
class IncomingEntryService {
  IncomingEntryService({required this._db, required this._importService});

  final AppDatabase _db;

  /// Looked up only when a shared file is saved.
  final AttachmentImportService Function() _importService;

  /// Saves shared [text] and [media] as a new entry in [journalId], and
  /// returns its ID.
  ///
  /// Every file becomes an attachment. Pictures also get an embed in the text,
  /// built by [imageInsert]. A file that cannot be saved is skipped, and the
  /// rest still are.
  Future<int> saveSharedEntry({
    required int journalId,
    required String title,
    required String text,
    required List<PickedAttachmentData> media,
    required ImageInsertBuilder imageInsert,
  }) async {
    final ops = <Map<String, dynamic>>[
      {'insert': text.isNotEmpty ? '$text\n' : '\n'},
    ];

    final entryId = await _db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: Value(title),
        contentJson: Value(jsonEncode(ops)),
      ),
    );

    final updatedOps = List<Map<String, dynamic>>.from(ops);
    for (final file in media) {
      try {
        final attachmentId = await _importService().importToEntry(
          database: _db,
          entryId: entryId,
          picked: file,
        );
        if (file.mimeType.startsWith('image/')) {
          updatedOps.add({'insert': imageInsert(attachmentId, file.fileName)});
          updatedOps.add({'insert': '\n'});
        }
      } catch (_) {}
    }

    await _db.entriesDao.updateEntryById(
      entryId,
      EntriesCompanion(contentJson: Value(jsonEncode(updatedOps))),
    );
    return entryId;
  }

  /// Saves an entry received by AirQR into the first journal, and returns its
  /// ID. [mood] is kept only when it is a whole number from 1 to 5.
  ///
  /// When there is no journal yet, one named [fallbackJournalTitle] is made
  /// first, so the entry always has a real journal to go into.
  Future<int> importReceivedEntry({
    required String title,
    required String contentJson,
    required String plainText,
    required String? mood,
    required String fallbackJournalTitle,
  }) async {
    final journals = await _db.journalsDao.getAllJournals();
    final journalId = journals.isNotEmpty
        ? journals.first.id
        : await _db.journalsDao.createJournal(
            JournalsCompanion.insert(title: fallbackJournalTitle),
          );

    final entryId = await _db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: Value(title),
        contentJson: Value(contentJson),
        plainText: Value(plainText),
      ),
    );

    if (mood != null && mood.isNotEmpty) {
      final moodInt = int.tryParse(mood);
      if (moodInt != null && moodInt >= 1 && moodInt <= 5) {
        await _db.entryMoodsDao.upsertMood(
          EntryMoodsCompanion.insert(entryId: entryId, mood: moodInt),
        );
      }
    }
    return entryId;
  }

  /// Saves a journal received by AirQR, with its entries, and returns its ID.
  ///
  /// [entries] are the payload's entry maps; anything that is not a map is
  /// skipped. An entry without a title gets [fallbackEntryTitle].
  Future<int> importReceivedJournal({
    required String title,
    required String? description,
    required List<dynamic> entries,
    required String fallbackEntryTitle,
  }) async {
    final journalId = await _db.journalsDao.createJournal(
      JournalsCompanion.insert(title: title, description: Value(description)),
    );

    for (final e in entries) {
      if (e is Map<String, dynamic>) {
        await _db.entriesDao.createEntry(
          EntriesCompanion.insert(
            journalId: journalId,
            title: Value(e['title'] as String? ?? fallbackEntryTitle),
            contentJson: Value(e['contentJson'] as String? ?? ''),
            plainText: Value(e['plainText'] as String? ?? ''),
          ),
        );
      }
    }
    return journalId;
  }
}
