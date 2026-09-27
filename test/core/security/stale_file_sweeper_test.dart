import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/core/security/stale_file_sweeper.dart';

void main() {
  late Directory root;
  late Directory cache;
  late Directory docs;
  late Directory encrypted;
  final now = DateTime(2026, 9, 19, 12);

  setUp(() {
    root = Directory.systemTemp.createTempSync('stale_sweeper_test_');
    cache = Directory(p.join(root.path, 'cache'))..createSync();
    docs = Directory(p.join(root.path, 'docs'))..createSync();
    encrypted = Directory(p.join(docs.path, attachmentEncryptedDirectoryName))
      ..createSync();
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  StaleFileSweeper sweeper(Future<Iterable<String>> Function() referenced) =>
      StaleFileSweeper(
        cacheDirectory: () async => cache,
        documentsDirectory: () async => docs,
        referencedStoredPaths: referenced,
        now: () => now,
      );

  File makeFile(Directory dir, String name, {Duration age = Duration.zero}) {
    dir.createSync(recursive: true);
    final file = File(p.join(dir.path, name))..writeAsStringSync('x');
    file.setLastModifiedSync(now.subtract(age));
    return file;
  }

  group('clearCacheFolders', () {
    test('deletes the picker, staging and recording folders', () async {
      final picked = makeFile(
        Directory(p.join(cache.path, 'file_picker', '1726')),
        'diary.pdf',
      );
      final staged = makeFile(
        Directory(p.join(cache.path, 'restore_staging')),
        'backup.vault',
      );
      final recording = makeFile(
        Directory(p.join(cache.path, 'voice_rec')),
        'voice_1.m4a',
      );

      final cleared = await sweeper(() async => const []).clearCacheFolders();

      expect(cleared, 3);
      expect(picked.existsSync(), isFalse);
      expect(staged.existsSync(), isFalse);
      expect(recording.existsSync(), isFalse);
    });

    test('keeps everything else in the cache', () async {
      final other = makeFile(Directory(p.join(cache.path, 'WebView')), 'x');
      final loose = makeFile(cache, 'notes.txt');

      await sweeper(() async => const []).clearCacheFolders();

      expect(other.existsSync(), isTrue);
      expect(loose.existsSync(), isTrue);
    });
  });

  group('sweepOrphanedAttachments', () {
    const old = Duration(hours: 2);

    test('deletes an old file no row points at', () async {
      final orphan = makeFile(encrypted, '1_1.bin', age: old);

      expect(await sweeper(() async => const []).sweepOrphanedAttachments(), 1);
      expect(orphan.existsSync(), isFalse);
    });

    test('keeps referenced, new, and SD card-listed files', () async {
      final referenced = makeFile(encrypted, '2_2.bin', age: old);
      final fresh = makeFile(encrypted, '3_3.bin');
      // A row may hold a path from before the app folder moved; the name
      // still matches.
      final movedPath = p.join('old', 'place', '4_4.bin');
      final moved = makeFile(encrypted, '4_4.bin', age: old);

      final deleted = await sweeper(
        () async => [referenced.path, movedPath, 'content://tree/doc/9.bin'],
      ).sweepOrphanedAttachments();

      expect(deleted, 0);
      expect(referenced.existsSync(), isTrue);
      expect(fresh.existsSync(), isTrue);
      expect(moved.existsSync(), isTrue);
    });

    test('touches nothing outside the encrypted folder', () async {
      final database = makeFile(docs, 'journal_vault.sqlite', age: old);
      final backup = makeFile(
        Directory(p.join(docs.path, 'backups')),
        'journal_backup.vault',
        age: old,
      );

      await sweeper(() async => const []).sweepOrphanedAttachments();

      expect(database.existsSync(), isTrue);
      expect(backup.existsSync(), isTrue);
    });

    test('does nothing when the database cannot be read', () async {
      final file = makeFile(encrypted, '5_5.bin', age: old);

      final deleted = await sweeper(
        () async => throw StateError('locked'),
      ).sweepOrphanedAttachments();

      expect(deleted, 0);
      expect(file.existsSync(), isTrue);
    });
  });

  test('run never throws, even without folders', () async {
    root.deleteSync(recursive: true);
    await sweeper(() async => const []).run();
  });
}
