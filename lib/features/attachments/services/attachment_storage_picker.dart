import 'package:flutter/services.dart';

/// Result of a successful SD card tree-picker selection.
class StorageTreeSelection {
  const StorageTreeSelection({required this.treeUri, required this.displayName});

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
      : _channel = channel ??
            const MethodChannel('sreerajp.journal_vault/attachment_storage');

  final MethodChannel _channel;

  @override
  Future<StorageTreeSelection?> pickStorageTree() async {
    final result =
        await _channel.invokeMapMethod<String, dynamic>('pickStorageTree');
    if (result == null) return null;
    final treeUri = result['treeUri'];
    final displayName = result['displayName'];
    if (treeUri is! String || displayName is! String) return null;
    return StorageTreeSelection(treeUri: treeUri, displayName: displayName);
  }
}
