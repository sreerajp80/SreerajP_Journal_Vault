import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_key_manager.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_storage_picker.dart';
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

  group('AesGcmAttachmentCryptoStorage SD card storage', () {
    late Directory sandboxRoot;
    late AttachmentTempFileManager tempFileManager;
    late _FakeStorageDocumentClient documentClient;
    late AttachmentStorageTarget target;
    late AesGcmAttachmentCryptoStorage storage;

    const treeUri = 'content://tree/vault';

    setUp(() async {
      sandboxRoot = await Directory.systemTemp.createTemp(
        'attachment_sd_storage_test_',
      );
      tempFileManager = AttachmentTempFileManager(
        cacheDirectoryProvider: () async =>
            Directory('${sandboxRoot.path}${Platform.pathSeparator}cache'),
        backgroundCleanupDelay: const Duration(milliseconds: 25),
      );
      documentClient = _FakeStorageDocumentClient();
      target = const AttachmentStorageTarget(
        location: AttachmentStorageLocation.appPrivate,
      );
      storage = AesGcmAttachmentCryptoStorage(
        algorithm: AesGcm.with256bits(),
        keyManager: _InMemoryAttachmentKeyManager(),
        tempFileManager: tempFileManager,
        documentsDirectoryProvider: () async =>
            Directory('${sandboxRoot.path}${Platform.pathSeparator}docs'),
        documentClient: documentClient,
        activeTargetProvider: () async => target,
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
      'writes new attachments to the tree when the target is SD card',
      () async {
        target = const AttachmentStorageTarget(
          location: AttachmentStorageLocation.sdCard,
          treeUri: treeUri,
        );

        final payload = await storage.encryptAndStore(
          sourceBytes: Uint8List.fromList([9, 9, 9]),
          sourceFileName: 'card.pdf',
        );

        expect(payload.encryptedPath, startsWith('content://'));
        expect(documentClient.documents, contains(payload.encryptedPath));
        // Nothing should have leaked into app-private storage.
        final docsDir = Directory(
          '${sandboxRoot.path}${Platform.pathSeparator}docs',
        );
        expect(await docsDir.exists(), isFalse);
      },
    );

    test('round-trips an SD card attachment back to plaintext', () async {
      target = const AttachmentStorageTarget(
        location: AttachmentStorageLocation.sdCard,
        treeUri: treeUri,
      );

      final payload = await storage.encryptAndStore(
        sourceBytes: Uint8List.fromList([4, 5, 6, 7]),
        sourceFileName: 'card.pdf',
      );
      final handle = await storage.decryptToTempFile(
        encryptedPath: payload.encryptedPath,
        nonceBase64: payload.nonceBase64,
        keyReference: payload.keyReference,
        fileName: 'card.pdf',
      );

      expect(await handle.file.readAsBytes(), [4, 5, 6, 7]);
      await handle.release();
    });

    test('falls back to app-private when the SD target has no tree', () async {
      // The grant was revoked: writing to a null tree would throw, so the
      // safe move is app-private rather than losing the attachment.
      target = const AttachmentStorageTarget(
        location: AttachmentStorageLocation.sdCard,
      );

      final payload = await storage.encryptAndStore(
        sourceBytes: Uint8List.fromList([1]),
        sourceFileName: 'orphan.pdf',
      );

      expect(payload.encryptedPath, isNot(startsWith('content://')));
      expect(await File(payload.encryptedPath).exists(), isTrue);
    });

    test(
      'migrates an app-private file onto the tree and decrypts after',
      () async {
        final payload = await storage.encryptAndStore(
          sourceBytes: Uint8List.fromList([2, 4, 8, 16]),
          sourceFileName: 'move.pdf',
        );

        final newPath = await storage.migrateStoredFile(
          encryptedPath: payload.encryptedPath,
          fileName: 'move.pdf',
          targetLocation: AttachmentStorageLocation.sdCard,
          targetTreeUri: treeUri,
        );

        expect(newPath, startsWith('content://'));

        // The blob moved byte-for-byte, so the original nonce still decrypts it.
        final handle = await storage.decryptToTempFile(
          encryptedPath: newPath,
          nonceBase64: payload.nonceBase64,
          keyReference: payload.keyReference,
          fileName: 'move.pdf',
        );
        expect(await handle.file.readAsBytes(), [2, 4, 8, 16]);
        await handle.release();
      },
    );

    test('migrates a tree document back to app-private storage', () async {
      target = const AttachmentStorageTarget(
        location: AttachmentStorageLocation.sdCard,
        treeUri: treeUri,
      );
      final payload = await storage.encryptAndStore(
        sourceBytes: Uint8List.fromList([3, 6, 9]),
        sourceFileName: 'back.pdf',
      );

      final newPath = await storage.migrateStoredFile(
        encryptedPath: payload.encryptedPath,
        fileName: 'back.pdf',
        targetLocation: AttachmentStorageLocation.appPrivate,
      );

      expect(newPath, isNot(startsWith('content://')));
      expect(await File(newPath).exists(), isTrue);

      final handle = await storage.decryptToTempFile(
        encryptedPath: newPath,
        nonceBase64: payload.nonceBase64,
        keyReference: payload.keyReference,
        fileName: 'back.pdf',
      );
      expect(await handle.file.readAsBytes(), [3, 6, 9]);
      await handle.release();
    });

    test(
      'migration is a no-op when the file is already at the target',
      () async {
        final payload = await storage.encryptAndStore(
          sourceBytes: Uint8List.fromList([1, 2]),
          sourceFileName: 'stay.pdf',
        );

        final newPath = await storage.migrateStoredFile(
          encryptedPath: payload.encryptedPath,
          fileName: 'stay.pdf',
          targetLocation: AttachmentStorageLocation.appPrivate,
        );

        expect(newPath, payload.encryptedPath);
        expect(documentClient.migratedToLocal, isEmpty);
      },
    );

    test('deletes tree documents through the document client', () async {
      target = const AttachmentStorageTarget(
        location: AttachmentStorageLocation.sdCard,
        treeUri: treeUri,
      );
      final payload = await storage.encryptAndStore(
        sourceBytes: Uint8List.fromList([5]),
        sourceFileName: 'gone.pdf',
      );

      await storage.deleteStoredFile(payload.encryptedPath);

      expect(documentClient.documents, isNot(contains(payload.encryptedPath)));
    });

    test(
      'reports a removed SD card as a storage failure, not a crash',
      () async {
        target = const AttachmentStorageTarget(
          location: AttachmentStorageLocation.sdCard,
          treeUri: treeUri,
        );
        documentClient.available = false;

        await expectLater(
          storage.encryptAndStore(
            sourceBytes: Uint8List.fromList([1]),
            sourceFileName: 'nocard.pdf',
          ),
          throwsA(isA<AttachmentStorageUnavailableException>()),
        );
      },
    );

    test('surfaces a removed SD card on open as a missing file', () async {
      target = const AttachmentStorageTarget(
        location: AttachmentStorageLocation.sdCard,
        treeUri: treeUri,
      );
      final payload = await storage.encryptAndStore(
        sourceBytes: Uint8List.fromList([1, 2, 3]),
        sourceFileName: 'nocard.pdf',
      );
      documentClient.available = false;

      await expectLater(
        storage.decryptToTempFile(
          encryptedPath: payload.encryptedPath,
          nonceBase64: payload.nonceBase64,
          keyReference: payload.keyReference,
          fileName: 'nocard.pdf',
        ),
        throwsA(
          isA<AttachmentOpenException>().having(
            (e) => e.failure,
            'failure',
            AttachmentOpenFailure.fileNotFound,
          ),
        ),
      );
    });

    test('migrating to SD card without a tree fails loudly', () async {
      final payload = await storage.encryptAndStore(
        sourceBytes: Uint8List.fromList([1]),
        sourceFileName: 'notree.pdf',
      );

      await expectLater(
        storage.migrateStoredFile(
          encryptedPath: payload.encryptedPath,
          fileName: 'notree.pdf',
          targetLocation: AttachmentStorageLocation.sdCard,
        ),
        throwsA(isA<AttachmentStorageUnavailableException>()),
      );
    });

    test('cleanup only touches the tree, and only when one is set', () async {
      await storage.cleanupMigrationArtifacts(
        targetLocation: AttachmentStorageLocation.appPrivate,
        targetTreeUri: treeUri,
      );
      expect(documentClient.cleanedTrees, isEmpty);

      await storage.cleanupMigrationArtifacts(
        targetLocation: AttachmentStorageLocation.sdCard,
      );
      expect(documentClient.cleanedTrees, isEmpty);

      await storage.cleanupMigrationArtifacts(
        targetLocation: AttachmentStorageLocation.sdCard,
        targetTreeUri: treeUri,
      );
      expect(documentClient.cleanedTrees, [treeUri]);
    });
  });
}

/// In-memory stand-in for the native SAF layer. Tree documents are keyed by
/// their `content://` URI, mirroring what `MainActivity.kt` returns.
class _FakeStorageDocumentClient implements AttachmentStorageDocumentClient {
  final Map<String, List<int>> documents = {};
  final List<String> migratedToLocal = [];
  final List<String> cleanedTrees = [];

  /// Flip to false to simulate a removed card or a revoked grant.
  bool available = true;

  var _nextId = 0;

  void _assertAvailable() {
    if (!available) {
      throw const AttachmentStorageDocumentUnavailable(
        'Storage location is unavailable.',
      );
    }
  }

  @override
  Future<String> writeDocument({
    required String treeUri,
    required String fileName,
    required List<int> bytes,
  }) async {
    _assertAvailable();
    final uri = '$treeUri/${_nextId++}_$fileName';
    documents[uri] = List<int>.from(bytes);
    return uri;
  }

  @override
  Future<List<int>> readDocument(String documentUri) async {
    _assertAvailable();
    final bytes = documents[documentUri];
    if (bytes == null) {
      throw const AttachmentStorageDocumentUnavailable('No such document.');
    }
    return bytes;
  }

  @override
  Future<void> deleteDocument(String documentUri) async {
    _assertAvailable();
    documents.remove(documentUri);
  }

  @override
  Future<String> migrateLocalFileToTree({
    required String sourcePath,
    required String treeUri,
    required String fileName,
  }) async {
    _assertAvailable();
    final bytes = await File(sourcePath).readAsBytes();
    final uri = '$treeUri/${_nextId++}_$fileName';
    documents[uri] = bytes;
    return uri;
  }

  @override
  Future<void> migrateTreeDocumentToLocalFile({
    required String documentUri,
    required String targetPath,
  }) async {
    _assertAvailable();
    final bytes = documents[documentUri];
    if (bytes == null) {
      throw const AttachmentStorageDocumentUnavailable('No such document.');
    }
    await File(targetPath).writeAsBytes(bytes, flush: true);
    migratedToLocal.add(documentUri);
  }

  @override
  Future<void> cleanupPendingTreeDocuments(String treeUri) async {
    _assertAvailable();
    cleanedTrees.add(treeUri);
  }

  @override
  Future<bool> isTreeAvailable(String treeUri) async => available;
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
