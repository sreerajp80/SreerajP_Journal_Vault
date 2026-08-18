/// Turns the attachment id inside a `vault_image` embed into a file the editor
/// can show.
///
/// An inline image is an ordinary encrypted attachment row. To draw it, the
/// bytes have to be decrypted to a temporary file first — the same path the
/// attachment viewer uses. This class does that once per attachment and keeps
/// the handle, so scrolling an entry full of photos does not decrypt the same
/// picture over and over.
///
/// **It owns the plaintext.** Every handle it hands out is released in
/// [dispose], so closing the editor removes the decrypted copies from the cache
/// directory. `AttachmentTempFileManager` sweeps anything left behind.
///
/// **It honours attachment locks.** A locked attachment resolves to
/// [InlineImageLocked] and is never decrypted until [unlock] succeeds. Drawing
/// a locked picture inline would be a way around a lock the user set on
/// purpose.
///
/// Everything it needs comes in as a callback, so it is a plain Dart class with
/// no database, no Riverpod and no Flutter — see `buildInlineImageStore` in
/// `entry_providers.dart` for the wiring, and the tests for how cheap this
/// makes it to fake.
library;

import 'dart:io';

import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';

/// The parts of an attachment row this store needs to decrypt one image.
class InlineImageSource {
  const InlineImageSource({
    required this.fileName,
    required this.encryptedPath,
    required this.nonceBase64,
    required this.keyReference,
  });

  final String fileName;
  final String encryptedPath;
  final String nonceBase64;
  final String keyReference;
}

/// What the embed should draw right now.
sealed class InlineImageState {
  const InlineImageState();
}

/// The picture is decrypted and ready.
class InlineImageReady extends InlineImageState {
  const InlineImageReady(this.file);

  final File file;
}

/// The attachment carries a lock. Nothing has been decrypted.
class InlineImageLocked extends InlineImageState {
  const InlineImageLocked();
}

/// The row is gone, the file is missing, or the bytes would not decrypt.
///
/// The embed stays in the document and says so, rather than vanishing — an
/// entry must never quietly lose the fact that there was a picture here.
class InlineImageUnavailable extends InlineImageState {
  const InlineImageUnavailable();
}

class InlineImageStore {
  // Private fields as named parameters — the same style the attachment and
  // export services use. Dart drops the underscore for the caller.
  InlineImageStore({
    required this._loadSource,
    required this._isLocked,
    required this._decrypt,
    required this._authenticate,
  });

  final Future<InlineImageSource?> Function(int attachmentId) _loadSource;
  final Future<bool> Function(int attachmentId) _isLocked;
  final Future<AttachmentTempFileHandle> Function(InlineImageSource source)
  _decrypt;
  final Future<bool> Function(String fileName) _authenticate;

  /// In-flight and finished lookups, keyed by attachment id. Holding the
  /// future — not the result — means two embeds asking at the same time share
  /// one decryption.
  final Map<int, Future<InlineImageState>> _resolved = {};

  /// Handles to release when the screen closes.
  final List<AttachmentTempFileHandle> _handles = [];

  /// Attachments the user has unlocked during this screen's lifetime. The lock
  /// on the row is untouched; this only remembers that the prompt was answered,
  /// so scrolling past an unlocked image does not ask again.
  final Set<int> _unlockedThisSession = {};

  bool _disposed = false;

  /// Whether [attachmentId] was unlocked earlier in this session.
  bool isUnlocked(int attachmentId) =>
      _unlockedThisSession.contains(attachmentId);

  /// Resolves what the embed for [attachmentId] should show.
  Future<InlineImageState> resolve(int attachmentId) {
    final cached = _resolved[attachmentId];
    if (cached != null) return cached;

    final pending = _resolveUncached(attachmentId);
    _resolved[attachmentId] = pending;
    return pending;
  }

  /// Prompts for authentication and, on success, decrypts a locked image.
  ///
  /// Returns the new state either way, so the caller can just redraw. A refused
  /// or cancelled prompt leaves the image locked.
  Future<InlineImageState> unlock(int attachmentId) async {
    final source = await _safeLoadSource(attachmentId);
    if (source == null) return const InlineImageUnavailable();

    final allowed = await _authenticate(source.fileName);
    if (!allowed) return const InlineImageLocked();

    _unlockedThisSession.add(attachmentId);
    final pending = _decryptToState(source);
    _resolved[attachmentId] = pending;
    return pending;
  }

  Future<InlineImageState> _resolveUncached(int attachmentId) async {
    final source = await _safeLoadSource(attachmentId);
    if (source == null) return const InlineImageUnavailable();

    if (!_unlockedThisSession.contains(attachmentId)) {
      bool locked;
      try {
        locked = await _isLocked(attachmentId);
      } catch (_) {
        // If the lock cannot be read, assume locked. Failing closed is the only
        // safe direction for a security check.
        locked = true;
      }
      if (locked) return const InlineImageLocked();
    }

    return _decryptToState(source);
  }

  Future<InlineImageSource?> _safeLoadSource(int attachmentId) async {
    // A deleted attachment leaves its embed behind in the document, and the
    // lookup throws. That is a missing picture, not a broken editor.
    try {
      return await _loadSource(attachmentId);
    } catch (_) {
      return null;
    }
  }

  Future<InlineImageState> _decryptToState(InlineImageSource source) async {
    try {
      final handle = await _decrypt(source);
      if (_disposed) {
        // The screen closed while we were decrypting; nothing will draw this.
        await handle.release();
        return const InlineImageUnavailable();
      }
      _handles.add(handle);
      return InlineImageReady(handle.file);
    } catch (_) {
      return const InlineImageUnavailable();
    }
  }

  /// Deletes every decrypted copy this store created.
  ///
  /// A widget's `dispose()` cannot wait, so callers there start this and walk
  /// away (`unawaited`). The future is returned anyway, so a test can be sure
  /// the files are gone before it checks.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _resolved.clear();
    _unlockedThisSession.clear();
    final handles = List<AttachmentTempFileHandle>.from(_handles);
    _handles.clear();
    for (final handle in handles) {
      try {
        await handle.release();
      } catch (_) {
        // A file the temp manager's own sweep has already removed must not
        // stop the rest from being cleaned up.
      }
    }
  }
}
