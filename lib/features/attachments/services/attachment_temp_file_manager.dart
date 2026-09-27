import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';

/// Handle to a temporary decrypted file. Call [release] after use.
class AttachmentTempFileHandle {
  AttachmentTempFileHandle({required this.file, this.onReleased});

  final File file;

  /// Tells the manager the handle is done, so it stops tracking it.
  final void Function(AttachmentTempFileHandle handle)? onReleased;

  bool _isReleased = false;
  bool _isHandedOff = false;

  bool get isReleased => _isReleased;

  /// True once the file was given to another app, which may still be reading
  /// it after this app has moved on.
  bool get isHandedOff => _isHandedOff;

  /// Marks the file as given to another app. Nobody in this app will release
  /// it, so the manager's pause sweep does.
  void markHandedOff() => _isHandedOff = true;

  /// Deletes the temporary file and marks this handle as released.
  Future<void> release() async {
    if (_isReleased) return;
    _isReleased = true;
    onReleased?.call(this);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// Manages temporary decrypted attachment files and cleans them up.
///
/// Three layers keep plain copies from piling up:
/// - whoever creates a copy releases it when done (viewers, inline images,
///   export, backup);
/// - a copy handed to another app is released [_backgroundCleanupDelay] after
///   this app goes to the background, once [listenToAppLifecycle] is on;
/// - [start], at app start, deletes whatever an earlier run left behind.
class AttachmentTempFileManager {
  AttachmentTempFileManager({
    required this._cacheDirectoryProvider,
    this._backgroundCleanupDelay = const Duration(minutes: 5),
  });

  final Future<Directory> Function() _cacheDirectoryProvider;
  final Duration _backgroundCleanupDelay;
  final List<AttachmentTempFileHandle> _activeHandles = [];
  Timer? _cleanupTimer;
  AppLifecycleListener? _lifecycleListener;

  /// Handles not yet released. For tests.
  @visibleForTesting
  int get activeHandleCount => _activeHandles.length;

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

  /// Forwards app lifecycle changes to [didChangeAppLifecycleState].
  ///
  /// Separate from [start] because it needs the Flutter binding, which plain
  /// unit tests do not have.
  void listenToAppLifecycle() {
    _lifecycleListener ??= AppLifecycleListener(
      onStateChange: didChangeAppLifecycleState,
    );
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

    final uniqueName = '${DateTime.now().microsecondsSinceEpoch}_$fileName';
    final file = File('${tempDir.path}${Platform.pathSeparator}$uniqueName');
    await file.writeAsBytes(bytes, flush: true);

    final handle = AttachmentTempFileHandle(
      file: file,
      onReleased: _activeHandles.remove,
    );
    _activeHandles.add(handle);
    return handle;
  }

  /// Responds to app lifecycle changes; schedules cleanup when the app pauses.
  ///
  /// Only copies handed to another app are swept. The in-app viewers and
  /// inline images still on screen own their copies and delete them when
  /// they close.
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _cleanupTimer?.cancel();
      _cleanupTimer = Timer(_backgroundCleanupDelay, _releaseHandedOff);
    }
  }

  /// Stops cleanup and immediately releases all active handles.
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    final handles = List<AttachmentTempFileHandle>.from(_activeHandles);
    _activeHandles.clear();
    for (final handle in handles) {
      handle.release(); // fire-and-forget
    }
  }

  Future<void> _releaseHandedOff() async {
    final handles = _activeHandles.where((h) => h.isHandedOff).toList();
    for (final handle in handles) {
      try {
        await handle.release();
      } catch (_) {
        // Already gone, or still locked; start() clears it next launch.
      }
    }
  }
}
