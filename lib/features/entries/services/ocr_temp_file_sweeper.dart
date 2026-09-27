// Layer: service. Deletes the plain (unencrypted) photos a text scan leaves in
// the app's cache folder. Knows nothing about widgets or UI strings, and never
// logs a file name or path — a scan photo is private journal content.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Start of the name of every temporary file a text scan can leave behind.
///
/// - `CAP` — a photo from the in-app camera (the camera plugin's name).
/// - `image_picker` — a photo taken with the phone's camera app.
/// - `image_cropper` — the output of the crop tool.
/// - `ocr_…` — working copies made by this app's own scan steps.
const List<String> kOcrTempFilePrefixes = <String>[
  'CAP',
  'image_picker',
  'image_cropper',
  'ocr_cap_',
  'ocr_enh_',
  'ocr_prep_',
  'ocr_rot_',
];

/// Name of a folder the photo picker makes for one gallery copy: a random
/// UUID, such as `3f2b…-…`.
final RegExp _pickerFolderName = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// A leftover file must be at least this old before [OcrTempFileSweeper.sweepStale]
/// deletes it, so a scan that is starting right now never loses its photo.
const Duration kOcrTempFileMinAge = Duration(seconds: 60);

/// Contract for cleaning up the temporary photos of a text scan.
abstract class OcrTempFileSweeper {
  /// The folder scan steps write their temporary files into.
  Future<Directory> tempDirectory();

  /// Deletes the temporary file at [path] now, and its folder when that is an
  /// empty folder the photo picker made for it.
  ///
  /// Does nothing for a path outside the app's cache folder, so a photo the
  /// user owns is never touched. Never throws.
  Future<void> deleteNow(String? path);

  /// Deletes scan files left in the cache folder by an earlier scan that did
  /// not finish — the app was closed or crashed part way. Only files whose name
  /// starts with one of [kOcrTempFilePrefixes], and the photo picker's own
  /// folders (a UUID name holding only files), older than [kOcrTempFileMinAge]
  /// are removed. Returns how many were deleted. Never throws.
  Future<int> sweepStale();
}

/// [OcrTempFileSweeper] for the app's own cache folder.
class CacheOcrTempFileSweeper implements OcrTempFileSweeper {
  const CacheOcrTempFileSweeper({this.cacheDirectory, this.now});

  /// Finds the cache folder. Defaults to `getTemporaryDirectory`. Injected in
  /// tests.
  final Future<Directory> Function()? cacheDirectory;

  /// The current time. Injected in tests.
  final DateTime Function()? now;

  @override
  Future<Directory> tempDirectory() async {
    try {
      return await (cacheDirectory ?? getTemporaryDirectory)();
    } catch (e) {
      // No platform folder (for example in a host test). The system temp
      // folder is the next best private place.
      AppLogger.warning('OcrTempFileSweeper: cache folder unavailable');
      return Directory.systemTemp;
    }
  }

  @override
  Future<void> deleteNow(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final root = p.canonicalize((await tempDirectory()).path);
      final target = p.canonicalize(path);
      if (!p.isWithin(root, target)) return;

      final file = File(target);
      if (file.existsSync()) file.deleteSync();

      // The picker copies a gallery photo into a folder of its own inside the
      // cache. Remove that folder too once it is empty.
      final parent = file.parent;
      if (p.isWithin(root, parent.path) &&
          parent.existsSync() &&
          parent.listSync().isEmpty) {
        parent.deleteSync();
      }
    } catch (e) {
      AppLogger.warning('OcrTempFileSweeper: could not delete a scan file');
    }
  }

  @override
  Future<int> sweepStale() async {
    var deleted = 0;
    try {
      final root = await tempDirectory();
      if (!root.existsSync()) return 0;
      final cutoff = (now ?? DateTime.now)().subtract(kOcrTempFileMinAge);

      for (final entity in root.listSync(followLinks: false)) {
        if (entity is Directory) {
          if (_deletePickerFolder(entity, cutoff)) deleted++;
          continue;
        }
        if (entity is! File) continue;
        final name = p.basename(entity.path);
        if (!kOcrTempFilePrefixes.any(name.startsWith)) continue;
        try {
          if (entity.lastModifiedSync().isAfter(cutoff)) continue;
          entity.deleteSync();
          deleted++;
        } catch (_) {
          // In use or already gone; the next sweep tries again.
        }
      }
    } catch (e) {
      AppLogger.warning('OcrTempFileSweeper: sweep failed');
    }
    if (deleted > 0) {
      AppLogger.info('OcrTempFileSweeper: removed $deleted old scan files');
    }
    return deleted;
  }

  /// The gallery picker copies each photo into `cache/<uuid>/<name>`. Such a
  /// folder is removed when it is old enough and holds only files, so a
  /// folder anything else made is never touched.
  bool _deletePickerFolder(Directory dir, DateTime cutoff) {
    if (!_pickerFolderName.hasMatch(p.basename(dir.path))) return false;
    try {
      final children = dir.listSync(followLinks: false);
      if (children.any((child) => child is! File)) return false;
      // The photo's own age; the folder's only when it is empty.
      final newest = children.isEmpty
          ? dir.statSync().modified
          : children
                .map((child) => child.statSync().modified)
                .reduce((a, b) => a.isAfter(b) ? a : b);
      if (newest.isAfter(cutoff)) return false;
      dir.deleteSync(recursive: true);
      return true;
    } catch (_) {
      // In use or already gone; the next sweep tries again.
      return false;
    }
  }
}
