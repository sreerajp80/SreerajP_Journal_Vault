import 'dart:io';
import 'dart:typed_data';

import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';

/// A file the backup feature has just written to attachment storage.
class BackupStoredFile {
  const BackupStoredFile({
    required this.encryptedPath,
    required this.nonceBase64,
    required this.keyReference,
    required this.sizeBytes,
  });

  final String encryptedPath;
  final String nonceBase64;
  final String keyReference;
  final int sizeBytes;
}

/// What backup and restore need from attachment storage, and nothing more.
///
/// Layer: service. Backup does not care where files live or how keys are
/// held; it only needs "give me the plain bytes" on the way out and "store
/// these bytes for this device" on the way back in.
abstract class BackupAttachmentCipher {
  /// Decrypts one stored file and returns its plain bytes.
  Future<Uint8List> decryptToBytes({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  });

  /// Encrypts [bytes] with this device's key and stores the result.
  Future<BackupStoredFile> encryptFromBytes({
    required List<int> bytes,
    required String fileName,
  });

  /// Writes bytes that are **already encrypted** straight to storage, without
  /// touching them.
  ///
  /// Only used when restoring a format version 1 archive, whose files carry
  /// the original device's encryption. They open again only if that device's
  /// key is still present, so this is a byte-for-byte rescue, not a
  /// re-encryption.
  Future<String> storeRawEncryptedBytes({
    required List<int> bytes,
    required String fileName,
  });

  /// Deletes a stored file. Used to clean up after a failed restore.
  Future<void> deleteStoredFile(String encryptedPath);
}

/// [BackupAttachmentCipher] on top of the app's real attachment storage.
class AttachmentStorageBackupCipher implements BackupAttachmentCipher {
  const AttachmentStorageBackupCipher(
    this._storage, {
    required this.documentsDirectoryProvider,
  });

  final AttachmentCryptoStorage _storage;

  /// Where raw version 1 blobs are written when they are rescued as-is.
  final Future<Directory> Function() documentsDirectoryProvider;

  @override
  Future<Uint8List> decryptToBytes({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) async {
    // The storage layer decrypts to a temp file. Read it, then release the
    // handle straight away so no plain copy outlives this call.
    final handle = await _storage.decryptToTempFile(
      encryptedPath: encryptedPath,
      nonceBase64: nonceBase64,
      keyReference: keyReference,
      fileName: fileName,
    );
    try {
      return await handle.file.readAsBytes();
    } finally {
      await handle.release();
    }
  }

  @override
  Future<BackupStoredFile> encryptFromBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    final stored = await _storage.encryptAndStore(
      sourceBytes: bytes,
      sourceFileName: fileName,
    );
    return BackupStoredFile(
      encryptedPath: stored.encryptedPath,
      nonceBase64: stored.nonceBase64,
      keyReference: stored.keyReference,
      sizeBytes: stored.sizeBytes,
    );
  }

  @override
  Future<String> storeRawEncryptedBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    final docsDir = await documentsDirectoryProvider();
    final targetDir = Directory(
      '${docsDir.path}${Platform.pathSeparator}'
      '$attachmentEncryptedDirectoryName',
    );
    await targetDir.create(recursive: true);
    final unique = DateTime.now().microsecondsSinceEpoch;
    final file = File(
      '${targetDir.path}${Platform.pathSeparator}${unique}_$fileName.bin',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<void> deleteStoredFile(String encryptedPath) =>
      _storage.deleteStoredFile(encryptedPath);
}
