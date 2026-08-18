/// Models describing what a backup holds and what a restore did.
///
/// Layer: domain. Pure Dart — no database, no file system, no widgets.
library;

import 'package:sreerajp_journal_vault/features/backup/domain/backup_format.dart';

/// How an archive is applied to the current data.
enum RestoreMode {
  /// Clear the user-data tables first, then insert everything the archive
  /// holds. The result is exactly the backup.
  replace,

  /// Insert only what is missing and leave existing rows alone. The result is
  /// the current data plus anything the backup had that it did not.
  merge,
}

/// What an archive contains, read without touching the app's data.
class BackupPreview {
  const BackupPreview({
    required this.manifest,
    required this.tableCounts,
    required this.attachmentFileCount,
    required this.voiceNoteFileCount,
    required this.sizeBytes,
  });

  final BackupManifest manifest;

  /// Rows actually present in the archive, counted from the dump rather than
  /// trusted from the manifest.
  final Map<String, int> tableCounts;

  final int attachmentFileCount;
  final int voiceNoteFileCount;

  /// Size of the archive file on disk.
  final int sizeBytes;

  int get entryCount => tableCounts['entries'] ?? 0;
  int get journalCount => tableCounts['journals'] ?? 0;
  int get attachmentCount => tableCounts['attachments'] ?? 0;

  /// True when the attachments in this archive can be opened after restoring
  /// onto a different device.
  bool get hasPortableAttachments => manifest.carriesPortableAttachments;
}

/// Rows added and rows left alone, per table.
class RestoreTableOutcome {
  const RestoreTableOutcome({this.added = 0, this.skipped = 0});

  /// Rows inserted.
  final int added;

  /// Rows the archive held that were already present, so nothing was written.
  final int skipped;

  RestoreTableOutcome copyWith({int? added, int? skipped}) =>
      RestoreTableOutcome(
        added: added ?? this.added,
        skipped: skipped ?? this.skipped,
      );

  RestoreTableOutcome plusAdded([int count = 1]) =>
      copyWith(added: added + count);

  RestoreTableOutcome plusSkipped([int count = 1]) =>
      copyWith(skipped: skipped + count);
}

/// What a restore did, or — for a dry run — what it would have done.
class RestoreResult {
  const RestoreResult({
    required this.mode,
    required this.wasDryRun,
    required this.tables,
    this.rowsCleared = 0,
    this.attachmentFilesRestored = 0,
    this.attachmentFilesFailed = 0,
    this.voiceNoteFilesRestored = 0,
    this.voiceNoteFilesFailed = 0,
    this.safetyBackupPath,
    this.warnings = const [],
  });

  final RestoreMode mode;

  /// True when nothing was written. Every count below is then a forecast.
  final bool wasDryRun;

  final Map<String, RestoreTableOutcome> tables;

  /// Rows deleted by a replace before inserting.
  final int rowsCleared;

  final int attachmentFilesRestored;
  final int attachmentFilesFailed;
  final int voiceNoteFilesRestored;
  final int voiceNoteFilesFailed;

  /// Where the automatic pre-restore backup was written, when a replace made
  /// one. Null for a merge or a dry run.
  final String? safetyBackupPath;

  /// Things the user should know that did not stop the restore — for example
  /// attachments from a version 1 archive that this device cannot decrypt.
  final List<RestoreWarning> warnings;

  int get totalAdded =>
      tables.values.fold(0, (sum, outcome) => sum + outcome.added);

  int get totalSkipped =>
      tables.values.fold(0, (sum, outcome) => sum + outcome.skipped);

  int get entriesAdded => tables['entries']?.added ?? 0;

  int get entriesSkipped => tables['entries']?.skipped ?? 0;
}

/// A non-fatal problem worth telling the user about after a restore.
enum RestoreWarning {
  /// The archive predates portable attachments, so its attachment files carry
  /// another device's encryption and will not open here.
  legacyAttachmentsNotPortable,

  /// One or more attachment files could not be written or re-encrypted. The
  /// entries themselves restored.
  someAttachmentFilesFailed,

  /// One or more voice-note files could not be written or re-encrypted.
  someVoiceNoteFilesFailed,

  /// The archive held no attachment files even though rows referenced them.
  attachmentFilesMissingFromArchive,
}
