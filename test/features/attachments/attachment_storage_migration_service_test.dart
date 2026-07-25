import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_storage_migration_service.dart';

void main() {
  group('AttachmentStorageMigrationService', () {
    late AppDatabase database;
    late _FakeAttachmentCryptoStorage storage;
    late AttachmentStorageMigrationService service;

    setUp(() {
      database = AppDatabase.forExecutor(NativeDatabase.memory());
      storage = _FakeAttachmentCryptoStorage();
      service = AttachmentStorageMigrationService(
        database: database,
        storage: storage,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'migrates encrypted attachments and finalizes SD card settings',
      () async {
        final attachmentId = await _createAttachment(
          database: database,
          encryptedPath: r'C:\vault\attachments\one.enc',
        );
        final progress = <String>[];

        await service.migrateTo(
          targetLocation: AttachmentStorageLocation.sdCard,
          targetTreeUri: 'content://tree/vault',
          targetTreeLabel: 'Journal Card',
          onProgress: (processed, total) => progress.add('$processed/$total'),
        );

        final attachment = (await database.attachmentsDao.getAllAttachments())
            .singleWhere((row) => row.id == attachmentId);
        final settings = await database.appSettingsDao.getSettings();

        expect(attachment.encryptedPath, 'content://vault/1');
        expect(storage.deletedPaths, [r'C:\vault\attachments\one.enc']);
        expect(progress, ['0/1', '1/1']);
        expect(settings.attachmentStorageLocation, 'sd_card');
        expect(settings.attachmentStorageTreeUri, 'content://tree/vault');
        expect(settings.attachmentStorageTreeLabel, 'Journal Card');
        expect(settings.attachmentMigrationStatus, 'idle');
        expect(settings.attachmentMigrationFailure, isNull);
      },
    );

    test(
      'fails without changing attachment metadata when migration copy fails',
      () async {
        await _createAttachment(
          database: database,
          encryptedPath: r'C:\vault\attachments\broken.enc',
        );
        storage.failOnPath = r'C:\vault\attachments\broken.enc';

        await expectLater(
          () => service.migrateTo(
            targetLocation: AttachmentStorageLocation.sdCard,
            targetTreeUri: 'content://tree/vault',
            targetTreeLabel: 'Journal Card',
          ),
          throwsA(isA<AttachmentStorageUnavailableException>()),
        );

        final attachment =
            (await database.attachmentsDao.getAllAttachments()).single;
        final settings = await database.appSettingsDao.getSettings();

        expect(attachment.encryptedPath, r'C:\vault\attachments\broken.enc');
        expect(storage.deletedPaths, isEmpty);
        expect(settings.attachmentStorageLocation, 'app_private');
        expect(settings.attachmentMigrationStatus, 'failed');
        expect(settings.attachmentMigrationTarget, 'sd_card');
        expect(settings.attachmentMigrationFailure, contains('missing'));
      },
    );

    test(
      'converts interrupted migration state into a retryable failure',
      () async {
        await database.appSettingsDao.getSettings();
        await database.appSettingsDao.updateSettings(
          AppSettingsCompanion(
            attachmentMigrationStatus: const Value('running'),
            attachmentMigrationTarget: const Value('sd_card'),
            attachmentMigrationProcessedCount: const Value(2),
            attachmentMigrationTotalCount: const Value(5),
            updatedAt: Value(DateTime.now()),
          ),
        );

        final settings = await service.recoverInterruptedMigrationIfNeeded();

        expect(settings.attachmentMigrationStatus, 'failed');
        expect(settings.attachmentMigrationTarget, 'sd_card');
        expect(
          settings.attachmentMigrationFailure,
          'Attachment migration was interrupted. Retry to continue.',
        );
      },
    );
  });
}

Future<int> _createAttachment({
  required AppDatabase database,
  required String encryptedPath,
}) async {
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
  return database.attachmentsDao.createAttachment(
    AttachmentsCompanion.insert(
      entryId: entryId,
      fileName: 'document.pdf',
      mimeType: const Value('application/pdf'),
      encryptedPath: encryptedPath,
      nonceBase64: 'nonce==',
      keyReference: 'key-1',
      sizeBytes: 1024,
    ),
  );
}

class _FakeAttachmentCryptoStorage implements AttachmentCryptoStorage {
  final List<String> deletedPaths = <String>[];
  String? failOnPath;
  int _nextDocumentId = 1;

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
  }) {
    throw UnimplementedError();
  }

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) {
    return switch (location) {
      AttachmentStorageLocation.appPrivate => !encryptedPath.startsWith(
        'content://',
      ),
      AttachmentStorageLocation.sdCard => encryptedPath.startsWith(
        'content://',
      ),
    };
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {
    if (encryptedPath == failOnPath) {
      throw const AttachmentStorageUnavailableException(
        'The selected SD card is missing.',
      );
    }
    return switch (targetLocation) {
      AttachmentStorageLocation.appPrivate =>
        r'C:\vault\attachments\restored.enc',
      AttachmentStorageLocation.sdCard =>
        'content://vault/${_nextDocumentId++}',
    };
  }
}
