part of 'app_database.dart';

class Journals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  TextColumn get credentialReference => text().nullable()();
  TextColumn get passwordSaltBase64 => text().nullable()();
  TextColumn get passwordVerifierBase64 => text().nullable()();
  IntColumn get passwordIterations => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get journalId => integer().references(Journals, #id)();
  TextColumn get title => text().nullable()();
  TextColumn get contentJson => text().nullable()();
  TextColumn get plainText => text().nullable()();
  DateTimeColumn get entryDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Display colour as a packed ARGB value.
  ///
  /// Null means "no colour chosen" — the UI falls back to a palette entry
  /// derived from the tag name. See `features/tags/domain/tag_colors.dart`.
  IntColumn get colorArgb => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class JournalTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get journalId => integer().references(Journals, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();
}

/// Per-entry tag assignments for smart tag suggestions.
class EntryTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {entryId, tagId},
  ];
}

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId => integer().references(Entries, #id)();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get encryptedPath => text()();
  TextColumn get nonceBase64 => text()();
  TextColumn get keyReference => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Stores extracted plain text from attachment files for FTS indexing.
///
/// **Supported formats and extraction source:**
/// - `text/plain` (.txt) — file contents read directly.
/// - `application/pdf` (.pdf) — text extracted via platform PDF text-extraction.
/// - `text/markdown` (.md) — file contents read directly.
/// - `text/csv` (.csv) — file contents read directly.
///
/// Unsupported formats (images, audio, video, archives) are not indexed.
class AttachmentTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attachmentId =>
      integer().references(Attachments, #id, onDelete: KeyAction.cascade)();
  TextColumn get extractedText => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Backlinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceEntryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  TextColumn get targetType => text()();
  IntColumn get targetId => integer()();
}

class SearchPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get query => text()();
  TextColumn get resultType => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get attachmentStorageLocation =>
      text().withDefault(const Constant('app_private'))();
  TextColumn get attachmentStorageTreeUri => text().nullable()();
  TextColumn get attachmentStorageTreeLabel => text().nullable()();
  TextColumn get attachmentMigrationStatus =>
      text().withDefault(const Constant('idle'))();
  TextColumn get attachmentMigrationTarget => text().nullable()();
  TextColumn get attachmentMigrationFailure => text().nullable()();
  IntColumn get attachmentMigrationProcessedCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get attachmentMigrationTotalCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSecurity extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get lockMode => text().nullable()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}

/// Stores snapshot revisions of entry content for version history.
///
/// Each revision captures a full copy of the entry's title, contentJson,
/// and plainText at the time of save. Revisions are immutable — restoring
/// a revision creates a new revision from the restored content rather than
/// deleting newer revisions.
class EntryRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().nullable()();
  TextColumn get contentJson => text().nullable()();
  TextColumn get plainText => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tracks backup execution history for the backup health dashboard.
///
/// Each row represents a single backup attempt, whether successful or failed.
/// The [status] field is one of: 'success', 'failed', 'in_progress'.
class BackupLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get status => text()(); // 'success', 'failed', 'in_progress'
  TextColumn get backupPath => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  IntColumn get entryCount => integer().withDefault(const Constant(0))();
  IntColumn get attachmentCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get trigger =>
      text().withDefault(const Constant('manual'))(); // 'manual', 'scheduled'
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// Tracks per-record sync metadata for multi-device encrypted sync.
///
/// Each row maps a local record (identified by [tableName] + [localId]) to a
/// deterministic [syncId] (UUID v5 derived from device ID + table + localId).
/// The [version] counter increments on every local mutation and is used for
/// vector-clock–style conflict detection during sync.
class SyncMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordTable => text()(); // e.g. 'journals', 'entries'
  IntColumn get localId => integer()();
  TextColumn get syncId => text()(); // deterministic UUID v5
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get lastModifiedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {recordTable, localId},
    {syncId},
  ];
}

/// Stores detected conflicts during sync that require user resolution.
///
/// When the same record is modified on two devices between sync cycles,
/// both versions are preserved here until the user picks a winner via the
/// conflict resolution UI.
class SyncConflicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text()(); // references SyncMetadata.syncId
  TextColumn get recordTable => text()();
  IntColumn get localVersion => integer()();
  IntColumn get remoteVersion => integer()();
  TextColumn get localDataJson => text()(); // full record snapshot
  TextColumn get remoteDataJson => text()(); // full record snapshot
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending, resolved, dismissed
  TextColumn get resolution =>
      text().nullable()(); // keep_local, keep_remote, merged
  DateTimeColumn get detectedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}

