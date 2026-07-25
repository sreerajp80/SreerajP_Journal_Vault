import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_key_manager.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AesGcmAttachmentCryptoStorage', () {
    late Directory sandboxRoot;
    late AttachmentTempFileManager tempFileManager;
    late AesGcmAttachmentCryptoStorage storage;

    setUp(() async {
      sandboxRoot = await Directory.systemTemp.createTemp(
        'attachment_crypto_storage_test_',
      );
      tempFileManager = AttachmentTempFileManager(
        cacheDirectoryProvider: () async =>
            Directory('${sandboxRoot.path}${Platform.pathSeparator}cache'),
        backgroundCleanupDelay: const Duration(milliseconds: 25),
      );
      storage = AesGcmAttachmentCryptoStorage(
        algorithm: AesGcm.with256bits(),
        keyManager: _InMemoryAttachmentKeyManager(),
        tempFileManager: tempFileManager,
        documentsDirectoryProvider: () async =>
            Directory('${sandboxRoot.path}${Platform.pathSeparator}docs'),
      );
      await tempFileManager.start();
    });

    tearDown(() async {
      tempFileManager.dispose();
      if (await sandboxRoot.exists()) {
        await sandboxRoot.delete(recursive: true);
      }
    });

    test(
      'encrypts to app documents storage and decrypts back to plaintext',
      () async {
        final payload = await storage.encryptAndStore(
          sourceBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
          sourceFileName: 'sample.pdf',
        );

        expect(
          payload.encryptedPath,
          contains(attachmentEncryptedDirectoryName),
        );
        expect(payload.keyReference, activeAttachmentKeyReference);
        expect(payload.sizeBytes, 5);

        final encryptedFile = File(payload.encryptedPath);
        expect(await encryptedFile.exists(), isTrue);
        expect(await encryptedFile.readAsBytes(), isNot([1, 2, 3, 4, 5]));

        final handle = await storage.decryptToTempFile(
          encryptedPath: payload.encryptedPath,
          nonceBase64: payload.nonceBase64,
          keyReference: payload.keyReference,
          fileName: 'sample.pdf',
        );
        expect(await handle.file.readAsBytes(), [1, 2, 3, 4, 5]);

        await handle.release();
        expect(await handle.file.exists(), isFalse);
      },
    );

    test('deletes encrypted files during persistence cleanup', () async {
      final payload = await storage.encryptAndStore(
        sourceBytes: Uint8List.fromList([8, 7, 6]),
        sourceFileName: 'cleanup.pdf',
      );

      final encryptedFile = File(payload.encryptedPath);
      expect(await encryptedFile.exists(), isTrue);

      await storage.deleteStoredFile(payload.encryptedPath);

      expect(await encryptedFile.exists(), isFalse);
    });

    test('fails safely for corrupted payloads', () async {
      final encryptedRoot = Directory(
        '${sandboxRoot.path}${Platform.pathSeparator}docs${Platform.pathSeparator}$attachmentEncryptedDirectoryName',
      );
      await encryptedRoot.create(recursive: true);
      final encryptedFile = File(
        '${encryptedRoot.path}${Platform.pathSeparator}broken.bin',
      );
      await encryptedFile.writeAsBytes([1, 2, 3], flush: true);

      expect(
        () => storage.decryptToTempFile(
          encryptedPath: encryptedFile.path,
          nonceBase64: 'abcd',
          keyReference: activeAttachmentKeyReference,
          fileName: 'broken.pdf',
        ),
        throwsA(isA<AttachmentOpenException>()),
      );
    });
  });
}

class _InMemoryAttachmentKeyManager implements AttachmentKeyManager {
  final Map<String, SecretKey> _keys = {};

  @override
  Future<AttachmentKeyMaterial> getOrCreateActiveKey() async {
    final key = _keys.putIfAbsent(
      activeAttachmentKeyReference,
      () => SecretKey(List<int>.generate(32, (index) => index + 1)),
    );
    return AttachmentKeyMaterial(
      keyReference: activeAttachmentKeyReference,
      secretKey: key,
    );
  }

  @override
  Future<SecretKey> loadKey(String keyReference) async {
    final key = _keys[keyReference];
    if (key == null) {
      throw AttachmentKeyUnavailableException(keyReference);
    }
    return key;
  }
}
