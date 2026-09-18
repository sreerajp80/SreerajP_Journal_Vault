part of 'app_database.dart';

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
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
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

@DriftAccessor(tables: [Tags, EntryTags, JournalTags])
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
    ])..where(entryTags.entryId.equals(entryId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(tags)).toList();
  }

  Future<void> addTagToEntry(int entryId, int tagId) => into(entryTags).insert(
    EntryTagsCompanion.insert(entryId: entryId, tagId: tagId),
    mode: InsertMode.insertOrIgnore,
  );

  Future<void> removeTagFromEntry(int entryId, int tagId) => (delete(
    entryTags,
  )..where((t) => t.entryId.equals(entryId) & t.tagId.equals(tagId))).go();

  Future<int> getOrCreateTag(String name) async {
    final trimmed = name.trim().toLowerCase();
    final existing = await (select(
      tags,
    )..where((t) => t.name.equals(trimmed))).getSingleOrNull();
    if (existing != null) return existing.id;
    return into(tags).insert(TagsCompanion.insert(name: trimmed));
  }

  /// Sets (or clears, with null) the display colour of a tag.
  Future<void> setTagColor(int id, int? colorArgb) => updateTagById(
    id,
    TagsCompanion(
      colorArgb: Value(colorArgb),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Renames a tag, using the same normalisation as [getOrCreateTag].
  ///
  /// Returns false without writing if the new name is empty, or if another tag
  /// already uses it — tag names are the identity users see, so duplicates are
  /// rejected rather than silently merged.
  Future<bool> renameTag(int id, String name) async {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) return false;

    final clash =
        await (select(tags)
              ..where((t) => t.name.equals(trimmed) & t.id.isNotValue(id)))
            .getSingleOrNull();
    if (clash != null) return false;

    await updateTagById(
      id,
      TagsCompanion(name: Value(trimmed), updatedAt: Value(DateTime.now())),
    );
    return true;
  }

  /// Deletes a tag along with its journal and entry links.
  ///
  /// Neither `journal_tags` nor `entry_tags` cascades from the tag side, so the
  /// link rows must be cleared explicitly or they are left pointing at a tag
  /// that no longer exists.
  Future<void> deleteTagWithLinks(int id) => transaction(() async {
    await (delete(journalTags)..where((t) => t.tagId.equals(id))).go();
    await (delete(entryTags)..where((t) => t.tagId.equals(id))).go();
    await deleteTagById(id);
  });
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

  Future<void> deleteForAttachment(int attachmentId) => (delete(
    attachmentTexts,
  )..where((t) => t.attachmentId.equals(attachmentId))).go();
}

@DriftAccessor(tables: [Backlinks])
class BacklinksDao extends DatabaseAccessor<AppDatabase>
    with _$BacklinksDaoMixin {
  BacklinksDao(super.db);

  Future<void> replaceBacklinksForEntry(
    int sourceEntryId,
    List<VaultBacklinkTarget> targets,
  ) async {
    await (delete(
      backlinks,
    )..where((t) => t.sourceEntryId.equals(sourceEntryId))).go();
    for (final target in targets) {
      await into(backlinks).insert(
        BacklinksCompanion.insert(
          sourceEntryId: sourceEntryId,
          targetType: target.type.name,
          targetId: target.targetId,
        ),
      );
    }
  }

  Stream<List<Backlink>> watchBacklinksForJournalTarget(int targetId) =>
      (select(backlinks)..where(
            (t) => t.targetType.equals('journal') & t.targetId.equals(targetId),
          ))
          .watch();

  Stream<List<Backlink>> watchBacklinksForEntryTarget(int targetId) =>
      (select(backlinks)..where(
            (t) => t.targetType.equals('entry') & t.targetId.equals(targetId),
          ))
          .watch();

  Future<List<Backlink>> getBacklinksForEntryTarget(int targetId) =>
      (select(backlinks)..where(
            (t) => t.targetType.equals('entry') & t.targetId.equals(targetId),
          ))
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
      (update(voiceNotes)..where((t) => t.id.equals(id))).write(
        VoiceNotesCompanion(transcript: Value(transcript)),
      );

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

  Future<List<BackupLog>> getAllLogs() => (select(
    backupLogs,
  )..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();

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
    final rows =
        await (select(backupLogs)..where(
              (t) =>
                  t.status.equals('failed') &
                  t.startedAt.isBiggerOrEqualValue(since),
            ))
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

  Future<List<SearchPreset>> getAllPresets() => select(searchPresets).get();

  Future<void> updatePresetById(int id, SearchPresetsCompanion companion) =>
      (update(searchPresets)..where((t) => t.id.equals(id))).write(companion);

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

  Future<void> updateAttachment(AttachmentsCompanion companion) => (update(
    attachments,
  )..where((t) => t.id.equals(companion.id.value))).write(companion);
}

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<AppSetting> getSettings() async {
    final rows = await select(appSettings).get();
    if (rows.isEmpty) {
      final id = await into(appSettings).insert(AppSettingsCompanion.insert());
      return (select(appSettings)..where((t) => t.id.equals(id))).getSingle();
    }
    return rows.first;
  }

  Future<void> updateSettings(AppSettingsCompanion companion) async {
    final settings = await getSettings();
    await (update(
      appSettings,
    )..where((t) => t.id.equals(settings.id))).write(companion);
  }
}

@DriftAccessor(tables: [AppSecurity])
class AppSecurityDao extends DatabaseAccessor<AppDatabase>
    with _$AppSecurityDaoMixin {
  AppSecurityDao(super.db);

  Future<AppSecurityData> getSecuritySettings() async {
    final rows = await select(appSecurity).get();
    if (rows.isEmpty) {
      final id = await into(appSecurity).insert(AppSecurityCompanion.insert());
      return (select(appSecurity)..where((t) => t.id.equals(id))).getSingle();
    }
    return rows.first;
  }

  Future<void> updateLockState(AppSecurityCompanion companion) async {
    final settings = await getSecuritySettings();
    await (update(
      appSecurity,
    )..where((t) => t.id.equals(settings.id))).write(companion);
  }
}

@DriftAccessor(tables: [JournalTags, Tags])
class JournalTagsDao extends DatabaseAccessor<AppDatabase>
    with _$JournalTagsDaoMixin {
  JournalTagsDao(super.db);

  Future<List<Tag>> getTagsForJournal(int journalId) async {
    final query = select(tags).join([
      innerJoin(journalTags, journalTags.tagId.equalsExp(tags.id)),
    ])..where(journalTags.journalId.equals(journalId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(tags)).toList();
  }

  Future<void> addTagToJournal(int journalId, int tagId) => into(
    journalTags,
  ).insert(JournalTagsCompanion.insert(journalId: journalId, tagId: tagId));

  Future<void> removeTagFromJournal(int journalId, int tagId) => (delete(
    journalTags,
  )..where((t) => t.journalId.equals(journalId) & t.tagId.equals(tagId))).go();
}
