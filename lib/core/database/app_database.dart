import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/links/vault_backlinks.dart';

part 'app_database.g.dart';

// ──────────────────────────── Tables ────────────────────────────

class Journals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isLocked =>
      boolean().withDefault(const Constant(false))();
  TextColumn get credentialReference => text().nullable()();
  TextColumn get passwordSaltBase64 => text().nullable()();
  TextColumn get passwordVerifierBase64 => text().nullable()();
  IntColumn get passwordIterations => integer().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get journalId => integer().references(Journals, #id)();
  TextColumn get title => text().nullable()();
  TextColumn get contentJson => text().nullable()();
  TextColumn get plainText => text().nullable()();
  DateTimeColumn get entryDate => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Backlinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceEntryId => integer()
      .references(Entries, #id, onDelete: KeyAction.cascade)();
  TextColumn get targetType => text()();
  IntColumn get targetId => integer()();
}

class SearchPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get query => text()();
  TextColumn get resultType => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class AppSecurity extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get lockMode => text().nullable()();
  BoolColumn get isLocked =>
      boolean().withDefault(const Constant(false))();
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
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  TextColumn get trigger => text().withDefault(const Constant('manual'))(); // 'manual', 'scheduled'
  DateTimeColumn get startedAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
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
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, resolved, dismissed
  TextColumn get resolution => text().nullable()(); // keep_local, keep_remote, merged
  DateTimeColumn get detectedAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get lockOnMinimize =>
      boolean().withDefault(const Constant(true))();
  TextColumn get scheduleCron => text().nullable()(); // optional cron expression
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Per-attachment lock enabling fine-grained access control.
///
/// When an attachment is locked, it requires re-authentication before
/// the decrypted content can be viewed or exported.
class AttachmentLocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attachmentId =>
      integer().references(Attachments, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isLocked =>
      boolean().withDefault(const Constant(true))();
  TextColumn get credentialReference => text().nullable()();
  DateTimeColumn get lockedAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {entryId},
      ];
}

/// Tracks sync execution history for the sync health dashboard.
class SyncLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get status => text()(); // 'success', 'failed', 'in_progress', 'partial'
  TextColumn get direction =>
      text().withDefault(const Constant('bidirectional'))(); // push, pull, bidirectional
  IntColumn get recordsPushed => integer().withDefault(const Constant(0))();
  IntColumn get recordsPulled => integer().withDefault(const Constant(0))();
  IntColumn get conflictsDetected =>
      integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get startedAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ──────────────────────────── DAOs ────────────────────────────

