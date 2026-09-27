import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_editor_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_revision_service.dart';

void main() {
  late AppDatabase db;
  late EntryEditorService service;
  late int journalId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = EntryEditorService(
      db: db,
      importService: () =>
          throw StateError('attachment storage must not be read'),
      revisionService: EntryRevisionService(db),
    );
    journalId = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
  });

  tearDown(() => db.close());

  test('createEntry and loadEntry round trip', () async {
    final id = await service.createEntry(
      journalId: journalId,
      title: 'Hello',
      contentJson: '[{"insert":"Hi\\n"}]',
    );

    final entry = await service.loadEntry(id);
    expect(entry.title, 'Hello');
    expect(entry.contentJson, '[{"insert":"Hi\\n"}]');
    expect((await service.loadJournal(journalId)).title, 'J');
  });

  test('the editor opens without touching attachment storage', () async {
    // Only addAttachment reads it; the lookup above throws if anything else
    // does.
    final id = await service.createEntry(
      journalId: journalId,
      title: null,
      contentJson: null,
    );
    await service.updateContentJson(id, '[{"insert":"x\\n"}]');
    expect(() => service.addAttachment(id, _picked), throwsStateError);
  });

  test('saveContent keeps the stored text as a revision and saves', () async {
    final target = await service.createEntry(
      journalId: journalId,
      title: 'Target',
      contentJson: null,
    );
    final id = await service.createEntry(
      journalId: journalId,
      title: 'Old',
      contentJson: '[{"insert":"old\\n"}]',
    );

    await service.saveContent(
      id,
      title: 'New',
      contentJson: '[{"insert":"new\\n"}]',
      plainText: 'see [[entry:$target]]',
    );

    final entry = await service.loadEntry(id);
    expect(entry.title, 'New');
    expect(entry.plainText, 'see [[entry:$target]]');
    final revisions = await db.entryRevisionsDao.getRevisionsForEntry(id);
    expect(revisions.single.contentJson, '[{"insert":"old\\n"}]');
    final links = await service.backlinksTo(target);
    expect(links.map((l) => l.sourceEntryId), [id]);
  });

  test('saveContent makes no revision when nothing was stored yet', () async {
    final id = await service.createEntry(
      journalId: journalId,
      title: null,
      contentJson: '[]',
    );

    await service.saveContent(
      id,
      title: 'T',
      contentJson: '[{"insert":"a\\n"}]',
      plainText: 'a',
    );

    expect(await db.entryRevisionsDao.getRevisionsForEntry(id), isEmpty);
  });

  test('attachmentsForEntry lists that entry only', () async {
    final a = await service.createEntry(
      journalId: journalId,
      title: null,
      contentJson: null,
    );
    final b = await service.createEntry(
      journalId: journalId,
      title: null,
      contentJson: null,
    );
    for (final entryId in [a, b]) {
      await db.attachmentsDao.createAttachment(
        AttachmentsCompanion.insert(
          entryId: entryId,
          fileName: 'f$entryId',
          encryptedPath: 'p$entryId',
          nonceBase64: 'n',
          keyReference: 'k',
          sizeBytes: 1,
          mimeType: const Value('image/png'),
        ),
      );
    }

    final list = await service.attachmentsForEntry(a);
    expect(list.map((x) => x.fileName), ['f$a']);
  });
}

const _picked = PickedAttachmentData(
  fileName: 'photo.png',
  mimeType: 'image/png',
  bytes: [1, 2, 3],
);
