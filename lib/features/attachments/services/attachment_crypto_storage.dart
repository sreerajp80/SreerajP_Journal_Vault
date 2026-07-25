import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_key_manager.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';

// Re-export so existing callers that only import this file keep working.
export 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart'
    show AttachmentOpenException, AttachmentOpenFailure;
export 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart'
    show AttachmentTempFileHandle;

/// Location where encrypted attachment files are stored.
enum AttachmentStorageLocation {
  appPrivate,
  sdCard;

  String toSettingsValue() => switch (this) {
        AttachmentStorageLocation.appPrivate => 'app_private',
        AttachmentStorageLocation.sdCard => 'sd_card',
      };

  static AttachmentStorageLocation fromSettingsValue(String value) =>
      switch (value) {
        'sd_card' => AttachmentStorageLocation.sdCard,
        _ => AttachmentStorageLocation.appPrivate,
      };
}

/// Payload returned after encrypting and storing an attachment.
class StoredAttachmentPayload {
  const StoredAttachmentPayload({
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

/// Thrown when an attachment storage location is unavailable (e.g. SD card removed).
class AttachmentStorageUnavailableException implements Exception {
  const AttachmentStorageUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Abstract interface for encrypting, decrypting, and managing attachment files.
abstract class AttachmentCryptoStorage {
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  });

  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  });

  Future<void> deleteStoredFile(String encryptedPath);

  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  });

  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  });

  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  });
}

/// AES-256-GCM implementation of [AttachmentCryptoStorage].
///
/// Encrypted files are stored in [documentsDirectoryProvider]/<[attachmentEncryptedDirectoryName]>/.
/// The nonce is returned in [StoredAttachmentPayload.nonceBase64] and stored separately.
/// File format on disk: cipherText || 16-byte GCM tag.
class AesGcmAttachmentCryptoStorage implements AttachmentCryptoStorage {
  AesGcmAttachmentCryptoStorage({
    required AesGcm algorithm,
    required AttachmentKeyManager keyManager,
    required AttachmentTempFileManager tempFileManager,
    required Future<Directory> Function() documentsDirectoryProvider,
  })  : _algorithm = algorithm,
        _keyManager = keyManager,
        _tempFileManager = tempFileManager,
        _documentsDirectoryProvider = documentsDirectoryProvider;

  final AesGcm _algorithm;
  final AttachmentKeyManager _keyManager;
  final AttachmentTempFileManager _tempFileManager;
  final Future<Directory> Function() _documentsDirectoryProvider;

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) async {
    final keyMaterial = await _keyManager.getOrCreateActiveKey();
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      sourceBytes,
      secretKey: keyMaterial.secretKey,
      nonce: nonce,
    );

    final docsDir = await _documentsDirectoryProvider();
    final encryptedDir = Directory(
      '${docsDir.path}${Platform.pathSeparator}$attachmentEncryptedDirectoryName',
    );
    await encryptedDir.create(recursive: true);

    final uniqueId =
        '${DateTime.now().microsecondsSinceEpoch}_${sourceFileName.hashCode.abs()}';
    final encryptedFile = File(
      '${encryptedDir.path}${Platform.pathSeparator}$uniqueId.bin',
    );

    // Write cipherText || mac to disk; nonce is stored separately.
    final fileBytes = Uint8List.fromList([
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    await encryptedFile.writeAsBytes(fileBytes, flush: true);

    return StoredAttachmentPayload(
      encryptedPath: encryptedFile.path,
      nonceBase64: base64.encode(secretBox.nonce),
      keyReference: keyMaterial.keyReference,
      sizeBytes: sourceBytes.length,
    );
  }

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) async {
    try {
      final secretKey = await _keyManager.loadKey(keyReference);
      final encryptedFile = File(encryptedPath);
      final fileBytes = await encryptedFile.readAsBytes();

      const macLength = 16; // AES-GCM authentication tag is always 16 bytes
      if (fileBytes.length < macLength) {
        throw AttachmentOpenException(AttachmentOpenFailure.decryptFailed);
      }

      final cipherText = fileBytes.sublist(0, fileBytes.length - macLength);
      final macBytes = fileBytes.sublist(fileBytes.length - macLength);
      final nonce = base64.decode(nonceBase64);

      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final clearText = await _algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return _tempFileManager.createTempFile(
        bytes: Uint8List.fromList(clearText),
        fileName: fileName,
      );
    } on AttachmentOpenException {
      rethrow;
    } catch (_) {
      throw AttachmentOpenException(AttachmentOpenFailure.decryptFailed);
    }
  }

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {
    final file = File(encryptedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) {
    return switch (location) {
      AttachmentStorageLocation.appPrivate =>
        !encryptedPath.startsWith('content://'),
      AttachmentStorageLocation.sdCard =>
        encryptedPath.startsWith('content://'),
    };
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {
    // Requires platform SAF integration for SD card migrations.
    throw UnimplementedError(
      'migrateStoredFile requires platform-specific SAF integration',
    );
  }

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}
}
