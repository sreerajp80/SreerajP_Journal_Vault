import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_deletion_service.dart';

void main() {
  late AppDatabase db;
  late List<String> deleted;
  late EntryDeletionService service;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    deleted = [];
    service = EntryDeletionService(
      db: db,
      deleteStoredFile: (path) async => deleted.add(path),
    );
  });

  tearDown(() => db.close());

  Future<int> journal([String title = 'J']) =>
      db.journalsDao.createJournal(JournalsCompanion.insert(title: title));

  Future<int> entry(int journalId) => db.entriesDao.createEntry(
    EntriesCompanion.insert(journalId: journalId, title: const Value('E')),
  );

  Future<int> attachment(int entryId, String path) =>
      db.attachmentsDao.createAttachment(
        AttachmentsCompanion.insert(
          entryId: entryId,
          fileName: 'photo.jpg',
          encryptedPath: path,
          nonceBase64: 'n',
          keyReference: 'k',
          sizeBytes: 1,
        ),
      );

  Future<void> voiceNote(int entryId, String path) =>
      db.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: entryId,
          fileName: 'voice.m4a',
          encryptedPath: path,
          nonceBase64: 'n',
          keyReference: 'k',
          durationMs: 1000,
        ),
      );

  test('the plain DAO delete fails for an entry with an attachment', () async {
    // The reason this service exists: attachments.entry_id has no cascade.
    final e = await entry(await journal());
    await attachment(e, 'a.bin');
    expect(() => db.entriesDao.deleteEntryById(e), throwsA(anything));
  });

  test('deleteEntry removes rows and files of that entry only', () async {
    final j = await journal();
    final e = await entry(j);
    final other = await entry(j);
    final a = await attachment(e, 'a.bin');
    await db.attachmentLocksDao.lockAttachment(
      AttachmentLocksCompanion.insert(attachmentId: a),
    );
    await voiceNote(e, 'v.bin');
    await attachment(other, 'keep.bin');

    await service.deleteEntry(e);

    final entries = await db.select(db.entries).get();
    expect(entries.map((x) => x.id), [other]);
    final attachments = await db.select(db.attachments).get();
    expect(attachments.map((x) => x.encryptedPath), ['keep.bin']);
    expect(await db.select(db.voiceNotes).get(), isEmpty);
    expect(await db.select(db.attachmentLocks).get(), isEmpty);
    expect(deleted, unorderedEquals(['a.bin', 'v.bin']));
  });

  test(
    'deleteJournal removes the journal, its tags, entries and files',
    () async {
      final j = await journal('Old');
      final keep = await journal('Keep');
      final e1 = await entry(j);
      final e2 = await entry(j);
      final kept = await entry(keep);
      await attachment(e1, 'one.bin');
      await voiceNote(e2, 'two.bin');
      await attachment(kept, 'kept.bin');
      final tag = await db.tagsDao.createTag(TagsCompanion.insert(name: 't'));
      await db.journalTagsDao.addTagToJournal(j, tag);

      await service.deleteJournal(j);

      final journals = await db.journalsDao.getAllJournals();
      expect(journals.map((x) => x.id), [keep]);
      expect((await db.select(db.entries).get()).map((x) => x.id), [kept]);
      expect(await db.select(db.journalTags).get(), isEmpty);
      expect(deleted, unorderedEquals(['one.bin', 'two.bin']));
    },
  );

  test('deleteJournal is all or nothing, and keeps files on failure', () async {
    final j = await journal();
    final e = await entry(j);
    await attachment(e, 'a.bin');
    // A row the service does not know about keeps the journal referenced, so
    // the final journal delete fails inside the transaction.
    await db.customStatement(
      'CREATE TABLE blocker (journal_id INTEGER REFERENCES journals(id))',
    );
    await db.customStatement('INSERT INTO blocker VALUES ($j)');

    await expectLater(service.deleteJournal(j), throwsA(anything));

    expect(await db.journalsDao.getAllJournals(), hasLength(1));
    expect(await db.select(db.entries).get(), hasLength(1));
    expect(await db.select(db.attachments).get(), hasLength(1));
    expect(deleted, isEmpty);
  });

  test('deleteAttachment removes the row and the file', () async {
    final e = await entry(await journal());
    final a = await attachment(e, 'a.bin');
    await attachment(e, 'b.bin');

    await service.deleteAttachment(a);

    final left = await db.select(db.attachments).get();
    expect(left.map((x) => x.encryptedPath), ['b.bin']);
    expect(deleted, ['a.bin']);
  });

  test('deleteAttachment on a missing id does nothing', () async {
    await service.deleteAttachment(999);
    expect(deleted, isEmpty);
  });

  test('a file that cannot be deleted does not fail the delete', () async {
    final e = await entry(await journal());
    await attachment(e, 'a.bin');
    final failing = EntryDeletionService(
      db: db,
      deleteStoredFile: (_) async => throw StateError('busy'),
    );

    await failing.deleteEntry(e);

    expect(await db.select(db.entries).get(), isEmpty);
  });

  group('deleteUnreferencedAttachments', () {
    Future<void> saveContent(int entryId, List<int> shownDrawingIds) =>
        db.entriesDao.updateEntryById(
          entryId,
          EntriesCompanion(
            contentJson: Value(
              jsonEncode([
                for (final id in shownDrawingIds)
                  {
                    'insert': {
                      'drawing': jsonEncode({'attachmentId': id}),
                    },
                  },
                {'insert': '\n'},
              ]),
            ),
          ),
        );

    test(
      'deletes only listed attachments the saved text no longer shows',
      () async {
        final e = await entry(await journal());
        final shown = await attachment(e, 'shown.bin');
        final replaced = await attachment(e, 'replaced.bin');
        final notListed = await attachment(e, 'tray-only.bin');
        await saveContent(e, [shown]);

        final count = await service.deleteUnreferencedAttachments(e, {
          shown,
          replaced,
        });

        expect(count, 1);
        final left = await db.select(db.attachments).get();
        expect(left.map((a) => a.id), unorderedEquals([shown, notListed]));
        expect(deleted, ['replaced.bin']);
      },
    );

    test('never touches an attachment of another entry', () async {
      final j = await journal();
      final e = await entry(j);
      final other = await entry(j);
      final foreign = await attachment(other, 'other.bin');
      await saveContent(e, []);

      final count = await service.deleteUnreferencedAttachments(e, {foreign});

      expect(count, 0);
      expect(await db.select(db.attachments).get(), hasLength(1));
      expect(deleted, isEmpty);
    });

    test('unreadable saved content deletes nothing', () async {
      final e = await entry(await journal());
      final a = await attachment(e, 'a.bin');
      await db.entriesDao.updateEntryById(
        e,
        const EntriesCompanion(contentJson: Value('{not json')),
      );

      final count = await service.deleteUnreferencedAttachments(e, {a});

      expect(count, 0);
      expect(deleted, isEmpty);
    });
  });
}
