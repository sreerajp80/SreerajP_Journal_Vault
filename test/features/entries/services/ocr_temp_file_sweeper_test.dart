import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/features/entries/services/ocr_temp_file_sweeper.dart';

void main() {
  late Directory root;
  late Directory cache;
  late Directory outside;
  final now = DateTime(2026, 9, 19, 12);

  setUp(() {
    root = Directory.systemTemp.createTempSync('ocr_sweeper_test_');
    cache = Directory(p.join(root.path, 'cache'))..createSync();
    outside = Directory(p.join(root.path, 'gallery'))..createSync();
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  CacheOcrTempFileSweeper sweeper() => CacheOcrTempFileSweeper(
    cacheDirectory: () async => cache,
    now: () => now,
  );

  File makeFile(Directory dir, String name, {Duration age = Duration.zero}) {
    final file = File(p.join(dir.path, name))..writeAsStringSync('pixels');
    file.setLastModifiedSync(now.subtract(age));
    return file;
  }

  group('deleteNow', () {
    test('deletes a scan photo inside the cache', () async {
      final photo = makeFile(cache, 'CAP123.jpg');

      await sweeper().deleteNow(photo.path);

      expect(photo.existsSync(), isFalse);
      expect(cache.existsSync(), isTrue);
    });

    test("removes the picker's own folder once it is empty", () async {
      final folder = Directory(p.join(cache.path, 'a1b2c3'))..createSync();
      final copy = makeFile(folder, 'IMG_0001.jpg');

      await sweeper().deleteNow(copy.path);

      expect(copy.existsSync(), isFalse);
      expect(folder.existsSync(), isFalse);
    });

    test('keeps a folder that still holds other files', () async {
      final folder = Directory(p.join(cache.path, 'shared'))..createSync();
      final copy = makeFile(folder, 'one.jpg');
      final other = makeFile(folder, 'two.jpg');

      await sweeper().deleteNow(copy.path);

      expect(copy.existsSync(), isFalse);
      expect(other.existsSync(), isTrue);
    });

    test('never touches a file outside the cache', () async {
      final users = makeFile(outside, 'CAP_holiday.jpg');

      await sweeper().deleteNow(users.path);

      expect(users.existsSync(), isTrue);
    });

    test('ignores a missing, empty or null path', () async {
      await sweeper().deleteNow(null);
      await sweeper().deleteNow('');
      await sweeper().deleteNow(p.join(cache.path, 'gone.png'));
    });
  });

  group('sweepStale picker folders', () {
    const uuid = '3f2b8c1e-9a4d-4e2f-8b7c-1d2e3f4a5b6c';

    test('deletes an old picker folder holding only files', () async {
      final folder = Directory(p.join(cache.path, uuid))..createSync();
      makeFile(folder, 'IMG_1.jpg', age: const Duration(minutes: 5));

      expect(await sweeper().sweepStale(), 1);
      expect(folder.existsSync(), isFalse);
    });

    test('keeps a picker folder whose photo is new', () async {
      final folder = Directory(p.join(cache.path, uuid))..createSync();
      makeFile(folder, 'IMG_1.jpg');

      await sweeper().sweepStale();
      expect(folder.existsSync(), isTrue);
    });

    test('keeps folders that are not the picker\'s', () async {
      final named = Directory(p.join(cache.path, 'WebView'))..createSync();
      makeFile(named, 'data', age: const Duration(days: 2));
      final nested = Directory(p.join(cache.path, uuid))..createSync();
      makeFile(nested, 'IMG_1.jpg', age: const Duration(days: 2));
      Directory(p.join(nested.path, 'inner')).createSync();

      await sweeper().sweepStale();
      expect(named.existsSync(), isTrue);
      expect(nested.existsSync(), isTrue);
    });
  });

  group('sweepStale', () {
    test('deletes old scan files and keeps everything else', () async {
      const old = Duration(minutes: 5);
      final oldFiles = [
        makeFile(cache, 'CAP99.jpg', age: old),
        makeFile(cache, 'image_picker123.jpg', age: old),
        makeFile(cache, 'image_cropper_1.png', age: old),
        makeFile(cache, 'ocr_cap_1.png', age: old),
        makeFile(cache, 'ocr_enh_1.png', age: old),
        makeFile(cache, 'ocr_prep_1.png', age: old),
        makeFile(cache, 'ocr_rot_1.png', age: old),
      ];
      final fresh = makeFile(cache, 'ocr_enh_2.png');
      final unrelated = makeFile(cache, 'backup.tmp', age: old);
      final folder = Directory(p.join(cache.path, 'ocr_enh_folder'))
        ..createSync();

      final deleted = await sweeper().sweepStale();

      expect(deleted, oldFiles.length);
      for (final file in oldFiles) {
        expect(file.existsSync(), isFalse, reason: file.path);
      }
      expect(fresh.existsSync(), isTrue);
      expect(unrelated.existsSync(), isTrue);
      expect(folder.existsSync(), isTrue);
    });

    test('never looks outside the cache', () async {
      final users = makeFile(outside, 'CAP1.jpg', age: const Duration(days: 1));

      await sweeper().sweepStale();

      expect(users.existsSync(), isTrue);
    });

    test('returns 0 when the cache folder does not exist', () async {
      cache.deleteSync(recursive: true);
      expect(await sweeper().sweepStale(), 0);
    });
  });

  test('tempDirectory falls back to the system temp folder', () async {
    final failing = CacheOcrTempFileSweeper(
      cacheDirectory: () async => throw const FileSystemException('none'),
    );
    expect((await failing.tempDirectory()).path, Directory.systemTemp.path);
  });
}
