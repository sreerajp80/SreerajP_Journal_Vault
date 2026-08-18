import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
}

/// [BackupFilePicker] backed by the system file picker.
class FilePickerBackupFilePicker implements BackupFilePicker {
  @override
  Future<PickedBackupFile?> pickBackupFile() async {
    // `withData` is deliberately off: a backup can be large, and the restore
    // service reads it from the path anyway.
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.first;
    final path = picked.path;
    if (path == null) return null;

    // Some providers hand back a cached copy that can vanish while the user
    // is still typing the password. Copy it somewhere we control first.
    final tempDir = await getTemporaryDirectory();
    final stagedDir = Directory(p.join(tempDir.path, 'restore_staging'));
    await stagedDir.create(recursive: true);
    final staged = File(p.join(stagedDir.path, picked.name));
    await File(path).copy(staged.path);

    return PickedBackupFile(path: staged.path, fileName: picked.name);
  }
}
