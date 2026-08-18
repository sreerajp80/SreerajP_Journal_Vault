import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/restore_models.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_restore_service.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';

import 'backup_test_support.dart';

/// The test the whole feature exists for: back up one device, restore onto a
/// different one, and get the journal back.
///
/// The second database and the second cipher share nothing with the first —
/// no rows, no stored files, no keys — which is what a new phone looks like.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase source;
  late AppDatabase target;
  late FakeBackupAttachmentCipher sourceCipher;
  late FakeBackupAttachmentCipher targetCipher;
  late Directory backupDir;

  setUp(() async {
    source = AppDatabase.forExecutor(NativeDatabase.memory());
    target = AppDatabase.forExecutor(NativeDatabase.memory());
    sourceCipher = FakeBackupAttachmentCipher();
    targetCipher = FakeBackupAttachmentCipher();
    backupDir = await createTempBackupDir();
  });

  tearDown(() async {
    await source.close();
    await target.close();
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }
  });

  test('a backup restores onto a fresh device, attachments included', () async {
    final seeded = await seedJournalData(source, sourceCipher);

    final backup = await BackupService(
      source,
      cipher: sourceCipher,
      envelope: testEnvelope(),
      backupDirectoryProvider: () async => backupDir,
    ).createBackup(password: testBackupPassword);

    expect(backup.entryCount, 1);
    expect(backup.filesIncluded, 1);
    expect(backup.filesFailed, 0);

    // Nothing from the first device is reachable here.
    expect(targetCipher.files, isEmpty);
    expect(await target.select(target.journals).get(), isEmpty);

    final result =
        await BackupRestoreService(
          target,
          cipher: targetCipher,
          envelope: testEnvelope(),
        ).restore(
          backupPath: backup.path,
          password: testBackupPassword,
          mode: RestoreMode.replace,
        );

    expect(result.wasDryRun, isFalse);
    expect(result.attachmentFilesRestored, 1);
    expect(result.attachmentFilesFailed, 0);
    expect(result.warnings, isEmpty);

    // Every table came back.
    final journal = (await target.select(target.journals).get()).single;
    expect(journal.title, 'Travel');
    expect(journal.description, 'A trip');

    final entry = (await target.select(target.entries).get()).single;
    expect(entry.title, 'First day');
    expect(entry.plainText, 'hello');
    expect(entry.journalId, journal.id);

    final tag = (await target.select(target.tags).get()).single;
    expect(tag.name, 'holiday');
    expect(tag.colorArgb, 0xff112233);

    final entryTag = (await target.select(target.entryTags).get()).single;
    expect(entryTag.entryId, entry.id);
    expect(entryTag.tagId, tag.id);

    final journalTag = (await target.select(target.journalTags).get()).single;
    expect(journalTag.journalId, journal.id);
    expect(journalTag.tagId, tag.id);

    final revision = (await target.select(target.entryRevisions).get()).single;
    expect(revision.entryId, entry.id);

    final mood = (await target.select(target.entryMoods).get()).single;
    expect(mood.entryId, entry.id);
    expect(mood.mood, 4);

    final preset = (await target.select(target.searchPresets).get()).single;
    expect(preset.query, 'tag:holiday');

    final backlink = (await target.select(target.backlinks).get()).single;
    expect(backlink.sourceEntryId, entry.id);
    expect(backlink.targetType, 'journal');
    expect(backlink.targetId, journal.id);

    // The attachment bytes survived the trip and are readable with this
    // device's key, not the one that wrote the backup.
    final attachment = (await target.select(target.attachments).get()).single;
    expect(attachment.entryId, entry.id);
    expect(attachment.fileName, 'photo.jpg');
    expect(attachment.mimeType, 'image/jpeg');
    expect(targetCipher.files.containsKey(attachment.encryptedPath), isTrue);

    final bytes = await targetCipher.decryptToBytes(
      encryptedPath: attachment.encryptedPath,
      nonceBase64: attachment.nonceBase64,
      keyReference: attachment.keyReference,
      fileName: attachment.fileName,
    );
    expect(bytes, seeded.attachmentBytes);

    // Search still works, so the index was rebuilt rather than left stale.
    final hits = await target.searchEntries('hello');
    expect(hits.map((h) => h.entryId), [entry.id]);
  });

  test(
    'restoring the same backup twice adds nothing the second time',
    () async {
      await seedJournalData(source, sourceCipher);
      final backup = await BackupService(
        source,
        cipher: sourceCipher,
        envelope: testEnvelope(),
        backupDirectoryProvider: () async => backupDir,
      ).createBackup(password: testBackupPassword);

      final service = BackupRestoreService(
        target,
        cipher: targetCipher,
        envelope: testEnvelope(),
      );

      final first = await service.restore(
        backupPath: backup.path,
        password: testBackupPassword,
        mode: RestoreMode.merge,
      );
      final second = await service.restore(
        backupPath: backup.path,
        password: testBackupPassword,
        mode: RestoreMode.merge,
      );

      expect(first.entriesAdded, 1);
      expect(second.entriesAdded, 0);
      expect(second.entriesSkipped, 1);
      expect((await target.select(target.entries).get()).length, 1);
      expect((await target.select(target.journals).get()).length, 1);
      expect((await target.select(target.attachments).get()).length, 1);
    },
  );
}
