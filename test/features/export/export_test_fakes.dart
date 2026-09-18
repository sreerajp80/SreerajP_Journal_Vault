// Test doubles shared by the tests next to this file.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';

/// A stand-in for the real AES-GCM storage.
///
/// [contents] maps an encrypted path to the bytes that come back. A path that
/// is not in the map throws, standing in for a missing SD card or a damaged
/// file.
class FakeCryptoStorage implements AttachmentCryptoStorage {
  FakeCryptoStorage(this.tempDir);

  final Directory tempDir;
  final Map<String, List<int>> contents = {};
  final List<String> decryptCalls = [];
  final List<AttachmentTempFileHandle> handedOutHandles = [];

  var _counter = 0;

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) async {
    decryptCalls.add(encryptedPath);
    final bytes = contents[encryptedPath];
    if (bytes == null) {
      throw StateError('no such stored file');
    }
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}'
      'tmp_${_counter++}_$fileName',
    );
    await file.writeAsBytes(bytes);
    final handle = AttachmentTempFileHandle(file: file);
    handedOutHandles.add(handle);
    return handle;
  }

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {}

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) => throw UnimplementedError();

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) => true;

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) => throw UnimplementedError();
}
