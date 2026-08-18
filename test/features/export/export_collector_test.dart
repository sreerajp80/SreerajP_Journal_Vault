import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_collector.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_scope.dart';

/// Covers the one part of the export feature that reads the database.
///
/// The date-range boundary tests are the ones that matter: an off-by-one there
/// silently drops a day's entries out of an export, which is exactly the kind
/// of quiet loss this feature exists to prevent.
void main() {
  late AppDatabase db;
  late ExportCollector collector;
  late int journalId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    collector = ExportCollector(db);
    journalId = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'My Journal'),
    );
  });

  tearDown(() async => db.close());

  Future<int> addEntry({
    String? title,
    String? contentJson,
    String? plainText,
    DateTime? entryDate,
  }) => db.entriesDao.createEntry(
    EntriesCompanion.insert(
      journalId: journalId,
      title: Value(title),
      contentJson: Value(contentJson),
      plainText: Value(plainText),
      entryDate: Value(entryDate),
    ),
  );

  String deltaOf(String text) => jsonEncode([
    {'insert': '$text\n'},
  ]);

  group('scopes', () {
    test('a single entry brings back just that entry', () async {
      final wanted = await addEntry(title: 'Wanted');
      await addEntry(title: 'Other');

      final bundle = await collector.collect(
        ExportScope.singleEntry(journalId: journalId, entryId: wanted),
      );

      expect(bundle.documents, hasLength(1));
      expect(bundle.documents.single.title, 'Wanted');
      expect(bundle.journalTitle, 'My Journal');
    });

    test('a whole journal brings back every entry', () async {
      await addEntry(title: 'A');
      await addEntry(title: 'B');

      final bundle = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId),
      );

      expect(bundle.entryCount, 2);
    });

    test('entries from another journal are never included', () async {
      final otherJournal = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Other Journal'),
      );
      await db.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: otherJournal,
          title: const Value('Not mine'),
        ),
      );
      await addEntry(title: 'Mine');

      final bundle = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId),
      );

      expect(bundle.documents.map((d) => d.title), ['Mine']);
    });

    test('a single-entry scope refuses an entry from another journal', () async {
      // The journal id carries the unlock. An entry id from elsewhere must not
      // ride in on it.
      final otherJournal = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Other Journal'),
      );
      final foreignEntry = await db.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: otherJournal,
          title: const Value('Not mine'),
        ),
      );

      final bundle = await collector.collect(
        ExportScope.singleEntry(journalId: journalId, entryId: foreignEntry),
      );

      expect(bundle.documents, isEmpty);
    });
  });

  group('date range', () {
    test('includes both end days in full', () async {
      await addEntry(title: 'before', entryDate: DateTime(2026, 3, 9, 23, 59));
      await addEntry(
        title: 'first day',
        entryDate: DateTime(2026, 3, 10, 0, 1),
      );
      await addEntry(title: 'middle', entryDate: DateTime(2026, 3, 11, 12));
      // Late on the final day — the case a naive comparison drops.
      await addEntry(
        title: 'last day',
        entryDate: DateTime(2026, 3, 12, 23, 58),
      );
      await addEntry(title: 'after', entryDate: DateTime(2026, 3, 13, 0, 1));

      final bundle = await collector.collect(
        ExportScope.dateRange(
          journalId: journalId,
          from: DateTime(2026, 3, 10),
          to: DateTime(2026, 3, 12),
        ),
      );

      expect(bundle.documents.map((d) => d.title), [
        'first day',
        'middle',
        'last day',
      ]);
    });

    test('a single-day range works', () async {
      await addEntry(title: 'that day', entryDate: DateTime(2026, 3, 2, 15));
      await addEntry(title: 'next day', entryDate: DateTime(2026, 3, 3, 1));

      final bundle = await collector.collect(
        ExportScope.dateRange(
          journalId: journalId,
          from: DateTime(2026, 3, 2),
          to: DateTime(2026, 3, 2),
        ),
      );

      expect(bundle.documents.map((d) => d.title), ['that day']);
    });

    test('falls back to createdAt when an entry has no entry date', () async {
      // entryDate is nullable, so a range must still be able to place the
      // entry rather than dropping it.
      await addEntry(title: 'no date');

      final bundle = await collector.collect(
        ExportScope.dateRange(
          journalId: journalId,
          from: DateTime(2000),
          to: DateTime(2100),
        ),
      );

      expect(bundle.documents.map((d) => d.title), ['no date']);
    });
  });

  group('ordering', () {
    test('sorts oldest first so the journal reads forward in time', () async {
      await addEntry(title: 'newest', entryDate: DateTime(2026, 3, 12));
      await addEntry(title: 'oldest', entryDate: DateTime(2026, 3, 10));
      await addEntry(title: 'middle', entryDate: DateTime(2026, 3, 11));

      final bundle = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId),
      );

      expect(bundle.documents.map((d) => d.title), [
        'oldest',
        'middle',
        'newest',
      ]);
    });

    test('breaks ties by id so two exports match byte for byte', () async {
      final sameMoment = DateTime(2026, 3, 10, 9);
      final first = await addEntry(title: 'first', entryDate: sameMoment);
      final second = await addEntry(title: 'second', entryDate: sameMoment);

      final bundle = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId),
      );

      expect(bundle.documents.map((d) => d.entryId), [first, second]);
    });
  });

  group('content', () {
    test('parses the delta body into blocks', () async {
      await addEntry(title: 'T', contentJson: deltaOf('the body'));

      final bundle = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId),
      );

      final block = bundle.documents.single.blocks.single as TextBlock;
      expect(block.plainText, 'the body');
    });

    test(
      'falls back to the plain-text column when the delta is corrupt',
      () async {
        await addEntry(
          title: 'T',
          contentJson: '{broken',
          plainText: 'the words survive',
        );

        final bundle = await collector.collect(
          ExportScope.wholeJournal(journalId: journalId),
        );

        final block = bundle.documents.single.blocks.single as TextBlock;
        expect(block.plainText, 'the words survive');
      },
    );
  });

  group('metadata', () {
    test('collects tags and mood when metadata is wanted', () async {
      final entryId = await addEntry(title: 'T');
      final tagId = await db.tagsDao.getOrCreateTag('work');
      await db.tagsDao.addTagToEntry(entryId, tagId);
      await db.entryMoodsDao.upsertMood(
        EntryMoodsCompanion.insert(
          entryId: entryId,
          mood: 4,
          note: const Value('good day'),
        ),
      );

      final bundle = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId),
      );

      final doc = bundle.documents.single;
      expect(doc.tags, ['work']);
      expect(doc.mood, 4);
      expect(doc.moodNote, 'good day');
    });

    test('skips tags and mood when metadata is not wanted', () async {
      final entryId = await addEntry(title: 'T');
      final tagId = await db.tagsDao.getOrCreateTag('work');
      await db.tagsDao.addTagToEntry(entryId, tagId);
      await db.entryMoodsDao.upsertMood(
        EntryMoodsCompanion.insert(entryId: entryId, mood: 4),
      );

      final bundle = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId, includeMetadata: false),
      );

      expect(bundle.documents.single.tags, isEmpty);
      expect(bundle.documents.single.mood, isNull);
    });
  });

  group('attachments and voice notes', () {
    Future<int> addAttachment(int entryId, String fileName) =>
        db.attachmentsDao.createAttachment(
          AttachmentsCompanion.insert(
            entryId: entryId,
            fileName: fileName,
            encryptedPath: '/enc/$fileName',
            nonceBase64: 'nonce',
            keyReference: 'key',
            sizeBytes: 10,
          ),
        );

    test('collects attachments only when they will be written out', () async {
      final entryId = await addEntry(title: 'T');
      await addAttachment(entryId, 'photo.jpg');

      final without = await collector.collect(
        ExportScope.wholeJournal(journalId: journalId),
      );
      expect(without.documents.single.attachments, isEmpty);

      final with_ = await collector.collect(
        ExportScope.wholeJournal(
          journalId: journalId,
          includeAttachments: true,
        ),
      );
      expect(with_.documents.single.attachments, hasLength(1));
      expect(with_.documents.single.attachments.single.fileName, 'photo.jpg');
    });

    test('marks a locked attachment as locked', () async {
      final entryId = await addEntry(title: 'T');
      final attachmentId = await addAttachment(entryId, 'secret.pdf');
      await db.attachmentLocksDao.lockAttachment(
        AttachmentLocksCompanion.insert(attachmentId: attachmentId),
      );

      final bundle = await collector.collect(
        ExportScope.wholeJournal(
          journalId: journalId,
          includeAttachments: true,
        ),
      );

      expect(bundle.documents.single.attachments.single.isLocked, isTrue);
    });

    test('an unlocked attachment is not marked locked', () async {
      final entryId = await addEntry(title: 'T');
      final attachmentId = await addAttachment(entryId, 'open.pdf');
      await db.attachmentLocksDao.lockAttachment(
        AttachmentLocksCompanion.insert(attachmentId: attachmentId),
      );
      await db.attachmentLocksDao.unlockAttachment(attachmentId);

      final bundle = await collector.collect(
        ExportScope.wholeJournal(
          journalId: journalId,
          includeAttachments: true,
        ),
      );

      expect(bundle.documents.single.attachments.single.isLocked, isFalse);
    });

    test(
      'collects voice notes even when attachments are not included',
      () async {
        // A transcript is part of the entry's content, not an optional extra.
        final entryId = await addEntry(title: 'T');
        await db.voiceNotesDao.createVoiceNote(
          VoiceNotesCompanion.insert(
            entryId: entryId,
            fileName: 'note.m4a',
            encryptedPath: '/enc/note',
            nonceBase64: 'n',
            keyReference: 'k',
            durationMs: 95000,
            transcript: const Value('what I said'),
          ),
        );

        final bundle = await collector.collect(
          ExportScope.wholeJournal(journalId: journalId),
        );

        final voiceNote = bundle.documents.single.voiceNotes.single;
        expect(voiceNote.transcript, 'what I said');
        expect(voiceNote.formattedDuration, '1:35');
      },
    );
  });

  test('an empty journal produces an empty bundle', () async {
    final bundle = await collector.collect(
      ExportScope.wholeJournal(journalId: journalId),
    );

    expect(bundle.isEmpty, isTrue);
    expect(bundle.journalTitle, 'My Journal');
  });
}