@DriftAccessor(tables: [Journals])
class JournalsDao extends DatabaseAccessor<AppDatabase>
    with _$JournalsDaoMixin {
  JournalsDao(super.db);

  Future<int> createJournal(JournalsCompanion companion) =>
      into(journals).insert(companion);

  Future<List<Journal>> getAllJournals() => select(journals).get();

  Future<Journal> getJournalById(int id) =>
      (select(journals)..where((t) => t.id.equals(id))).getSingle();

  Future<void> updateJournalById(int id, JournalsCompanion companion) =>
      (update(journals)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteJournalById(int id) =>
      (delete(journals)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Entries])
class EntriesDao extends DatabaseAccessor<AppDatabase>
    with _$EntriesDaoMixin {
  EntriesDao(super.db);

  Future<int> createEntry(EntriesCompanion companion) =>
      into(entries).insert(companion);

  Future<List<Entry>> getEntriesForJournal(int journalId) =>
      (select(entries)..where((t) => t.journalId.equals(journalId))).get();

  Stream<List<Entry>> watchEntriesForJournal(int journalId) =>
      (select(entries)..where((t) => t.journalId.equals(journalId))).watch();

  Future<Entry> getEntryById(int id) =>
      (select(entries)..where((t) => t.id.equals(id))).getSingle();

  Future<void> updateEntryById(int id, EntriesCompanion companion) =>
      (update(entries)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteEntryById(int id) =>
      (delete(entries)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Tags, EntryTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Future<int> createTag(TagsCompanion companion) =>
      into(tags).insert(companion);

  Future<List<Tag>> getAllTags() => select(tags).get();

  Future<void> updateTagById(int id, TagsCompanion companion) =>
      (update(tags)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteTagById(int id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

  Future<List<Tag>> getTagsForEntry(int entryId) async {
    final query = select(tags).join([
      innerJoin(entryTags, entryTags.tagId.equalsExp(tags.id)),
    ])
      ..where(entryTags.entryId.equals(entryId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(tags)).toList();
  }

  Future<void> addTagToEntry(int entryId, int tagId) =>
      into(entryTags).insert(
        EntryTagsCompanion.insert(entryId: entryId, tagId: tagId),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> removeTagFromEntry(int entryId, int tagId) =>
      (delete(entryTags)
            ..where(
                (t) => t.entryId.equals(entryId) & t.tagId.equals(tagId)))
          .go();

  Future<int> getOrCreateTag(String name) async {
    final trimmed = name.trim().toLowerCase();
    final existing = await (select(tags)
          ..where((t) => t.name.equals(trimmed)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(tags).insert(TagsCompanion.insert(name: trimmed));
  }
}

@DriftAccessor(tables: [AttachmentTexts])
class AttachmentTextsDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentTextsDaoMixin {
  AttachmentTextsDao(super.db);

  Future<int> upsertExtractedText(int attachmentId, String text) =>
      into(attachmentTexts).insert(
        AttachmentTextsCompanion.insert(
          attachmentId: attachmentId,
          extractedText: text,
        ),
        mode: InsertMode.replace,
      );

  Future<void> deleteForAttachment(int attachmentId) =>
      (delete(attachmentTexts)
            ..where((t) => t.attachmentId.equals(attachmentId)))
          .go();
}

@DriftAccessor(tables: [Backlinks])
class BacklinksDao extends DatabaseAccessor<AppDatabase>
    with _$BacklinksDaoMixin {
  BacklinksDao(super.db);

  Future<void> replaceBacklinksForEntry(
    int sourceEntryId,
    List<VaultBacklinkTarget> targets,
  ) async {
    await (delete(backlinks)
          ..where((t) => t.sourceEntryId.equals(sourceEntryId)))
        .go();
    for (final target in targets) {
      await into(backlinks).insert(BacklinksCompanion.insert(
        sourceEntryId: sourceEntryId,
        targetType: target.type.name,
        targetId: target.targetId,
      ));
    }
  }

  Stream<List<Backlink>> watchBacklinksForJournalTarget(int targetId) =>
      (select(backlinks)
            ..where((t) =>
                t.targetType.equals('journal') &
                t.targetId.equals(targetId)))
          .watch();

  Stream<List<Backlink>> watchBacklinksForEntryTarget(int targetId) =>
      (select(backlinks)
            ..where((t) =>
                t.targetType.equals('entry') &
                t.targetId.equals(targetId)))
          .watch();

  Future<List<Backlink>> getBacklinksForEntryTarget(int targetId) =>
      (select(backlinks)
            ..where((t) =>
                t.targetType.equals('entry') &
                t.targetId.equals(targetId)))
          .get();
}

@DriftAccessor(tables: [EntryRevisions])
class EntryRevisionsDao extends DatabaseAccessor<AppDatabase>
    with _$EntryRevisionsDaoMixin {
  EntryRevisionsDao(super.db);

  Future<int> createRevision(EntryRevisionsCompanion companion) =>
      into(entryRevisions).insert(companion);

  Future<List<EntryRevision>> getRevisionsForEntry(int entryId) =>
      (select(entryRevisions)
            ..where((t) => t.entryId.equals(entryId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Stream<List<EntryRevision>> watchRevisionsForEntry(int entryId) =>
      (select(entryRevisions)
            ..where((t) => t.entryId.equals(entryId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<EntryRevision> getRevisionById(int id) =>
      (select(entryRevisions)..where((t) => t.id.equals(id))).getSingle();

  Future<void> deleteRevisionById(int id) =>
      (delete(entryRevisions)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllForEntry(int entryId) =>
      (delete(entryRevisions)..where((t) => t.entryId.equals(entryId))).go();
}

@DriftAccessor(tables: [VoiceNotes])
class VoiceNotesDao extends DatabaseAccessor<AppDatabase>
    with _$VoiceNotesDaoMixin {
  VoiceNotesDao(super.db);

  Future<int> createVoiceNote(VoiceNotesCompanion companion) =>
      into(voiceNotes).insert(companion);

  Future<List<VoiceNote>> getVoiceNotesForEntry(int entryId) =>
      (select(voiceNotes)
            ..where((t) => t.entryId.equals(entryId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Stream<List<VoiceNote>> watchVoiceNotesForEntry(int entryId) =>
      (select(voiceNotes)
            ..where((t) => t.entryId.equals(entryId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<void> updateTranscript(int id, String transcript) =>
      (update(voiceNotes)..where((t) => t.id.equals(id)))
          .write(VoiceNotesCompanion(transcript: Value(transcript)));

  Future<void> deleteVoiceNoteById(int id) =>
      (delete(voiceNotes)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [BackupLogs])
class BackupLogsDao extends DatabaseAccessor<AppDatabase>
    with _$BackupLogsDaoMixin {
  BackupLogsDao(super.db);

  Future<int> createLog(BackupLogsCompanion companion) =>
      into(backupLogs).insert(companion);

  Future<void> updateLog(int id, BackupLogsCompanion companion) =>
      (update(backupLogs)..where((t) => t.id.equals(id))).write(companion);

  Future<List<BackupLog>> getAllLogs() =>
      (select(backupLogs)..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();

  Future<List<BackupLog>> getRecentLogs({int limit = 20}) =>
      (select(backupLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit))
          .get();

  Future<BackupLog?> getLatestSuccessful() =>
      (select(backupLogs)
            ..where((t) => t.status.equals('success'))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> getFailureCountSince(DateTime since) async {
    final rows = await (select(backupLogs)
          ..where(
              (t) => t.status.equals('failed') & t.startedAt.isBiggerOrEqualValue(since)))
        .get();
    return rows.length;
  }

  Future<void> deleteOldLogs({int keepCount = 50}) async {
    final all = await getAllLogs();
    if (all.length <= keepCount) return;
    final idsToDelete = all.skip(keepCount).map((l) => l.id).toList();
    await (delete(backupLogs)..where((t) => t.id.isIn(idsToDelete))).go();
  }
}

@DriftAccessor(tables: [SearchPresets])
class SearchPresetsDao extends DatabaseAccessor<AppDatabase>
    with _$SearchPresetsDaoMixin {
  SearchPresetsDao(super.db);

  Future<int> createPreset(SearchPresetsCompanion companion) =>
      into(searchPresets).insert(companion);

  Future<List<SearchPreset>> getAllPresets() =>
      select(searchPresets).get();

  Future<void> updatePresetById(
      int id, SearchPresetsCompanion companion) =>
      (update(searchPresets)..where((t) => t.id.equals(id)))
          .write(companion);

  Future<void> deletePresetById(int id) =>
      (delete(searchPresets)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Attachments])
class AttachmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentsDaoMixin {
  AttachmentsDao(super.db);

  Future<int> createAttachment(AttachmentsCompanion companion) =>
      into(attachments).insert(companion);

  Future<List<Attachment>> getAttachmentsForEntry(int entryId) =>
      (select(attachments)..where((t) => t.entryId.equals(entryId))).get();

  Stream<List<Attachment>> watchAttachmentsForEntry(int entryId) =>
      (select(attachments)..where((t) => t.entryId.equals(entryId))).watch();

  Future<List<Attachment>> getAllAttachments() => select(attachments).get();

  Future<Attachment> getAttachmentById(int id) =>
      (select(attachments)..where((t) => t.id.equals(id))).getSingle();

  Future<void> deleteAttachmentById(int id) =>
      (delete(attachments)..where((t) => t.id.equals(id))).go();

  Future<void> updateAttachment(AttachmentsCompanion companion) =>
      (update(attachments)..where((t) => t.id.equals(companion.id.value)))
          .write(companion);
}

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<AppSetting> getSettings() async {
    final rows = await select(appSettings).get();
    if (rows.isEmpty) {
      final id =
          await into(appSettings).insert(AppSettingsCompanion.insert());
      return (select(appSettings)..where((t) => t.id.equals(id)))
          .getSingle();
    }
    return rows.first;
  }

  Future<void> updateSettings(AppSettingsCompanion companion) async {
    final settings = await getSettings();
    await (update(appSettings)..where((t) => t.id.equals(settings.id)))
        .write(companion);
  }
}

@DriftAccessor(tables: [AppSecurity])
class AppSecurityDao extends DatabaseAccessor<AppDatabase>
    with _$AppSecurityDaoMixin {
  AppSecurityDao(super.db);

  Future<AppSecurityData> getSecuritySettings() async {
    final rows = await select(appSecurity).get();
    if (rows.isEmpty) {
      final id =
          await into(appSecurity).insert(AppSecurityCompanion.insert());
      return (select(appSecurity)..where((t) => t.id.equals(id)))
          .getSingle();
    }
    return rows.first;
  }

  Future<void> updateLockState(AppSecurityCompanion companion) async {
    final settings = await getSecuritySettings();
    await (update(appSecurity)..where((t) => t.id.equals(settings.id)))
        .write(companion);
  }
}

@DriftAccessor(tables: [JournalTags, Tags])
class JournalTagsDao extends DatabaseAccessor<AppDatabase>
    with _$JournalTagsDaoMixin {
  JournalTagsDao(super.db);

  Future<List<Tag>> getTagsForJournal(int journalId) async {
    final query = select(tags).join([
      innerJoin(journalTags, journalTags.tagId.equalsExp(tags.id)),
    ])
      ..where(journalTags.journalId.equals(journalId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(tags)).toList();
  }

  Future<void> addTagToJournal(int journalId, int tagId) =>
      into(journalTags).insert(
        JournalTagsCompanion.insert(journalId: journalId, tagId: tagId),
      );

  Future<void> removeTagFromJournal(int journalId, int tagId) =>
      (delete(journalTags)
            ..where(
                (t) => t.journalId.equals(journalId) & t.tagId.equals(tagId)))
          .go();
}

@DriftAccessor(tables: [SyncMetadata])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetadataDaoMixin {
  SyncMetadataDao(super.db);

  Future<int> upsert(SyncMetadataCompanion companion) =>
      into(syncMetadata).insert(
        companion,
        mode: InsertMode.insertOrReplace,
      );

  Future<SyncMetadataData?> getBySyncId(String syncId) =>
      (select(syncMetadata)..where((t) => t.syncId.equals(syncId)))
          .getSingleOrNull();

  Future<SyncMetadataData?> getByRecord(String table, int localId) =>
      (select(syncMetadata)
            ..where(
                (t) => t.recordTable.equals(table) & t.localId.equals(localId)))
          .getSingleOrNull();

  Future<List<SyncMetadataData>> getUnsyncedRecords() =>
      (select(syncMetadata)
            ..where((t) => t.lastSyncedAt.isNull() | t.lastModifiedAt.isBiggerThan(t.lastSyncedAt))
            ..where((t) => t.isDeleted.equals(false)))
          .get();

  Future<List<SyncMetadataData>> getModifiedSince(DateTime since) =>
      (select(syncMetadata)
            ..where((t) => t.lastModifiedAt.isBiggerOrEqualValue(since)))
          .get();

  Future<void> markSynced(String syncId, DateTime syncedAt) =>
      (update(syncMetadata)..where((t) => t.syncId.equals(syncId)))
          .write(SyncMetadataCompanion(lastSyncedAt: Value(syncedAt)));

  Future<void> markDeleted(String syncId) =>
      (update(syncMetadata)..where((t) => t.syncId.equals(syncId)))
          .write(const SyncMetadataCompanion(isDeleted: Value(true)));

  Future<void> incrementVersion(String syncId) async {
    final record = await getBySyncId(syncId);
    if (record == null) return;
    await (update(syncMetadata)..where((t) => t.syncId.equals(syncId)))
        .write(SyncMetadataCompanion(
      version: Value(record.version + 1),
      lastModifiedAt: Value(DateTime.now()),
    ));
  }

  Future<List<SyncMetadataData>> getAllForTable(String table) =>
      (select(syncMetadata)..where((t) => t.recordTable.equals(table))).get();
}

@DriftAccessor(tables: [SyncConflicts])
class SyncConflictsDao extends DatabaseAccessor<AppDatabase>
    with _$SyncConflictsDaoMixin {
  SyncConflictsDao(super.db);

  Future<int> createConflict(SyncConflictsCompanion companion) =>
      into(syncConflicts).insert(companion);

  Future<List<SyncConflict>> getPendingConflicts() =>
      (select(syncConflicts)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)]))
          .get();

  Future<int> getPendingConflictCount() async {
    final rows = await getPendingConflicts();
    return rows.length;
  }

  Stream<List<SyncConflict>> watchPendingConflicts() =>
      (select(syncConflicts)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)]))
          .watch();

  Future<SyncConflict> getConflictById(int id) =>
      (select(syncConflicts)..where((t) => t.id.equals(id))).getSingle();

  Future<void> resolveConflict(int id, String resolution) =>
      (update(syncConflicts)..where((t) => t.id.equals(id))).write(
        SyncConflictsCompanion(
          status: const Value('resolved'),
          resolution: Value(resolution),
          resolvedAt: Value(DateTime.now()),
        ),
      );

  Future<void> dismissConflict(int id) =>
      (update(syncConflicts)..where((t) => t.id.equals(id))).write(
        const SyncConflictsCompanion(
          status: Value('dismissed'),
        ),
      );

  Future<List<SyncConflict>> getAllConflicts() =>
      (select(syncConflicts)
            ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)]))
          .get();

  Future<void> deleteOldResolved({int keepCount = 100}) async {
    final resolved = await (select(syncConflicts)
          ..where((t) => t.status.isIn(['resolved', 'dismissed']))
          ..orderBy([(t) => OrderingTerm.desc(t.resolvedAt)]))
        .get();
    if (resolved.length <= keepCount) return;
    final idsToDelete = resolved.skip(keepCount).map((c) => c.id).toList();
    await (delete(syncConflicts)..where((t) => t.id.isIn(idsToDelete))).go();
  }
}

@DriftAccessor(tables: [SyncLogs])
class SyncLogsDao extends DatabaseAccessor<AppDatabase>
    with _$SyncLogsDaoMixin {
  SyncLogsDao(super.db);

  Future<int> createLog(SyncLogsCompanion companion) =>
      into(syncLogs).insert(companion);

  Future<void> updateLog(int id, SyncLogsCompanion companion) =>
      (update(syncLogs)..where((t) => t.id.equals(id))).write(companion);

  Future<List<SyncLog>> getRecentLogs({int limit = 20}) =>
      (select(syncLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit))
          .get();

  Future<SyncLog?> getLatestSuccessful() =>
      (select(syncLogs)
            ..where((t) => t.status.equals('success'))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> getFailureCountSince(DateTime since) async {
    final rows = await (select(syncLogs)
          ..where(
              (t) => t.status.equals('failed') & t.startedAt.isBiggerOrEqualValue(since)))
        .get();
    return rows.length;
  }

  Future<void> deleteOldLogs({int keepCount = 50}) async {
    final all = await (select(syncLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    if (all.length <= keepCount) return;
    final idsToDelete = all.skip(keepCount).map((l) => l.id).toList();
    await (delete(syncLogs)..where((t) => t.id.isIn(idsToDelete))).go();
  }
}

@DriftAccessor(tables: [AutoLockProfiles])
class AutoLockProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$AutoLockProfilesDaoMixin {
  AutoLockProfilesDao(super.db);

  Future<int> createProfile(AutoLockProfilesCompanion companion) =>
      into(autoLockProfiles).insert(companion);

  Future<List<AutoLockProfile>> getAllProfiles() =>
      (select(autoLockProfiles)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<AutoLockProfile?> getActiveProfile() =>
      (select(autoLockProfiles)
            ..where((t) => t.isActive.equals(true))
            ..limit(1))
          .getSingleOrNull();

  Future<void> activateProfile(int id) async {
    // Deactivate all first
    await update(autoLockProfiles).write(
      const AutoLockProfilesCompanion(isActive: Value(false)),
    );
    // Activate the selected one
    await (update(autoLockProfiles)..where((t) => t.id.equals(id))).write(
      AutoLockProfilesCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deactivateAll() => update(autoLockProfiles).write(
        const AutoLockProfilesCompanion(isActive: Value(false)),
      );

  Future<void> updateProfile(int id, AutoLockProfilesCompanion companion) =>
      (update(autoLockProfiles)..where((t) => t.id.equals(id)))
          .write(companion);

  Future<void> deleteProfile(int id) =>
      (delete(autoLockProfiles)..where((t) => t.id.equals(id))).go();

  Stream<AutoLockProfile?> watchActiveProfile() =>
      (select(autoLockProfiles)
            ..where((t) => t.isActive.equals(true))
            ..limit(1))
          .watchSingleOrNull();
}

@DriftAccessor(tables: [AttachmentLocks])
class AttachmentLocksDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentLocksDaoMixin {
  AttachmentLocksDao(super.db);

  Future<int> lockAttachment(AttachmentLocksCompanion companion) =>
      into(attachmentLocks).insert(
        companion,
        mode: InsertMode.insertOrReplace,
      );

  Future<AttachmentLock?> getLockForAttachment(int attachmentId) =>
      (select(attachmentLocks)
            ..where((t) => t.attachmentId.equals(attachmentId)))
          .getSingleOrNull();

  Future<bool> isAttachmentLocked(int attachmentId) async {
    final lock = await getLockForAttachment(attachmentId);
    return lock?.isLocked ?? false;
  }

  Future<void> unlockAttachment(int attachmentId) =>
      (update(attachmentLocks)
            ..where((t) => t.attachmentId.equals(attachmentId)))
          .write(AttachmentLocksCompanion(
        isLocked: const Value(false),
        unlockedAt: Value(DateTime.now()),
      ));

  Future<void> relockAttachment(int attachmentId) =>
      (update(attachmentLocks)
            ..where((t) => t.attachmentId.equals(attachmentId)))
          .write(const AttachmentLocksCompanion(
        isLocked: Value(true),
      ));

  Future<void> removeLock(int attachmentId) =>
      (delete(attachmentLocks)
            ..where((t) => t.attachmentId.equals(attachmentId)))
          .go();

  Future<List<AttachmentLock>> getLockedAttachments() =>
      (select(attachmentLocks)
            ..where((t) => t.isLocked.equals(true)))
          .get();
}

@DriftAccessor(tables: [SecurityEvents])
class SecurityEventsDao extends DatabaseAccessor<AppDatabase>
    with _$SecurityEventsDaoMixin {
  SecurityEventsDao(super.db);

  Future<int> logEvent(SecurityEventsCompanion companion) =>
      into(securityEvents).insert(companion);

  Future<List<SecurityEvent>> getRecentEvents({int limit = 50}) =>
      (select(securityEvents)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<List<SecurityEvent>> getEventsByType(String eventType,
          {int limit = 20}) =>
      (select(securityEvents)
            ..where((t) => t.eventType.equals(eventType))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<List<SecurityEvent>> getCriticalEvents({int limit = 20}) =>
      (select(securityEvents)
            ..where((t) => t.severity.equals('critical'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Stream<List<SecurityEvent>> watchRecentEvents({int limit = 50}) =>
      (select(securityEvents)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .watch();

  Future<int> getEventCountSince(DateTime since) async {
    final rows = await (select(securityEvents)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(since)))
        .get();
    return rows.length;
  }

  Future<void> deleteOldEvents({int keepCount = 500}) async {
    final all = await (select(securityEvents)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    if (all.length <= keepCount) return;
    final idsToDelete = all.skip(keepCount).map((e) => e.id).toList();
    await (delete(securityEvents)..where((t) => t.id.isIn(idsToDelete))).go();
  }
}

@DriftAccessor(tables: [EntryMoods])
class EntryMoodsDao extends DatabaseAccessor<AppDatabase>
    with _$EntryMoodsDaoMixin {
  EntryMoodsDao(super.db);

  Future<int> upsertMood(EntryMoodsCompanion companion) =>
      into(entryMoods).insert(
        companion,
        mode: InsertMode.insertOrReplace,
      );

  Future<EntryMood?> getMoodForEntry(int entryId) =>
      (select(entryMoods)..where((t) => t.entryId.equals(entryId)))
          .getSingleOrNull();

  Future<List<EntryMood>> getAllMoods() =>
      (select(entryMoods)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> deleteMoodForEntry(int entryId) =>
      (delete(entryMoods)..where((t) => t.entryId.equals(entryId))).go();

  Stream<EntryMood?> watchMoodForEntry(int entryId) =>
      (select(entryMoods)..where((t) => t.entryId.equals(entryId)))
          .watchSingleOrNull();
}

// ──────────────────────────── Database ────────────────────────────

// ──────────────────────────── FTS5 helpers ────────────────────────────

/// Result of a full-text search query.
class FtsSearchResult {
  final int entryId;
  final int journalId;
  final String? title;
  final String snippet;
  final double rank;

  const FtsSearchResult({
    required this.entryId,
    required this.journalId,
    this.title,
    required this.snippet,
    required this.rank,
  });
}

/// Entry count on a specific date for the timeline/calendar view.
class DateEntryCount {
  final DateTime date;
  final int count;

  const DateEntryCount({required this.date, required this.count});
}

// ──────────────────────────── Database ────────────────────────────

@DriftDatabase(
  tables: [
    Journals,
    Entries,
    Tags,
    JournalTags,
    EntryTags,
    Attachments,
    AttachmentTexts,
    Backlinks,
    SearchPresets,
    AppSettings,
    AppSecurity,
    EntryRevisions,
    VoiceNotes,
    BackupLogs,
    SyncMetadata,
    SyncConflicts,
    SyncLogs,
    AutoLockProfiles,
    AttachmentLocks,
    SecurityEvents,
    EntryMoods,
  ],
  daos: [
    JournalsDao,
    EntriesDao,
    TagsDao,
    AttachmentsDao,
    AttachmentTextsDao,
    BacklinksDao,
    BackupLogsDao,
    SearchPresetsDao,
    AppSettingsDao,
    AppSecurityDao,
    JournalTagsDao,
    EntryRevisionsDao,
    VoiceNotesDao,
    SyncMetadataDao,
    SyncConflictsDao,
    SyncLogsDao,
    AutoLockProfilesDao,
    AttachmentLocksDao,
    SecurityEventsDao,
    EntryMoodsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createFts5Tables();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(entryTags);
            await m.createTable(attachmentTexts);
            await _createFts5Tables();
            await customStatement('''
              INSERT INTO entries_fts (rowid, title, plain_text)
              SELECT id, COALESCE(title, ''), COALESCE(plain_text, '')
              FROM entries
            ''');
          }
          if (from < 3) {
            await m.createTable(entryRevisions);
            await m.createTable(voiceNotes);
          }
          if (from < 4) {
            await m.createTable(backupLogs);
          }
          if (from < 5) {
            await m.createTable(syncMetadata);
            await m.createTable(syncConflicts);
            await m.createTable(syncLogs);
          }
          if (from < 6) {
            await m.createTable(autoLockProfiles);
            await m.createTable(attachmentLocks);
            await m.createTable(securityEvents);
            await m.createTable(entryMoods);
          }
          if (from < 7) {
            await m.addColumn(appSettings, appSettings.attachmentStorageTreeLabel);
            await m.addColumn(appSettings, appSettings.attachmentMigrationTarget);
            await m.addColumn(appSettings, appSettings.attachmentMigrationFailure);
            await m.addColumn(appSettings, appSettings.updatedAt);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Creates the FTS5 virtual table and synchronisation triggers.
  ///
  /// The FTS5 index covers:
  /// - Entry title and plain_text (from the entries table).
  /// - Attachment extracted text (from attachment_texts, joined via a
  ///   separate content-sync trigger on attachment_texts).
  Future<void> _createFts5Tables() async {
    // Main FTS5 table for entry content.
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts
      USING fts5(
        title,
        plain_text,
        content='entries',
        content_rowid='id'
      )
    ''');

    // Keep FTS in sync when entries change.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ai AFTER INSERT ON entries BEGIN
        INSERT INTO entries_fts(rowid, title, plain_text)
        VALUES (new.id, COALESCE(new.title, ''), COALESCE(new.plain_text, ''));
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ad AFTER DELETE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, title, plain_text)
        VALUES ('delete', old.id, COALESCE(old.title, ''), COALESCE(old.plain_text, ''));
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_au AFTER UPDATE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, title, plain_text)
        VALUES ('delete', old.id, COALESCE(old.title, ''), COALESCE(old.plain_text, ''));
        INSERT INTO entries_fts(rowid, title, plain_text)
        VALUES (new.id, COALESCE(new.title, ''), COALESCE(new.plain_text, ''));
      END
    ''');

    // Separate FTS5 table for attachment extracted text.
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS attachment_text_fts
      USING fts5(
        extracted_text,
        content='attachment_texts',
        content_rowid='id'
      )
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS att_text_ai AFTER INSERT ON attachment_texts BEGIN
        INSERT INTO attachment_text_fts(rowid, extracted_text)
        VALUES (new.id, new.extracted_text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS att_text_ad AFTER DELETE ON attachment_texts BEGIN
        INSERT INTO attachment_text_fts(attachment_text_fts, rowid, extracted_text)
        VALUES ('delete', old.id, old.extracted_text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS att_text_au AFTER UPDATE ON attachment_texts BEGIN
        INSERT INTO attachment_text_fts(attachment_text_fts, rowid, extracted_text)
        VALUES ('delete', old.id, old.extracted_text);
        INSERT INTO attachment_text_fts(rowid, extracted_text)
        VALUES (new.id, new.extracted_text);
      END
    ''');
  }

  // ────────────── Full-text search queries ──────────────

  /// Searches entry content and attachment text using FTS5.
  ///
  /// Returns results ranked by relevance with highlighted snippets.
  Future<List<FtsSearchResult>> searchEntries(String query) async {
    if (query.trim().isEmpty) return [];

    // Sanitise user input for FTS5 — wrap each token in double quotes
    // so special characters are treated as literals.
    final sanitised =
        query.trim().split(RegExp(r'\s+')).map((t) => '"$t"').join(' ');

    // Search entry content.
    final entryResults = await customSelect(
      '''
      SELECT e.id AS entry_id,
             e.journal_id,
             e.title,
             snippet(entries_fts, 1, '<b>', '</b>', '...', 32) AS snippet,
             entries_fts.rank
      FROM entries_fts
      INNER JOIN entries e ON e.id = entries_fts.rowid
      WHERE entries_fts MATCH ?
      ORDER BY entries_fts.rank
      LIMIT 100
      ''',
      variables: [Variable.withString(sanitised)],
    ).get();

    // Search attachment extracted text.
    final attachmentResults = await customSelect(
      '''
      SELECT e.id AS entry_id,
             e.journal_id,
             e.title,
             snippet(attachment_text_fts, 0, '<b>', '</b>', '...', 32) AS snippet,
             attachment_text_fts.rank
      FROM attachment_text_fts
      INNER JOIN attachment_texts at2 ON at2.id = attachment_text_fts.rowid
      INNER JOIN attachments a ON a.id = at2.attachment_id
      INNER JOIN entries e ON e.id = a.entry_id
      WHERE attachment_text_fts MATCH ?
      ORDER BY attachment_text_fts.rank
      LIMIT 50
      ''',
      variables: [Variable.withString(sanitised)],
    ).get();

    // Merge and deduplicate by entry id, keeping best rank.
    final Map<int, FtsSearchResult> merged = {};
    for (final row in [...entryResults, ...attachmentResults]) {
      final entryId = row.read<int>('entry_id');
      final rank = row.read<double>('rank');
      final existing = merged[entryId];
      if (existing == null || rank < existing.rank) {
        merged[entryId] = FtsSearchResult(
          entryId: entryId,
          journalId: row.read<int>('journal_id'),
          title: row.readNullable<String>('title'),
          snippet: row.read<String>('snippet'),
          rank: rank,
        );
      }
    }

    final results = merged.values.toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    return results;
  }

  // ────────────── Timeline queries ──────────────

  /// Returns entry counts grouped by date for a given month.
  Future<List<DateEntryCount>> getEntryCountsForMonth(
    int year,
    int month,
  ) async {
    // entry_date is stored as Unix seconds by drift's default DateTime
    // mapping, so feed it directly to unixepoch (no extra divide).
    final results = await customSelect(
      '''
      SELECT DATE(entry_date, 'unixepoch') AS day,
             COUNT(*) AS cnt
      FROM entries
      WHERE entry_date IS NOT NULL
        AND strftime('%Y', entry_date, 'unixepoch') = ?
        AND strftime('%m', entry_date, 'unixepoch') = ?
      GROUP BY day
      ''',
      variables: [
        Variable.withString(year.toString()),
        Variable.withString(month.toString().padLeft(2, '0')),
      ],
    ).get();

    return results.map((row) {
      final dayStr = row.read<String>('day');
      return DateEntryCount(
        date: DateTime.parse(dayStr),
        count: row.read<int>('cnt'),
      );
    }).toList();
  }

  /// Returns all entries for a specific date.
  Future<List<Entry>> getEntriesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(entries)
          ..where((t) =>
              t.entryDate.isBiggerOrEqualValue(startOfDay) &
              t.entryDate.isSmallerThanValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.asc(t.entryDate)]))
        .get();
  }

}
