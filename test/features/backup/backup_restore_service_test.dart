import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
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

  group('reading an archive', () {
    test('rejects the wrong password', () async {
      await seedJournalData(db, cipher);
      final backup = await backupService.createBackup(
        password: testBackupPassword,
      );

      expect(
        () => restoreService.inspect(
          backupPath: backup.path,
          password: 'a-different-password',
        ),
        throwsA(
          isA<BackupCorruptedException>().having(
            (e) => e.isWrongPassword,
            'isWrongPassword',
            isTrue,
          ),
        ),
      );
    });

    test('rejects a newer archive format', () async {
      final path = await writeArchive(
        manifest: {'formatVersion': backupFormatVersion + 1},
        tables: const {'journals': []},
      );

      expect(
        () => restoreService.inspect(
          backupPath: path,
          password: testBackupPassword,
        ),
        throwsA(
          isA<BackupVersionTooNewException>().having(
            (e) => e.isSchemaVersion,
            'isSchemaVersion',
            isFalse,
          ),
        ),
      );
    });

    test('rejects a newer database schema', () async {
      final path = await writeArchive(
        manifest: {
          'formatVersion': backupFormatVersion,
          'schemaVersion': db.schemaVersion + 1,
        },
        tables: const {'journals': []},
      );

      expect(
        () => restoreService.inspect(
          backupPath: path,
          password: testBackupPassword,
        ),
        throwsA(
          isA<BackupVersionTooNewException>().having(
            (e) => e.isSchemaVersion,
            'isSchemaVersion',
            isTrue,
          ),
        ),
      );
    });

    test(
      'accepts an older archive that has no version fields at all',
      () async {
        final path = await writeArchive(
          manifest: {'version': 1, 'entryCount': 0},
          tables: {
            'journals': [
              {
                'id': 7,
                'title': 'Old journal',
                'createdAt': '2025-01-01T00:00:00.000Z',
                'updatedAt': '2025-01-01T00:00:00.000Z',
              },
            ],
          },
          legacyEnvelope: true,
        );

        final preview = await restoreService.inspect(
          backupPath: path,
          password: testBackupPassword,
        );

        expect(preview.manifest.formatVersion, 1);
        expect(preview.hasPortableAttachments, isFalse);
        expect(preview.journalCount, 1);
      },
    );

    test('reports what the archive holds', () async {
      await seedJournalData(db, cipher);
      final backup = await backupService.createBackup(
        password: testBackupPassword,
      );

      final preview = await restoreService.inspect(
        backupPath: backup.path,
        password: testBackupPassword,
      );

      expect(preview.manifest.formatVersion, backupFormatVersion);
      expect(preview.manifest.schemaVersion, db.schemaVersion);
      expect(preview.entryCount, 1);
      expect(preview.journalCount, 1);
      expect(preview.attachmentCount, 1);
      expect(preview.attachmentFileCount, 1);
      expect(preview.hasPortableAttachments, isTrue);
      expect(preview.sizeBytes, greaterThan(0));
    });
  });

  group('passwords', () {
    test('a short password cannot create a backup', () async {
      expect(
        () => backupService.createBackup(password: 'short'),
        throwsA(isA<BackupPasswordException>()),
      );
    });
  });

  group('dry run', () {
    test('writes nothing but reports what would be added', () async {
      final seeded = await seedJournalData(db, cipher);
      final backup = await backupService.createBackup(
        password: testBackupPassword,
      );
      final storedFilesBefore = cipher.files.length;

      // Clear the database so the archive's rows are all new.
      await db.delete(db.entryMoods).go();
      await db.delete(db.backlinks).go();
      await db.delete(db.entryRevisions).go();
      await db.delete(db.attachments).go();
      await db.delete(db.entryTags).go();
      await db.delete(db.journalTags).go();
      await db.delete(db.entries).go();
      await db.delete(db.tags).go();
      await db.delete(db.journals).go();
      await db.delete(db.searchPresets).go();

      final result = await restoreService.restore(
        backupPath: backup.path,
        password: testBackupPassword,
        mode: RestoreMode.merge,
        dryRun: true,
      );

      expect(result.wasDryRun, isTrue);
      expect(result.entriesAdded, 1);
      expect(result.tables['journals']?.added, 1);

      // Nothing was written: no rows, no files, no restore log.
      expect(await db.select(db.journals).get(), isEmpty);
      expect(cipher.files.length, storedFilesBefore);
      final logs = await db.backupLogsDao.getAllLogs();
      expect(logs.where((l) => l.trigger == 'restore'), isEmpty);
      expect(seeded.entryId, isPositive);
    });
  });

  group('merge', () {
    test('adds what is missing and skips what is already there', () async {
      await seedJournalData(db, cipher);
      final backup = await backupService.createBackup(
        password: testBackupPassword,
      );

      // Add a second entry that the archive does not know about.
      final journals = await db.select(db.journals).get();
      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journals.single.id,
              title: const Value('Written after the backup'),
              createdAt: Value(DateTime.utc(2026, 6, 15)),
              updatedAt: Value(DateTime.utc(2026, 6, 15)),
            ),
          );

      final result = await restoreService.restore(
        backupPath: backup.path,
        password: testBackupPassword,
        mode: RestoreMode.merge,
      );

      // Everything in the archive was already present.
      expect(result.entriesAdded, 0);
      expect(result.entriesSkipped, 1);
      expect(result.tables['journals']?.skipped, 1);
      expect(result.tables['tags']?.skipped, 1);

      // And the newer entry survived the merge.
      final entries = await db.select(db.entries).get();
      expect(entries.length, 2);
      expect(
        entries.map((e) => e.title),
        containsAll(<String>['First day', 'Written after the backup']),
      );

      // A merge takes no safety backup — nothing is being replaced.
      expect(result.safetyBackupPath, isNull);
    });

    test('reassigns ids instead of reusing the archive\'s', () async {
      final other = AppDatabase.forExecutor(NativeDatabase.memory());
      final otherCipher = FakeBackupAttachmentCipher();
      final otherBackupDir = await createTempBackupDir();
      addTearDown(() async {
        await other.close();
        await otherBackupDir.delete(recursive: true);
      });

      // Make a backup of a different journal, whose ids start at 1 as well.
      await seedJournalData(
        other,
        otherCipher,
        journalTitle: 'Work',
        entryTitle: 'Standup notes',
      );
      final backup = await BackupService(
        other,
        cipher: otherCipher,
        envelope: testEnvelope(),
        backupDirectoryProvider: () async => otherBackupDir,
      ).createBackup(password: testBackupPassword);

      // The receiving database already holds row id 1 in every table.
      final seeded = await seedJournalData(db, cipher);
      expect(seeded.journalId, 1);
      expect(seeded.entryId, 1);

      final result =
          await BackupRestoreService(
            db,
            cipher: cipher,
            envelope: testEnvelope(),
          ).restore(
            backupPath: backup.path,
            password: testBackupPassword,
            mode: RestoreMode.merge,
          );

      expect(result.entriesAdded, 1);

      // Both journals are here, and the imported entry points at the imported
      // journal — not at the one that happened to share id 1.
      final journals = await db.select(db.journals).get();
      expect(journals.map((j) => j.title), containsAll(['Travel', 'Work']));

      final workJournal = journals.firstWhere((j) => j.title == 'Work');
      expect(workJournal.id, isNot(1));

      final entries = await db.select(db.entries).get();
      final imported = entries.firstWhere((e) => e.title == 'Standup notes');
      expect(imported.journalId, workJournal.id);

      final travelEntry = entries.firstWhere((e) => e.title == 'First day');
      expect(travelEntry.journalId, seeded.journalId);
    });
  });

  group('replace', () {
    test(
      'makes the database match the archive and keeps a safety backup',
      () async {
        await seedJournalData(db, cipher);
        final backup = await backupService.createBackup(
          password: testBackupPassword,
        );

        // Change the data after the backup was taken: a journal the backup
        // never saw, and an edit to the entry it did see.
        await db
            .into(db.journals)
            .insert(JournalsCompanion.insert(title: 'Added later'));
        await db
            .update(db.entries)
            .write(
              const EntriesCompanion(title: Value('Edited after the backup')),
            );

        final result = await restoreService.restore(
          backupPath: backup.path,
          password: testBackupPassword,
          mode: RestoreMode.replace,
        );

        final journals = await db.select(db.journals).get();
        expect(journals.map((j) => j.title), ['Travel']);

        final entries = await db.select(db.entries).get();
        expect(entries.single.title, 'First day');
        expect(entries.single.journalId, journals.single.id);

        expect(result.safetyBackupPath, isNotNull);
        expect(File(result.safetyBackupPath!).existsSync(), isTrue);

        final logs = await db.backupLogsDao.getAllLogs();
        expect(
          logs.any((l) => l.trigger == 'restore' && l.status == 'success'),
          isTrue,
        );
        expect(logs.any((l) => l.trigger == 'pre_restore'), isTrue);
      },
    );

    test('restores moods and search presets, which version 1 lost', () async {
      await seedJournalData(db, cipher);
      final backup = await backupService.createBackup(
        password: testBackupPassword,
      );

      await db.delete(db.entryMoods).go();
      await db.delete(db.searchPresets).go();

      await restoreService.restore(
        backupPath: backup.path,
        password: testBackupPassword,
        mode: RestoreMode.replace,
      );

      final moods = await db.select(db.entryMoods).get();
      expect(moods.single.mood, 4);
      expect(moods.single.note, 'good day');

      final presets = await db.select(db.searchPresets).get();
      expect(presets.single.name, 'Holidays');
    });
  });

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
