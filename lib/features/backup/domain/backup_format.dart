/// Backup archive format: versions, manifest, and the errors a reader can hit.
///
/// Layer: domain. Pure Dart — no database, no file system, no widgets.
///
/// The format is deliberately self-describing. Every archive says which format
/// version wrote it and which database schema it came from, so a reader can
/// tell "older, still fine" from "newer, I do not understand this".
library;

import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';

/// Format version written by this build.
///
/// * 1 — the original archive. Manifest holds `version`, entry/attachment/
///   journal counts and a timestamp. Attachment files are stored **still
///   encrypted with the device key**, so they only open on the device that
///   made them.
/// * 2 — adds `formatVersion`, `schemaVersion` and per-table counts to the
///   manifest, exports entry moods and saved search presets, and stores
///   attachment and voice-note files as **plain bytes inside the encrypted
///   archive**, so they restore onto any device.
const int backupFormatVersion = 2;

/// The oldest format this build can read.
const int minimumSupportedBackupFormatVersion = 1;

/// Shortest backup password we accept.
///
/// The rule lives in `core/security/vault_envelope.dart` now, because the
/// export file uses the same one. This name is kept so backup code and its
/// tests still read as backup code.
const int minimumBackupPasswordLength = minimumVaultPasswordLength;

/// Name of the manifest file inside the archive.
const String backupManifestFileName = 'manifest.json';

/// Name of the database dump inside the archive.
const String backupDatabaseFileName = 'database.json';

/// Folder inside the archive holding attachment files.
const String backupAttachmentsFolder = 'attachments';

/// Folder inside the archive holding voice-note files.
const String backupVoiceNotesFolder = 'voice_notes';

// Detail codes on [BackupCorruptedException]. Copied from `sreerajp_todo` so
// the two apps report the same three failures by the same names.

/// The password did not open the archive.
const String backupWrongPasswordDetails = vaultWrongPasswordDetails;

/// The file is not a backup, or its contents are damaged.
const String backupInvalidArchiveDetails = vaultInvalidDataDetails;

/// The database failed `PRAGMA integrity_check` after a restore.
const String backupIntegrityCheckFailedDetails = 'integrity_check_failed';

/// What the archive says about itself.
class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    this.schemaVersion,
    this.createdAt,
    this.appVersion,
    this.entryCount = 0,
    this.attachmentCount = 0,
    this.journalCount = 0,
    this.tableCounts = const {},
  });

  /// Reads a manifest map. A map with no `formatVersion` is a version 1
  /// archive — the field did not exist yet.
  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    final rawTables = json['tables'];
    return BackupManifest(
      formatVersion: _asInt(json['formatVersion']) ?? 1,
      schemaVersion: _asInt(json['schemaVersion']),
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      appVersion: json['appVersion'] as String?,
      entryCount: _asInt(json['entryCount']) ?? 0,
      attachmentCount: _asInt(json['attachmentCount']) ?? 0,
      journalCount: _asInt(json['journalCount']) ?? 0,
      tableCounts: rawTables is Map
          ? {
              for (final entry in rawTables.entries)
                if (_asInt(entry.value) != null)
                  entry.key.toString(): _asInt(entry.value)!,
            }
          : const {},
    );
  }

  final int formatVersion;

  /// Database schema the archive was written from. Null in version 1
  /// archives, which did not record it.
  final int? schemaVersion;

  final DateTime? createdAt;
  final String? appVersion;
  final int entryCount;
  final int attachmentCount;
  final int journalCount;

  /// Row count per exported table. Empty in version 1 archives.
  final Map<String, int> tableCounts;

  /// True when the archive stores attachment bytes in the clear inside the
  /// encrypted container, so they can be re-encrypted for this device.
  ///
  /// False for version 1 archives, whose files carry the original device's
  /// encryption and cannot be opened anywhere else.
  bool get carriesPortableAttachments => formatVersion >= 2;

  Map<String, dynamic> toJson() => {
    // `version` is kept so an older build still recognises the file.
    'version': 1,
    'formatVersion': formatVersion,
    if (schemaVersion != null) 'schemaVersion': schemaVersion,
    if (appVersion != null) 'appVersion': appVersion,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    'entryCount': entryCount,
    'attachmentCount': attachmentCount,
    'journalCount': journalCount,
    'tables': tableCounts,
  };

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}

/// Thrown when an archive comes from a build newer than this one.
///
/// Raised for both a newer archive format and a newer database schema; the
/// user cannot act on the difference, and the advice is the same either way:
/// update the app.
class BackupVersionTooNewException implements Exception {
  const BackupVersionTooNewException(
    this.backupVersion,
    this.appVersion, {
    this.isSchemaVersion = false,
    this.message = 'This backup was created by a newer version of the app.',
  });

  final int backupVersion;
  final int appVersion;

  /// True when the mismatch is the database schema, false when it is the
  /// archive format.
  final bool isSchemaVersion;

  final String message;

  @override
  String toString() =>
      'BackupVersionTooNewException: $message '
      '(backupVersion: $backupVersion, appVersion: $appVersion, '
      'isSchemaVersion: $isSchemaVersion)';
}

/// Thrown when a file is not a backup, is damaged, or the password is wrong.
///
/// The same class the envelope throws — a wrong password and a tampered file
/// are one event to AES-GCM, wherever the file came from.
typedef BackupCorruptedException = VaultCorruptedException;

/// Thrown when the password is too short or empty.
typedef BackupPasswordException = VaultPasswordException;

/// Rejects a password that is empty or shorter than
/// [minimumBackupPasswordLength].
void validateBackupPassword(String password) => validateVaultPassword(password);
