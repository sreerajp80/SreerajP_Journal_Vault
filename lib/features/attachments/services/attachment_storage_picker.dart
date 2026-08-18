import 'dart:convert';

import 'package:flutter/services.dart';

/// The single native channel backing every SD-card storage operation.
const MethodChannel attachmentStorageChannel = MethodChannel(
  'sreerajp.journal_vault/attachment_storage',
);

/// Error code the native side returns when the tree is gone (card removed,
/// permission revoked). Mapped to `AttachmentStorageUnavailableException`.
const String storageUnavailableErrorCode = 'storage_unavailable';

/// Result of a successful SD card tree-picker selection.
class StorageTreeSelection {
  const StorageTreeSelection({
    required this.treeUri,
    required this.displayName,
  });

  final String treeUri;
  final String displayName;
}

/// Wraps the native `sreerajp.journal_vault/attachment_storage` MethodChannel
/// for the Dart side of the SD-card tree picker. The Settings UI uses this to
/// let the user choose where SD card attachments will live.
abstract class AttachmentStoragePicker {
  /// Launches the system folder picker. Returns null if the user cancels.
  Future<StorageTreeSelection?> pickStorageTree();
}

class MethodChannelAttachmentStoragePicker implements AttachmentStoragePicker {
  MethodChannelAttachmentStoragePicker({MethodChannel? channel})
    : _channel = channel ?? attachmentStorageChannel;

  final MethodChannel _channel;

  @override
  Future<StorageTreeSelection?> pickStorageTree() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pickStorageTree',
    );
    if (result == null) return null;
    final treeUri = result['treeUri'];
    final displayName = result['displayName'];
    if (treeUri is! String || displayName is! String) return null;
    return StorageTreeSelection(treeUri: treeUri, displayName: displayName);
  }
}

/// Thrown when the SD card tree cannot be reached — card removed, or the
/// persisted tree permission was revoked.
class AttachmentStorageDocumentUnavailable implements Exception {
  const AttachmentStorageDocumentUnavailable(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Dart wrapper over the document half of [attachmentStorageChannel].
///
/// The native side (`MainActivity.kt`) has implemented all of these since the
/// SAF work landed; only [AttachmentStoragePicker] had a Dart caller. Bytes
/// cross the channel Base64-encoded because `MethodChannel` has no efficient
/// large-binary type.
abstract class AttachmentStorageDocumentClient {
  /// Writes [bytes] as [fileName] under [treeUri]. Returns the `content://`
  /// URI of the created document.
  Future<String> writeDocument({
    required String treeUri,
    required String fileName,
    required List<int> bytes,
  });

  Future<List<int>> readDocument(String documentUri);

  Future<void> deleteDocument(String documentUri);

  /// Copies an app-private file onto the tree. Returns the new `content://` URI.
  Future<String> migrateLocalFileToTree({
    required String sourcePath,
    required String treeUri,
    required String fileName,
  });

  /// Copies a tree document back into app-private storage at [targetPath].
  Future<void> migrateTreeDocumentToLocalFile({
    required String documentUri,
    required String targetPath,
  });

  /// Removes half-written documents left by an interrupted migration.
  Future<void> cleanupPendingTreeDocuments(String treeUri);

  /// Whether [treeUri] is still readable and writable.
  Future<bool> isTreeAvailable(String treeUri);
}

class MethodChannelAttachmentStorageDocumentClient
    implements AttachmentStorageDocumentClient {
  MethodChannelAttachmentStorageDocumentClient({MethodChannel? channel})
    : _channel = channel ?? attachmentStorageChannel;

  final MethodChannel _channel;

  /// Every native call funnels through here so the `storage_unavailable`
  /// error code becomes a typed exception in exactly one place.
  Future<T> _invoke<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (error) {
      if (error.code == storageUnavailableErrorCode) {
        throw AttachmentStorageDocumentUnavailable(
          error.message ?? 'Storage location is unavailable.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<String> writeDocument({
    required String treeUri,
    required String fileName,
    required List<int> bytes,
  }) async {
    final uri = await _invoke(
      () => _channel.invokeMethod<String>('writeStorageDocument', {
        'treeUri': treeUri,
        'fileName': fileName,
        'bytesBase64': base64.encode(bytes),
      }),
    );
    if (uri == null) {
      throw const AttachmentStorageDocumentUnavailable(
        'Storage location did not return a document URI.',
      );
    }
    return uri;
  }

  @override
  Future<List<int>> readDocument(String documentUri) async {
    final encoded = await _invoke(
      () => _channel.invokeMethod<String>('readStorageDocument', {
        'documentUri': documentUri,
      }),
    );
    if (encoded == null) {
      throw const AttachmentStorageDocumentUnavailable(
        'Storage location did not return document bytes.',
      );
    }
    return base64.decode(encoded);
  }

  @override
  Future<void> deleteDocument(String documentUri) => _invoke(
    () => _channel.invokeMethod<void>('deleteStorageDocument', {
      'documentUri': documentUri,
    }),
  );

  @override
  Future<String> migrateLocalFileToTree({
    required String sourcePath,
    required String treeUri,
    required String fileName,
  }) async {
    final uri = await _invoke(
      () => _channel.invokeMethod<String>('migrateLocalFileToTree', {
        'sourcePath': sourcePath,
        'treeUri': treeUri,
        'fileName': fileName,
      }),
    );
    if (uri == null) {
      throw const AttachmentStorageDocumentUnavailable(
        'Storage location did not return a document URI.',
      );
    }
    return uri;
  }

  @override
  Future<void> migrateTreeDocumentToLocalFile({
    required String documentUri,
    required String targetPath,
  }) => _invoke(
    () => _channel.invokeMethod<void>('migrateTreeDocumentToLocalFile', {
      'documentUri': documentUri,
      'targetPath': targetPath,
    }),
  );

  @override
  Future<void> cleanupPendingTreeDocuments(String treeUri) => _invoke(
    () => _channel.invokeMethod<void>('cleanupPendingTreeDocuments', {
      'treeUri': treeUri,
    }),
  );

  @override
  Future<bool> isTreeAvailable(String treeUri) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'checkStorageTreeAccess',
        {'treeUri': treeUri},
      );
      return result?['available'] == true;
    } on PlatformException {
      return false;
    }
  }
}
