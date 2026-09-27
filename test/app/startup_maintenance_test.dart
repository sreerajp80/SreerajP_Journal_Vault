import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/app/startup_maintenance.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory root;
  late Directory cache;
  late Directory docs;
  late Directory encrypted;
  late AttachmentTempFileManager manager;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    root = Directory.systemTemp.createTempSync('startup_maintenance_test_');
    cache = Directory(p.join(root.path, 'cache'))..createSync();
    docs = Directory(p.join(root.path, 'docs'))..createSync();
    encrypted = Directory(p.join(docs.path, attachmentEncryptedDirectoryName))
      ..createSync();
    manager = AttachmentTempFileManager(
      cacheDirectoryProvider: () async => cache,
    );
  });

  tearDown(() async {
    manager.dispose();
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  File oldFile(Directory dir, String name) {
    dir.createSync(recursive: true);
    return File(p.join(dir.path, name))
      ..writeAsStringSync('x')
      ..setLastModifiedSync(DateTime.now().subtract(const Duration(days: 1)));
  }

  test('moves old voice notes and clears every kind of leftover', () async {
    final journal = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final entry = await db.entriesDao.createEntry(
      EntriesCompanion.insert(journalId: journal, title: const Value('E')),
    );
    final voice = oldFile(encrypted, 'voice.bin');
    await db.voiceNotesDao.createVoiceNote(
      VoiceNotesCompanion.insert(
        entryId: entry,
        fileName: 'voice_1.m4a',
        encryptedPath: voice.path,
        nonceBase64: 'n',
        keyReference: 'k',
        durationMs: 1000,
      ),
    );
    final kept = oldFile(encrypted, 'kept.bin');
    await db.attachmentsDao.createAttachment(
      AttachmentsCompanion.insert(
        entryId: entry,
        fileName: 'photo.jpg',
        encryptedPath: kept.path,
        nonceBase64: 'n',
        keyReference: 'k',
        sizeBytes: 1,
      ),
    );
    final orphan = oldFile(encrypted, 'orphan.bin');
    final decrypted = oldFile(
      Directory(p.join(cache.path, attachmentTempDirectoryName)),
      'diary.pdf',
    );
    final picked = oldFile(
      Directory(p.join(cache.path, 'file_picker', '1')),
      'a.jpg',
    );
    final scan = oldFile(cache, 'CAP1.jpg');

    await runStartupMaintenance(
      database: db,
      tempFileManager: manager,
      cacheDirectory: () async => cache,
      documentsDirectory: () async => docs,
    );

    // The voice note is now an attachment, and its file is kept.
    expect(await db.select(db.voiceNotes).get(), isEmpty);
    final attachments = await db.select(db.attachments).get();
    expect(
      attachments.map((a) => a.encryptedPath),
      containsAll([voice.path, kept.path]),
    );
    expect(voice.existsSync(), isTrue);
    expect(kept.existsSync(), isTrue);
    // Everything else is gone.
    expect(orphan.existsSync(), isFalse);
    expect(decrypted.existsSync(), isFalse);
    expect(picked.existsSync(), isFalse);
    expect(scan.existsSync(), isFalse);
  });

  test('starts even when the folders are missing', () async {
    root.deleteSync(recursive: true);

    await runStartupMaintenance(
      database: db,
      tempFileManager: manager,
      cacheDirectory: () async => cache,
      documentsDirectory: () async => docs,
    );
  });
}
