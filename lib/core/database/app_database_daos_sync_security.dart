part of 'app_database.dart';

@DriftAccessor(tables: [SyncMetadata])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetadataDaoMixin {
  SyncMetadataDao(super.db);

  Future<int> upsert(SyncMetadataCompanion companion) =>
      into(syncMetadata).insert(companion, mode: InsertMode.insertOrReplace);

  Future<SyncMetadataData?> getBySyncId(String syncId) => (select(
    syncMetadata,
  )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();

  Future<SyncMetadataData?> getByRecord(String table, int localId) =>
      (select(syncMetadata)..where(
            (t) => t.recordTable.equals(table) & t.localId.equals(localId),
          ))
          .getSingleOrNull();

  Future<List<SyncMetadataData>> getUnsyncedRecords() =>
      (select(syncMetadata)
            ..where(
              (t) =>
                  t.lastSyncedAt.isNull() |
                  t.lastModifiedAt.isBiggerThan(t.lastSyncedAt),
            )
            ..where((t) => t.isDeleted.equals(false)))
          .get();

  Future<List<SyncMetadataData>> getModifiedSince(DateTime since) => (select(
    syncMetadata,
  )..where((t) => t.lastModifiedAt.isBiggerOrEqualValue(since))).get();

  Future<void> markSynced(String syncId, DateTime syncedAt) =>
      (update(syncMetadata)..where((t) => t.syncId.equals(syncId))).write(
        SyncMetadataCompanion(lastSyncedAt: Value(syncedAt)),
      );

  Future<void> markDeleted(String syncId) =>
      (update(syncMetadata)..where((t) => t.syncId.equals(syncId))).write(
        const SyncMetadataCompanion(isDeleted: Value(true)),
      );

  Future<void> incrementVersion(String syncId) async {
    final record = await getBySyncId(syncId);
    if (record == null) return;
    await (update(syncMetadata)..where((t) => t.syncId.equals(syncId))).write(
      SyncMetadataCompanion(
        version: Value(record.version + 1),
        lastModifiedAt: Value(DateTime.now()),
      ),
    );
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
        const SyncConflictsCompanion(status: Value('dismissed')),
      );

  Future<List<SyncConflict>> getAllConflicts() => (select(
    syncConflicts,
  )..orderBy([(t) => OrderingTerm.desc(t.detectedAt)])).get();

  Future<void> deleteOldResolved({int keepCount = 100}) async {
    final resolved =
        await (select(syncConflicts)
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
    final rows =
        await (select(syncLogs)..where(
              (t) =>
                  t.status.equals('failed') &
                  t.startedAt.isBiggerOrEqualValue(since),
            ))
            .get();
    return rows.length;
  }

  Future<void> deleteOldLogs({int keepCount = 50}) async {
    final all = await (select(
      syncLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();
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

  Future<List<AutoLockProfile>> getAllProfiles() => (select(
    autoLockProfiles,
  )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<AutoLockProfile?> getActiveProfile() =>
      (select(autoLockProfiles)
            ..where((t) => t.isActive.equals(true))
            ..limit(1))
          .getSingleOrNull();

  Future<void> activateProfile(int id) async {
    // Deactivate all first
    await update(
      autoLockProfiles,
    ).write(const AutoLockProfilesCompanion(isActive: Value(false)));
    // Activate the selected one
    await (update(autoLockProfiles)..where((t) => t.id.equals(id))).write(
      AutoLockProfilesCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deactivateAll() => update(
    autoLockProfiles,
  ).write(const AutoLockProfilesCompanion(isActive: Value(false)));

  Future<void> updateProfile(int id, AutoLockProfilesCompanion companion) =>
      (update(
        autoLockProfiles,
      )..where((t) => t.id.equals(id))).write(companion);

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
      into(attachmentLocks).insert(companion, mode: InsertMode.insertOrReplace);

  Future<AttachmentLock?> getLockForAttachment(int attachmentId) => (select(
    attachmentLocks,
  )..where((t) => t.attachmentId.equals(attachmentId))).getSingleOrNull();

  Future<bool> isAttachmentLocked(int attachmentId) async {
    final lock = await getLockForAttachment(attachmentId);
    return lock?.isLocked ?? false;
  }

  Future<void> unlockAttachment(int attachmentId) =>
      (update(
        attachmentLocks,
      )..where((t) => t.attachmentId.equals(attachmentId))).write(
        AttachmentLocksCompanion(
          isLocked: const Value(false),
          unlockedAt: Value(DateTime.now()),
        ),
      );

  Future<void> relockAttachment(int attachmentId) =>
      (update(attachmentLocks)
            ..where((t) => t.attachmentId.equals(attachmentId)))
          .write(const AttachmentLocksCompanion(isLocked: Value(true)));

  Future<void> removeLock(int attachmentId) => (delete(
    attachmentLocks,
  )..where((t) => t.attachmentId.equals(attachmentId))).go();

  Future<List<AttachmentLock>> getLockedAttachments() =>
      (select(attachmentLocks)..where((t) => t.isLocked.equals(true))).get();
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

  Future<List<SecurityEvent>> getEventsByType(
    String eventType, {
    int limit = 20,
  }) =>
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

  Stream<List<SecurityEvent>> watchEventsByType(
    String eventType, {
    int limit = 50,
  }) =>
      (select(securityEvents)
            ..where((t) => t.eventType.equals(eventType))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .watch();

  Future<int> getEventCountSince(DateTime since) async {
    final rows = await (select(
      securityEvents,
    )..where((t) => t.createdAt.isBiggerOrEqualValue(since))).get();
    return rows.length;
  }

  Future<void> deleteOldEvents({int keepCount = 500}) async {
    final all = await (select(
      securityEvents,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
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
      into(entryMoods).insert(companion, mode: InsertMode.insertOrReplace);

  Future<EntryMood?> getMoodForEntry(int entryId) => (select(
    entryMoods,
  )..where((t) => t.entryId.equals(entryId))).getSingleOrNull();

  Future<List<EntryMood>> getAllMoods() => (select(
    entryMoods,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<void> deleteMoodForEntry(int entryId) =>
      (delete(entryMoods)..where((t) => t.entryId.equals(entryId))).go();

  Stream<EntryMood?> watchMoodForEntry(int entryId) => (select(
    entryMoods,
  )..where((t) => t.entryId.equals(entryId))).watchSingleOrNull();
}

@DriftAccessor(tables: [UserTemplates])
class UserTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$UserTemplatesDaoMixin {
  UserTemplatesDao(super.db);

  Future<int> createUserTemplate(UserTemplatesCompanion companion) =>
      into(userTemplates).insert(companion);

  Future<List<UserTemplate>> getAllUserTemplates() =>
      (select(userTemplates)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<UserTemplate>> watchAllUserTemplates() => (select(
    userTemplates,
  )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<UserTemplate?> getUserTemplateById(int id) =>
      (select(userTemplates)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> updateUserTemplate(UserTemplate template) =>
      update(userTemplates).replace(template);

  Future<void> updateUserTemplateCompanion(
    int id,
    UserTemplatesCompanion companion,
  ) => (update(userTemplates)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteUserTemplate(int id) =>
      (delete(userTemplates)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [UserRitualCards])
class UserRitualCardsDao extends DatabaseAccessor<AppDatabase>
    with _$UserRitualCardsDaoMixin {
  UserRitualCardsDao(super.db);

  Future<int> createCard(UserRitualCardsCompanion companion) =>
      into(userRitualCards).insert(companion);

  Future<List<UserRitualCard>> getAllCards() => (select(
    userRitualCards,
  )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Stream<List<UserRitualCard>> watchAllCards() => (select(
    userRitualCards,
  )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();

  Future<UserRitualCard?> getCardById(int id) => (select(
    userRitualCards,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> updateCard(int id, UserRitualCardsCompanion companion) =>
      (update(userRitualCards)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteCard(int id) =>
      (delete(userRitualCards)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [TimeCapsules])
class TimeCapsulesDao extends DatabaseAccessor<AppDatabase>
    with _$TimeCapsulesDaoMixin {
  TimeCapsulesDao(super.db);

  Future<int> createCapsule(TimeCapsulesCompanion companion) =>
      into(timeCapsules).insert(companion);

  Future<TimeCapsule?> getCapsuleForEntry(int entryId) => (select(
    timeCapsules,
  )..where((t) => t.entryId.equals(entryId))).getSingleOrNull();

  Stream<TimeCapsule?> watchCapsuleForEntry(int entryId) => (select(
    timeCapsules,
  )..where((t) => t.entryId.equals(entryId))).watchSingleOrNull();

  Future<List<TimeCapsule>> getAllCapsules() => (select(
    timeCapsules,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Stream<List<TimeCapsule>> watchAllCapsules() => (select(
    timeCapsules,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<List<TimeCapsule>> getUnopenedCapsules() =>
      (select(timeCapsules)..where((t) => t.isOpened.equals(false))).get();

  Future<List<TimeCapsule>> getReadyToOpenCapsules(DateTime now) =>
      (select(timeCapsules)..where(
            (t) =>
                t.isOpened.equals(false) &
                t.unlockDate.isSmallerOrEqualValue(now),
          ))
          .get();

  Future<void> updateCapsule(int id, TimeCapsulesCompanion companion) =>
      (update(timeCapsules)..where((t) => t.id.equals(id))).write(companion);

  Future<void> markOpened(int id, DateTime openedAt) =>
      (update(timeCapsules)..where((t) => t.id.equals(id))).write(
        TimeCapsulesCompanion(
          isOpened: const Value(true),
          openedAt: Value(openedAt),
        ),
      );

  Future<void> deleteCapsuleForEntry(int entryId) =>
      (delete(timeCapsules)..where((t) => t.entryId.equals(entryId))).go();
}

// ──────────────────────────── Database ────────────────────────────

// ──────────────────────────── FTS5 helpers ────────────────────────────
