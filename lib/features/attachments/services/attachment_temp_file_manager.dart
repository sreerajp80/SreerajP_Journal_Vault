import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';

/// Handle to a temporary decrypted file. Call [release] after use.
class AttachmentTempFileHandle {
  AttachmentTempFileHandle({required this.file});

  final File file;
  bool _isReleased = false;

  bool get isReleased => _isReleased;

  /// Deletes the temporary file and marks this handle as released.
  Future<void> release() async {
    if (_isReleased) return;
    _isReleased = true;
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// Manages temporary decrypted attachment files and cleans them up.
class AttachmentTempFileManager {
  AttachmentTempFileManager({
    required Future<Directory> Function() cacheDirectoryProvider,
    Duration backgroundCleanupDelay = const Duration(minutes: 5),
  })  : _cacheDirectoryProvider = cacheDirectoryProvider,
        _backgroundCleanupDelay = backgroundCleanupDelay;

  final Future<Directory> Function() _cacheDirectoryProvider;
  final Duration _backgroundCleanupDelay;
  final List<AttachmentTempFileHandle> _activeHandles = [];
  Timer? _cleanupTimer;

  /// Starts the manager and deletes any orphan temp files from prior sessions.
  Future<void> start() async {
    final cacheDir = await _cacheDirectoryProvider();
    final tempDir = Directory(
      '${cacheDir.path}${Platform.pathSeparator}$attachmentTempDirectoryName',
    );
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }

  /// Creates a temporary decrypted file and returns a tracked handle.
  Future<AttachmentTempFileHandle> createTempFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final cacheDir = await _cacheDirectoryProvider();
    final tempDir = Directory(
      '${cacheDir.path}${Platform.pathSeparator}$attachmentTempDirectoryName',
    );
    await tempDir.create(recursive: true);

    final uniqueName =
        '${DateTime.now().microsecondsSinceEpoch}_$fileName';
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}$uniqueName',
    );
    await file.writeAsBytes(bytes, flush: true);

    final handle = AttachmentTempFileHandle(file: file);
    _activeHandles.add(handle);
    return handle;
  }

  /// Responds to app lifecycle changes; schedules cleanup when the app pauses.
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _cleanupTimer?.cancel();
      _cleanupTimer = Timer(_backgroundCleanupDelay, _releaseAll);
    }
  }

  /// Stops cleanup and immediately releases all active handles.
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    final handles = List<AttachmentTempFileHandle>.from(_activeHandles);
    _activeHandles.clear();
    for (final handle in handles) {
      handle.release(); // fire-and-forget
    }
  }

  Future<void> _releaseAll() async {
    final handles = List<AttachmentTempFileHandle>.from(_activeHandles);
    for (final handle in handles) {
      await handle.release();
    }
    _activeHandles.removeWhere((h) => h.isReleased);
  }
}
