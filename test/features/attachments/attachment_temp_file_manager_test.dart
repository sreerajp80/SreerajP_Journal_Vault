import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttachmentTempFileManager', () {
    late Directory sandboxRoot;
    late AttachmentTempFileManager manager;

    setUp(() async {
      sandboxRoot = await Directory.systemTemp.createTemp(
        'attachment_temp_manager_test_',
      );
      manager = AttachmentTempFileManager(
        cacheDirectoryProvider: () async => sandboxRoot,
        backgroundCleanupDelay: const Duration(milliseconds: 20),
      );
    });

    tearDown(() async {
      manager.dispose();
      if (await sandboxRoot.exists()) {
        await sandboxRoot.delete(recursive: true);
      }
    });

    test('cleans orphan temp files on startup', () async {
      final tempDir = Directory(
        '${sandboxRoot.path}${Platform.pathSeparator}$attachmentTempDirectoryName',
      );
      await tempDir.create(recursive: true);
      final orphanFile = File(
        '${tempDir.path}${Platform.pathSeparator}orphan.txt',
      );
      await orphanFile.writeAsString('plaintext', flush: true);

      await manager.start();

      expect(await orphanFile.exists(), isFalse);
    });

    test('removes temp files when released explicitly', () async {
      await manager.start();
      final handle = await manager.createTempFile(
        bytes: Uint8List.fromList([9, 8, 7]),
        fileName: 'voice.mp3',
      );

      expect(await handle.file.exists(), isTrue);
      await handle.release();
      expect(await handle.file.exists(), isFalse);
    });

    test('background timeout cleans files handed to other apps only', () async {
      await manager.start();
      final handedOff = await manager.createTempFile(
        bytes: Uint8List.fromList([5, 4, 3]),
        fileName: 'archive.zip',
      );
      handedOff.markHandedOff();
      // Still on screen in an in-app viewer, which deletes it itself.
      final inApp = await manager.createTempFile(
        bytes: Uint8List.fromList([1, 2]),
        fileName: 'page.pdf',
      );

      manager.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(await handedOff.file.exists(), isFalse);
      expect(handedOff.isReleased, isTrue);
      expect(await inApp.file.exists(), isTrue);
      expect(inApp.isReleased, isFalse);
    });

    test('released handles are no longer tracked', () async {
      await manager.start();
      final handle = await manager.createTempFile(
        bytes: Uint8List.fromList([7]),
        fileName: 'photo.jpg',
      );
      expect(manager.activeHandleCount, 1);

      await handle.release();

      expect(manager.activeHandleCount, 0);
    });

    test('releases active files when disposed', () async {
      await manager.start();
      final handle = await manager.createTempFile(
        bytes: Uint8List.fromList([1, 3, 5]),
        fileName: 'dispose.pdf',
      );

      manager.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(await handle.file.exists(), isFalse);
      expect(handle.isReleased, isTrue);
    });
  });
}
