import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_journal_vault/core/security/file_picker_cache.dart';
import 'package:sreerajp_journal_vault/core/security/stale_file_sweeper.dart';
import 'package:sreerajp_journal_vault/core/security/external_handoff_guard.dart';

/// A backup file the user chose from outside the app.
class PickedBackupFile {
  const PickedBackupFile({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

/// Lets the user point at a backup file anywhere on the device.
///
/// Layer: service. Behind an interface so tests can substitute a fake.
abstract class BackupFilePicker {
  /// Returns the chosen file, or null if the user backed out.
  Future<PickedBackupFile?> pickBackupFile();

  /// Deletes the copy [pickBackupFile] made. Call when the restore screen
  /// closes. Never throws.
  Future<void> discardStagedCopy();
}

/// [BackupFilePicker] backed by the system file picker.
///
/// Holds at most one staged copy, in the cache's
/// [restoreStagingDirectoryName] folder. The picker's own copy is deleted as
/// soon as the staged copy exists.
class FilePickerBackupFilePicker implements BackupFilePicker {
  @override
  Future<PickedBackupFile?> pickBackupFile() async {
    try {
      // `withData` is deliberately off: a backup can be large, and the
      // restore service reads it from the path anyway.
      final result = await ExternalHandoffGuard.instance.run(
        FilePicker.pickFiles,
      );
      if (result == null || result.files.isEmpty) return null;

      final picked = result.files.first;
      final path = picked.path;
      if (path == null) return null;

      // Some providers hand back a cached copy that can vanish while the user
      // is still typing the password. Copy it somewhere we control first.
      final stagedDir = await _stagingDirectory();
      // One staged backup at a time: an earlier pick is no longer needed.
      if (stagedDir.existsSync()) await stagedDir.delete(recursive: true);
      await stagedDir.create(recursive: true);
      final staged = File(p.join(stagedDir.path, picked.name));
      await File(path).copy(staged.path);

      return PickedBackupFile(path: staged.path, fileName: picked.name);
    } finally {
      await clearFilePickerCache();
    }
  }

  @override
  Future<void> discardStagedCopy() async {
    try {
      final stagedDir = await _stagingDirectory();
      if (stagedDir.existsSync()) await stagedDir.delete(recursive: true);
    } catch (_) {
      // The startup sweep clears it.
    }
  }

  Future<Directory> _stagingDirectory() async {
    final tempDir = await getTemporaryDirectory();
    return Directory(p.join(tempDir.path, restoreStagingDirectoryName));
  }
}