/// Configurable auto-lock profiles that control when the app locks.
///
/// Each profile defines an inactivity timeout and optional schedule.
/// Only one profile can be active at a time.
class AutoLockProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get timeoutSeconds =>
      integer().withDefault(const Constant(300))(); // 5 min default
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  BoolColumn get lockOnMinimize =>
      boolean().withDefault(const Constant(true))();
  TextColumn get scheduleCron =>
      text().nullable()(); // optional cron expression
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Per-attachment lock enabling fine-grained access control.
///
/// When an attachment is locked, it requires re-authentication before
/// the decrypted content can be viewed or exported.
class AttachmentLocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attachmentId =>
      integer().references(Attachments, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isLocked => boolean().withDefault(const Constant(true))();
  TextColumn get credentialReference => text().nullable()();
  DateTimeColumn get lockedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {attachmentId},
  ];
}

/// Logs security-relevant events for audit and tamper detection.
///
/// Events include: failed_auth, lock_triggered, tamper_detected,
/// attachment_locked, attachment_unlocked, profile_changed, export_attempt.
class SecurityEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventType => text()(); // e.g. 'failed_auth', 'tamper_detected'
  TextColumn get severity =>
      text().withDefault(const Constant('info'))(); // info, warning, critical
  TextColumn get description => text()();
  TextColumn get metadata => text().nullable()(); // JSON details
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Stores mood ratings for journal entries to power mood trend insights.
///
/// Mood is a 1-5 scale (1 = very low, 5 = very high). Users can edit
/// mood ratings after the fact.
class EntryMoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  IntColumn get mood => integer()(); // 1-5
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {entryId},
  ];
}

/// Tracks sync execution history for the sync health dashboard.
class SyncLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get status =>
      text()(); // 'success', 'failed', 'in_progress', 'partial'
  TextColumn get direction => text().withDefault(
    const Constant('bidirectional'),
  )(); // push, pull, bidirectional
  IntColumn get recordsPushed => integer().withDefault(const Constant(0))();
  IntColumn get recordsPulled => integer().withDefault(const Constant(0))();
  IntColumn get conflictsDetected => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// Stores voice note recordings associated with an entry.
///
/// Voice notes are encrypted using the same AES-256-GCM scheme as
/// attachments. An optional transcript is stored alongside the audio.
class VoiceNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileName => text()();
  TextColumn get encryptedPath => text()();
  TextColumn get nonceBase64 => text()();
  TextColumn get keyReference => text()();
  IntColumn get durationMs => integer()();
  TextColumn get transcript => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Stores user-created entry templates with customizable titles and starter content.
class UserTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get defaultTitle => text().nullable()();
  TextColumn get contentJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Cryptographically sealed time capsule letter to future self.
///
/// When an entry is sealed:
/// - The body content is encrypted under a dedicated AES-256-GCM key.
/// - The cleartext in `entries` table (`plainText` and `contentJson`) is wiped (nulled).
/// - The entry is excluded from FTS search results.
/// - The app's date-gated release engine refuses decryption until [unlockDate] arrives.
class TimeCapsules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get unlockDate => dateTime()();
  DateTimeColumn get sealedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isOpened => boolean().withDefault(const Constant(false))();
  DateTimeColumn get openedAt => dateTime().nullable()();
  TextColumn get sealedCiphertext => text()(); // AES-256-GCM ciphertext
  TextColumn get ivBase64 => text()();
  TextColumn get macBase64 => text()();
  TextColumn get sealedKeyCiphertext => text().nullable()();
  TextColumn get teaserMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {entryId},
  ];
}

/// Stores user-created reflection cards for the Sanathana Dharma ritual deck.
///
/// Curated cards ship with the app as Dart constants; this table holds only
/// cards the user writes themselves. The [theme] column stores the
/// `RitualTheme` enum name so it can be parsed back on read.
class UserRitualCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get theme => text()();
  TextColumn get title => text()();
  TextColumn get prompt => text()();
  TextColumn get quote => text()();
  TextColumn get quoteAuthor => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ──────────────────────────── DAOs ────────────────────────────
