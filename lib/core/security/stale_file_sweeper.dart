// Layer: service (core, because it is app-wide). Deletes files an earlier run
// of the app left behind. Knows nothing about widgets or UI strings, and never
// logs a file name or path — these are private journal files.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';

/// Cache sub-folder where `file_picker` copies every file the user picks.
const String filePickerCacheDirectoryName = 'file_picker';

/// Cache sub-folder holding the copy of a backup being restored.
const String restoreStagingDirectoryName = 'restore_staging';

/// Cache sub-folder holding voice recordings in progress.
const String voiceRecordingDirectoryName = 'voice_rec';

/// Cache sub-folders that only ever hold temporary copies, so everything in
/// them at start-up is left over from an earlier run.
///
/// `attachment_temp` is not listed: `AttachmentTempFileManager.start` owns it.
const List<String> kStaleCacheDirectoryNames = <String>[
  filePickerCacheDirectoryName,
  restoreStagingDirectoryName,
  voiceRecordingDirectoryName,
];

/// An encrypted file must be at least this old before
/// [StaleFileSweeper.sweepOrphanedAttachments] may delete it. Every write of
/// an encrypted file is followed within moments by its database row, so an
/// hour is far beyond any write still in flight.
const Duration kOrphanAttachmentMinAge = Duration(hours: 1);

/// Deletes leftover files once, when the app starts.
///
/// Run it before anything else can create temporary files, and never while a
/// backup restore or sync is running.
class StaleFileSweeper {
  StaleFileSweeper({
    required this.cacheDirectory,
    required this.documentsDirectory,
    required this.referencedStoredPaths,
    this.now,
  });

  /// The app's cache folder.
  final Future<Directory> Function() cacheDirectory;

  /// The app's private documents folder, which holds
  /// [attachmentEncryptedDirectoryName].
  final Future<Directory> Function() documentsDirectory;

  /// Every `encrypted_path` a database row points at. May throw; then no
  /// encrypted file is touched.
  final Future<Iterable<String>> Function() referencedStoredPaths;

  /// The current time. Injected in tests.
  final DateTime Function()? now;

  /// Runs every sweep. Never throws.
  Future<void> run() async {
    await clearCacheFolders();
    await sweepOrphanedAttachments();
  }

  /// Deletes the folders in [kStaleCacheDirectoryNames]. Returns how many
  /// existed. Never throws.
  Future<int> clearCacheFolders() async {
    var cleared = 0;
    try {
      final root = await cacheDirectory();
      for (final name in kStaleCacheDirectoryNames) {
        final dir = Directory(p.join(root.path, name));
        try {
          if (!dir.existsSync()) continue;
          dir.deleteSync(recursive: true);
          cleared++;
        } catch (_) {
          // In use or already gone; the next start tries again.
        }
      }
    } catch (e) {
      AppLogger.warning('StaleFileSweeper: cache folder unavailable');
    }
    if (cleared > 0) {
      AppLogger.info('StaleFileSweeper: cleared $cleared cache folders');
    }
    return cleared;
  }

  /// Deletes encrypted files that no database row points at and that are
  /// older than [kOrphanAttachmentMinAge]. Returns how many were deleted.
  /// Never throws.
  ///
  /// Such files are left by deletes from older builds, which removed the row
  /// but not the file. They cannot be opened: the nonce needed to decrypt
  /// them was in the row. Only app-private storage is swept; the SD card
  /// bridge cannot list files.
  Future<int> sweepOrphanedAttachments() async {
    final Set<String> referenced;
    try {
      // Compared by file name: the name is unique per file, and it survives a
      // change in the app's folder path, which a full path would not.
      referenced = {
        for (final path in await referencedStoredPaths())
          if (!path.startsWith('content://')) p.basename(path),
      };
    } catch (e) {
      AppLogger.warning(
        'StaleFileSweeper: database unreadable, orphan sweep skipped',
      );
      return 0;
    }

    var deleted = 0;
    try {
      final docs = await documentsDirectory();
      final dir = Directory(
        p.join(docs.path, attachmentEncryptedDirectoryName),
      );
      if (!dir.existsSync()) return 0;
      final cutoff = (now ?? DateTime.now)().subtract(kOrphanAttachmentMinAge);
      for (final entity in dir.listSync(followLinks: false)) {
        if (entity is! File) continue;
        if (referenced.contains(p.basename(entity.path))) continue;
        try {
          if (entity.lastModifiedSync().isAfter(cutoff)) continue;
          entity.deleteSync();
          deleted++;
        } catch (_) {
          // The next start tries again.
        }
      }
    } catch (e) {
      AppLogger.warning('StaleFileSweeper: orphan sweep failed');
    }
    if (deleted > 0) {
      AppLogger.info('StaleFileSweeper: removed $deleted orphaned files');
    }
    return deleted;
  }
}
