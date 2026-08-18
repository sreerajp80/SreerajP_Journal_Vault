import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_key_manager.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_storage_picker.dart';
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

/// Where attachments should be written right now: the location plus, for
/// [AttachmentStorageLocation.sdCard], the SAF tree that was granted.
///
/// A `sdCard` target with a null [treeUri] is treated as app-private — the
/// grant is gone, so there is nowhere to write.
class AttachmentStorageTarget {
  const AttachmentStorageTarget({required this.location, this.treeUri});

  final AttachmentStorageLocation location;
  final String? treeUri;
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
    required this._algorithm,
    required this._keyManager,
    required this._tempFileManager,
    required this._documentsDirectoryProvider,
    this._documentClient,
    this._activeTargetProvider,
  });

  final AesGcm _algorithm;
  final AttachmentKeyManager _keyManager;
  final AttachmentTempFileManager _tempFileManager;
  final Future<Directory> Function() _documentsDirectoryProvider;

  /// Native SAF bridge. Null in tests that never touch SD-card paths.
  final AttachmentStorageDocumentClient? _documentClient;

  /// Where new attachments should land. Reads the persisted setting so
  /// [encryptAndStore] honours it — previously it always wrote app-private
  /// regardless of what the user had chosen.
  final Future<AttachmentStorageTarget> Function()? _activeTargetProvider;

  /// Paths on the SD card tree are SAF content URIs; app-private paths are
  /// plain filesystem paths. This one test drives every read/write branch.
  static bool _isTreeDocument(String path) => path.startsWith('content://');

  AttachmentStorageDocumentClient _requireDocumentClient() {
    final client = _documentClient;
    if (client == null) {
      throw const AttachmentStorageUnavailableException(
        'SD card storage is not available on this platform.',
      );
    }
    return client;
  }

  /// Every native storage failure surfaces as
  /// [AttachmentStorageUnavailableException] so callers show a real message
  /// instead of a raw platform error string.
  Future<T> _mapUnavailable<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AttachmentStorageDocumentUnavailable catch (error) {
      throw AttachmentStorageUnavailableException(error.message);
    }
  }

  String _buildFileName(String sourceFileName) =>
      '${DateTime.now().microsecondsSinceEpoch}_${sourceFileName.hashCode.abs()}.bin';

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

    // Write cipherText || mac; nonce is stored separately in the database.
    final fileBytes = Uint8List.fromList([
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    final fileName = _buildFileName(sourceFileName);

    final target =
        await _activeTargetProvider?.call() ??
        const AttachmentStorageTarget(
          location: AttachmentStorageLocation.appPrivate,
        );

    final String encryptedPath;
    if (target.location == AttachmentStorageLocation.sdCard &&
        target.treeUri != null) {
      encryptedPath = await _mapUnavailable(
        () => _requireDocumentClient().writeDocument(
          treeUri: target.treeUri!,
          fileName: fileName,
          bytes: fileBytes,
        ),
      );
    } else {
      final docsDir = await _documentsDirectoryProvider();
      final encryptedDir = Directory(
        '${docsDir.path}${Platform.pathSeparator}$attachmentEncryptedDirectoryName',
      );
      await encryptedDir.create(recursive: true);
      final encryptedFile = File(
        '${encryptedDir.path}${Platform.pathSeparator}$fileName',
      );
      await encryptedFile.writeAsBytes(fileBytes, flush: true);
      encryptedPath = encryptedFile.path;
    }

    return StoredAttachmentPayload(
      encryptedPath: encryptedPath,
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
      final fileBytes = _isTreeDocument(encryptedPath)
          ? await _mapUnavailable(
              () => _requireDocumentClient().readDocument(encryptedPath),
            )
          : await File(encryptedPath).readAsBytes();

      const macLength = 16; // AES-GCM authentication tag is always 16 bytes
      if (fileBytes.length < macLength) {
        throw AttachmentOpenException(AttachmentOpenFailure.decryptFailed);
      }

      final cipherText = fileBytes.sublist(0, fileBytes.length - macLength);
      final macBytes = fileBytes.sublist(fileBytes.length - macLength);
      final nonce = base64.decode(nonceBase64);

      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

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
    } on AttachmentStorageUnavailableException {
      // The bytes are intact, we just cannot reach them — a removed SD card
      // is a missing file to the user, not a corrupt one.
      throw AttachmentOpenException(AttachmentOpenFailure.fileNotFound);
    } catch (_) {
      throw AttachmentOpenException(AttachmentOpenFailure.decryptFailed);
    }
  }

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {
    if (_isTreeDocument(encryptedPath)) {
      await _mapUnavailable(
        () => _requireDocumentClient().deleteDocument(encryptedPath),
      );
      return;
    }
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
      AttachmentStorageLocation.appPrivate => !_isTreeDocument(encryptedPath),
      AttachmentStorageLocation.sdCard => _isTreeDocument(encryptedPath),
    };
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {
    // The encrypted blob moves byte-for-byte. Nonce and key reference live in
    // the database and are untouched, so a migrated file decrypts exactly as
    // it did before.
    switch (targetLocation) {
      case AttachmentStorageLocation.sdCard:
        if (targetTreeUri == null) {
          throw const AttachmentStorageUnavailableException(
            'No SD card folder has been selected.',
          );
        }
        if (_isTreeDocument(encryptedPath)) return encryptedPath;
        return _mapUnavailable(
          () => _requireDocumentClient().migrateLocalFileToTree(
            sourcePath: encryptedPath,
            treeUri: targetTreeUri,
            fileName: _buildFileName(fileName),
          ),
        );

      case AttachmentStorageLocation.appPrivate:
        if (!_isTreeDocument(encryptedPath)) return encryptedPath;
        final docsDir = await _documentsDirectoryProvider();
        final encryptedDir = Directory(
          '${docsDir.path}${Platform.pathSeparator}$attachmentEncryptedDirectoryName',
        );
        await encryptedDir.create(recursive: true);
        final targetPath =
            '${encryptedDir.path}${Platform.pathSeparator}${_buildFileName(fileName)}';
        await _mapUnavailable(
          () => _requireDocumentClient().migrateTreeDocumentToLocalFile(
            documentUri: encryptedPath,
            targetPath: targetPath,
          ),
        );
        return targetPath;
    }
  }

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {
    // Only the tree side can be left half-written; app-private writes are a
    // single flushed File.writeAsBytes.
    if (targetLocation != AttachmentStorageLocation.sdCard) return;
    if (targetTreeUri == null || _documentClient == null) return;
    await _mapUnavailable(
      () => _documentClient.cleanupPendingTreeDocuments(targetTreeUri),
    );
  }
}
