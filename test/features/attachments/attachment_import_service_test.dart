import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';

void main() {
  group('AttachmentImportService', () {
    late AppDatabase database;
    late _FakeAttachmentCryptoStorage storage;
    late AttachmentImportService service;

    setUp(() {
      database = AppDatabase.forExecutor(NativeDatabase.memory());
      storage = _FakeAttachmentCryptoStorage();
      service = AttachmentImportService(storage);
    });

    tearDown(() async {
      await database.close();
    });

    test('persists encryption metadata for imported attachments', () async {
      final journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Vault'),
      );
      final entryId = await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: const Value('Entry'),
          contentJson: const Value('[]'),
        ),
      );

      await service.importToEntry(
        database: database,
        entryId: entryId,
        picked: const PickedAttachmentData(
          fileName: 'document.pdf',
          mimeType: 'application/pdf',
          bytes: [1, 2, 3, 4],
        ),
      );

      final attachments = await database.attachmentsDao.getAttachmentsForEntry(
        entryId,
      );
      expect(attachments, hasLength(1));
      expect(attachments.single.encryptedPath, 'docs/attachments/file.enc');
      expect(attachments.single.nonceBase64, 'nonce==');
      expect(attachments.single.keyReference, 'android_keystore_wrapped_v1');
      expect(attachments.single.sizeBytes, 4);
      expect(storage.deletedPaths, isEmpty);
    });

    test('deletes encrypted file when metadata persistence fails', () async {
      await expectLater(
        service.importToEntry(
          database: database,
          entryId: 9999,
          picked: const PickedAttachmentData(
            fileName: 'document.pdf',
            mimeType: 'application/pdf',
            bytes: [1, 2, 3, 4],
          ),
        ),
        throwsA(anything),
      );

      expect(storage.deletedPaths, ['docs/attachments/file.enc']);
    });
  });
}

class _FakeAttachmentCryptoStorage implements AttachmentCryptoStorage {
  final List<String> deletedPaths = [];

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {
    deletedPaths.add(encryptedPath);
  }

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) async {
    return StoredAttachmentPayload(
      encryptedPath: 'docs/attachments/file.enc',
      nonceBase64: 'nonce==',
      keyReference: 'android_keystore_wrapped_v1',
      sizeBytes: sourceBytes.length,
    );
  }

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) {
    return false;
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) {
    throw UnimplementedError();
  }
}
