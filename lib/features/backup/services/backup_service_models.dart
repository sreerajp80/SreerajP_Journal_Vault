part of 'backup_service.dart';

class _PayloadFileReport {
  const _PayloadFileReport({required this.included, required this.failed});

  final int included;
  final int failed;
}

class BackupResult {
  const BackupResult({
    required this.path,
    required this.sizeBytes,
    required this.entryCount,
    required this.attachmentCount,
    this.filesIncluded = 0,
    this.filesFailed = 0,
  });

  final String path;
  final int sizeBytes;
  final int entryCount;
  final int attachmentCount;

  /// Attachment and voice-note files written into the archive.
  final int filesIncluded;

  /// Files that could not be read or decrypted, so the archive does not hold
  /// them. Their database rows are still in the backup.
  final int filesFailed;
}

class BackupVerification {
  const BackupVerification({
    required this.isValid,
    this.error,
    this.entryCount,
    this.attachmentCount,
    this.journalCount,
    this.createdAt,
    this.formatVersion,
  });

  final bool isValid;
  final String? error;
  final int? entryCount;
  final int? attachmentCount;
  final int? journalCount;
  final DateTime? createdAt;
  final int? formatVersion;
}

/// One backup file on disk.
class BackupFileInfo {
  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
  });

  final String path;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;
}
