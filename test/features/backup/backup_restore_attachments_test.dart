import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/backup_format.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/restore_models.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_restore_service.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';

import 'backup_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeBackupAttachmentCipher cipher;
  late Directory backupDir;
  late BackupService backupService;
  late BackupRestoreService restoreService;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    cipher = FakeBackupAttachmentCipher();
    backupDir = await createTempBackupDir();
    backupService = BackupService(
      db,
      cipher: cipher,
      envelope: testEnvelope(),
      backupDirectoryProvider: () async => backupDir,
    );
    restoreService = BackupRestoreService(
      db,
      cipher: cipher,
      envelope: testEnvelope(),
      backupService: backupService,
    );
  });

  tearDown(() async {
    await db.close();
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }
  });

  /// Writes an archive by hand so a test can control the manifest exactly.
  Future<String> writeArchive({
    required Map<String, dynamic> manifest,
    required Map<String, dynamic> tables,
    String password = testBackupPassword,
    bool legacyEnvelope = false,
    Map<String, List<int>> extraFiles = const {},
  }) async {
    final archive = Archive();
    void add(String name, List<int> bytes) =>
        archive.addFile(ArchiveFile(name, bytes.length, bytes));

    add(backupManifestFileName, utf8.encode(jsonEncode(manifest)));
    add(backupDatabaseFileName, utf8.encode(jsonEncode(tables)));
    extraFiles.forEach(add);

    final zipped = Uint8List.fromList(ZipEncoder().encode(archive));
    final envelope = testEnvelope();
    final sealed = legacyEnvelope
        ? await envelope.sealLegacyV1(plainBytes: zipped, password: password)
        : await envelope.seal(plainBytes: zipped, password: password);

    final file = File('${backupDir.path}${Platform.pathSeparator}hand.vault');
    await file.writeAsBytes(sealed, flush: true);
    return file.path;
  }

  group('attachments', () {
    test('re-encrypts a restored file for this device', () async {
      final seeded = await seedJournalData(db, cipher);
      final backup = await backupService.createBackup(
        password: testBackupPassword,
      );

      final originalRow = (await db.select(db.attachments).get()).single;
      await restoreService.restore(
        backupPath: backup.path,
        password: testBackupPassword,
        mode: RestoreMode.replace,
      );

      final restored = (await db.select(db.attachments).get()).single;
      expect(restored.fileName, 'photo.jpg');

      // A fresh path and a fresh nonce: the file was encrypted again here,
      // not copied byte-for-byte from the archive.
      expect(restored.encryptedPath, isNot(originalRow.encryptedPath));
      expect(restored.nonceBase64, isNot(originalRow.nonceBase64));

      // And the bytes still come back.
      final bytes = await cipher.decryptToBytes(
        encryptedPath: restored.encryptedPath,
        nonceBase64: restored.nonceBase64,
        keyReference: restored.keyReference,
        fileName: restored.fileName,
      );
      expect(bytes, seeded.attachmentBytes);
    });

    test(
      'a file that cannot be stored does not fail the whole restore',
      () async {
        await seedJournalData(db, cipher);
        final backup = await backupService.createBackup(
          password: testBackupPassword,
        );

        final failing = FakeBackupAttachmentCipher(failOnFileName: 'photo.jpg')
          ..files.addAll(cipher.files);

        final result =
            await BackupRestoreService(
              db,
              cipher: failing,
              envelope: testEnvelope(),
            ).restore(
              backupPath: backup.path,
              password: testBackupPassword,
              mode: RestoreMode.replace,
            );

        expect(result.attachmentFilesFailed, 1);
        expect(
          result.warnings,
          contains(RestoreWarning.someAttachmentFilesFailed),
        );

        // The entry and its attachment record survived; only the bytes are gone.
        expect((await db.select(db.entries).get()).length, 1);
        expect((await db.select(db.attachments).get()).length, 1);
      },
    );

    test(
      'warns that a version 1 archive holds device-locked attachments',
      () async {
        final path = await writeArchive(
          manifest: {'version': 1},
          tables: {
            'journals': [
              {
                'id': 1,
                'title': 'Old',
                'createdAt': '2025-01-01T00:00:00.000Z',
                'updatedAt': '2025-01-01T00:00:00.000Z',
              },
            ],
            'entries': [
              {
                'id': 1,
                'journalId': 1,
                'title': 'Old entry',
                'createdAt': '2025-01-01T00:00:00.000Z',
                'updatedAt': '2025-01-01T00:00:00.000Z',
              },
            ],
            'attachments': [
              {
                'id': 5,
                'entryId': 1,
                'fileName': 'old.jpg',
                'encryptedPath': 'gone',
                'nonceBase64': 'old-nonce',
                'keyReference': 'attachment_key_v1',
                'sizeBytes': 3,
                'createdAt': '2025-01-01T00:00:00.000Z',
              },
            ],
          },
          legacyEnvelope: true,
          extraFiles: {
            'attachments/5_old.jpg': const [1, 2, 3],
          },
        );

        final result = await restoreService.restore(
          backupPath: path,
          password: testBackupPassword,
          mode: RestoreMode.replace,
        );

        expect(
          result.warnings,
          contains(RestoreWarning.legacyAttachmentsNotPortable),
        );
        expect(result.attachmentFilesRestored, 1);

        // The old nonce and key reference are kept: the bytes were not touched,
        // so only the original device's key can open them.
        final restored = (await db.select(db.attachments).get()).single;
        expect(restored.nonceBase64, 'old-nonce');
        expect(restored.keyReference, 'attachment_key_v1');
      },
    );
  });

  group('failure handling', () {
    test('a broken archive leaves the database untouched', () async {
      await seedJournalData(db, cipher);

      // An entry pointing at a journal that is not in the archive: the row
      // cannot be inserted, and the restore must not half-apply.
      final path = await writeArchive(
        manifest: {
          'formatVersion': backupFormatVersion,
          'schemaVersion': db.schemaVersion,
        },
        tables: const {
          'journals': [],
          'entries': [
            {
              'id': 1,
              'journalId': 99,
              'title': 'Orphan',
              'createdAt': '2025-01-01T00:00:00.000Z',
              'updatedAt': '2025-01-01T00:00:00.000Z',
            },
          ],
        },
      );

      await restoreService.restore(
        backupPath: path,
        password: testBackupPassword,
        mode: RestoreMode.merge,
      );

      // The orphan row was dropped rather than pointed at the wrong journal.
      final entries = await db.select(db.entries).get();
      expect(entries.map((e) => e.title), ['First day']);
    });

    test('a missing file is reported as a damaged archive', () async {
      expect(
        () => restoreService.inspect(
          backupPath: '${backupDir.path}${Platform.pathSeparator}nope.vault',
          password: testBackupPassword,
        ),
        throwsA(isA<BackupCorruptedException>()),
      );
    });
  });
}
