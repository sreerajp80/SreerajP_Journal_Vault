import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/legacy_voice_note_mover.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_saver.dart';

/// Records what was stored; can be told to fail.
class _FakeStorage implements AttachmentCryptoStorage {
  bool failEncrypt = false;
  final List<String> deleted = [];
  int stored = 0;

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) async {
    if (failEncrypt) throw StateError('encrypt failed');
    stored++;
    return StoredAttachmentPayload(
      encryptedPath: 'enc_$stored.bin',
      nonceBase64: 'n',
      keyReference: 'k',
      sizeBytes: sourceBytes.length,
    );
  }

  @override
  Future<void> deleteStoredFile(String encryptedPath) async =>
      deleted.add(encryptedPath);

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) => throw UnimplementedError();

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) => true;

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) => throw UnimplementedError();

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}
}

void main() {
  late AppDatabase db;
  late _FakeStorage storage;
  late VoiceNoteSaver saver;
  late Directory dir;
  late int entryId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    storage = _FakeStorage();
    saver = VoiceNoteSaver(
      importService: AttachmentImportService(storage),
      db: db,
    );
    dir = Directory.systemTemp.createTempSync('voice_saver_test');
    final journal = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    entryId = await db.entriesDao.createEntry(
      EntriesCompanion.insert(journalId: journal, title: const Value('E')),
    );
  });

  tearDown(() async {
    await db.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  File recording([List<int> bytes = const [1, 2, 3]]) =>
      File('${dir.path}/rec.m4a')..writeAsBytesSync(bytes);

  group('VoiceNoteSaver', () {
    test('saves an audio/mp4 attachment and deletes the recording', () async {
      final file = recording();

      final id = await saver.save(
        entryId: entryId,
        recordingPath: file.path,
        fileName: 'Voice note 2026-09-19 09-41.m4a',
      );

      final row = await db.attachmentsDao.getAttachmentById(id);
      expect(row.entryId, entryId);
      expect(row.mimeType, voiceNoteMimeType);
      expect(row.fileName, 'Voice note 2026-09-19 09-41.m4a');
      expect(row.sizeBytes, 3);
      expect(file.existsSync(), isFalse);
    });

    test('no entry: fails and still deletes the recording', () async {
      final file = recording();

      await expectLater(
        saver.save(entryId: null, recordingPath: file.path, fileName: 'x.m4a'),
        throwsA(isA<VoiceNoteSaveException>()),
      );
      expect(file.existsSync(), isFalse);
      expect(await db.select(db.attachments).get(), isEmpty);
    });

    test('empty recording: fails and deletes it', () async {
      final file = recording(const []);

      await expectLater(
        saver.save(
          entryId: entryId,
          recordingPath: file.path,
          fileName: 'x.m4a',
        ),
        throwsA(isA<VoiceNoteSaveException>()),
      );
      expect(file.existsSync(), isFalse);
    });

    test('encryption failure: fails and deletes the recording', () async {
      storage.failEncrypt = true;
      final file = recording();

      await expectLater(
        saver.save(
          entryId: entryId,
          recordingPath: file.path,
          fileName: 'x.m4a',
        ),
        throwsA(isA<StateError>()),
      );
      expect(file.existsSync(), isFalse);
    });

    test('database failure: removes the encrypted file too', () async {
      final file = recording();

      await expectLater(
        saver.save(
          entryId: 999999,
          recordingPath: file.path,
          fileName: 'x.m4a',
        ),
        throwsA(anything),
      );
      expect(file.existsSync(), isFalse);
      expect(storage.deleted, ['enc_1.bin']);
    });
  });

  test('voiceNoteTimestamp pads every part', () {
    expect(voiceNoteTimestamp(DateTime(2026, 9, 1, 7, 5)), '2026-09-01 07-05');
  });

  group('LegacyVoiceNoteMover', () {
    Future<void> legacyNote(String path, String name) =>
        db.voiceNotesDao.createVoiceNote(
          VoiceNotesCompanion.insert(
            entryId: entryId,
            fileName: name,
            encryptedPath: path,
            nonceBase64: 'nonce',
            keyReference: 'key',
            durationMs: 4000,
          ),
        );

    test('moves each note to attachments with the same file', () async {
      final encrypted = File('${dir.path}/old.bin')
        ..writeAsBytesSync(List.filled(116, 0));
      await legacyNote(encrypted.path, 'voice_abc.m4a');
      await legacyNote('content://tree/doc', 'voice_sd');

      final moved = await LegacyVoiceNoteMover(db).moveAll();

      expect(moved, 2);
      expect(await db.select(db.voiceNotes).get(), isEmpty);
      final rows = await db.select(db.attachments).get();
      expect(rows, hasLength(2));
      final local = rows.firstWhere((r) => r.encryptedPath == encrypted.path);
      expect(local.fileName, 'voice_abc.m4a');
      expect(local.mimeType, voiceNoteMimeType);
      expect(local.nonceBase64, 'nonce');
      expect(local.keyReference, 'key');
      expect(local.sizeBytes, 100);
      final sd = rows.firstWhere(
        (r) => r.encryptedPath == 'content://tree/doc',
      );
      expect(sd.fileName, 'voice_sd.m4a');
      expect(sd.sizeBytes, 0);
      // The file itself is untouched.
      expect(encrypted.existsSync(), isTrue);
    });

    test('a second run does nothing', () async {
      await legacyNote('a.bin', 'a.m4a');
      await LegacyVoiceNoteMover(db).moveAll();

      expect(await LegacyVoiceNoteMover(db).moveAll(), 0);
      expect(await db.select(db.attachments).get(), hasLength(1));
    });
  });
}
