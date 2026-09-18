part of 'backup_restore_service.dart';

extension _BackupRestoreServicePart4 on BackupRestoreService {
  // ───────────────────────── writing rows ─────────────────────────

  /// Inserts every planned row inside the caller's transaction, dropping the
  /// archive's primary keys and rewriting foreign keys as it goes.
  Future<void> _insertRows(
    _ReadArchive archive,
    _RestorePlan plan,
    _RestoredFiles files,
  ) async {
    Future<void> insertTable({
      required String table,
      required Future<int?> Function(Map<String, dynamic> row) insert,
    }) async {
      for (final row in archive.tables[table] ?? const []) {
        final oldId = BackupRestoreService._asInt(row['id']);
        if (oldId != null && !plan.willInsert(table, oldId)) continue;
        final newId = await insert(row);
        if (oldId != null && newId != null) {
          plan.mapExisting(table, oldId, newId);
        }
      }
    }

    await insertTable(
      table: 'journals',
      insert: (row) => _db
          .into(_db.journals)
          .insert(
            JournalsCompanion.insert(
              title: (row['title'] as String?) ?? '',
              description: Value(row['description'] as String?),
              isLocked: Value((row['isLocked'] as bool?) ?? false),
              credentialReference: Value(row['credentialReference'] as String?),
              passwordSaltBase64: Value(row['passwordSaltBase64'] as String?),
              passwordVerifierBase64: Value(
                row['passwordVerifierBase64'] as String?,
              ),
              passwordIterations: Value(
                BackupRestoreService._asInt(row['passwordIterations']),
              ),
              createdAt: BackupRestoreService._dateValue(row['createdAt']),
              updatedAt: BackupRestoreService._dateValue(row['updatedAt']),
            ),
          ),
    );

    await insertTable(
      table: 'tags',
      insert: (row) => _db
          .into(_db.tags)
          .insert(
            TagsCompanion.insert(
              name: (row['name'] as String?) ?? '',
              colorArgb: Value(BackupRestoreService._asInt(row['colorArgb'])),
              createdAt: BackupRestoreService._dateValue(row['createdAt']),
              updatedAt: BackupRestoreService._dateValue(row['updatedAt']),
            ),
          ),
    );

    await insertTable(
      table: 'entries',
      insert: (row) async {
        final journalId = plan.mappedId(
          'journals',
          BackupRestoreService._asInt(row['journalId']),
        );
        if (journalId == null) return null;
        return _db
            .into(_db.entries)
            .insert(
              EntriesCompanion.insert(
                journalId: journalId,
                title: Value(row['title'] as String?),
                contentJson: Value(row['contentJson'] as String?),
                plainText: Value(row['plainText'] as String?),
                entryDate: BackupRestoreService._nullableDateValue(
                  row['entryDate'],
                ),
                createdAt: BackupRestoreService._dateValue(row['createdAt']),
                updatedAt: BackupRestoreService._dateValue(row['updatedAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'journalTags',
      insert: (row) async {
        final journalId = plan.mappedId(
          'journals',
          BackupRestoreService._asInt(row['journalId']),
        );
        final tagId = plan.mappedId(
          'tags',
          BackupRestoreService._asInt(row['tagId']),
        );
        if (journalId == null || tagId == null) return null;
        return _db
            .into(_db.journalTags)
            .insert(
              JournalTagsCompanion.insert(journalId: journalId, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );

    await insertTable(
      table: 'entryTags',
      insert: (row) async {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        final tagId = plan.mappedId(
          'tags',
          BackupRestoreService._asInt(row['tagId']),
        );
        if (entryId == null || tagId == null) return null;
        return _db
            .into(_db.entryTags)
            .insert(
              EntryTagsCompanion.insert(entryId: entryId, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );

    await insertTable(
      table: 'attachments',
      insert: (row) async {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        final oldId = BackupRestoreService._asInt(row['id']);
        final stored = files.stored['attachments:$oldId'];
        return _db
            .into(_db.attachments)
            .insert(
              AttachmentsCompanion.insert(
                entryId: entryId,
                fileName: (row['fileName'] as String?) ?? 'file',
                mimeType: Value(row['mimeType'] as String?),
                // Without the file, the row still restores: the entry keeps its
                // record of the attachment even though the bytes are gone.
                encryptedPath:
                    stored?.encryptedPath ??
                    (row['encryptedPath'] as String? ?? ''),
                nonceBase64:
                    stored?.nonceBase64 ??
                    (row['nonceBase64'] as String? ?? ''),
                keyReference:
                    stored?.keyReference ??
                    (row['keyReference'] as String? ?? ''),
                sizeBytes:
                    stored?.sizeBytes ??
                    (BackupRestoreService._asInt(row['sizeBytes']) ?? 0),
                createdAt: BackupRestoreService._dateValue(row['createdAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'voiceNotes',
      insert: (row) async {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        final oldId = BackupRestoreService._asInt(row['id']);
        final stored = files.stored['voiceNotes:$oldId'];
        return _db
            .into(_db.voiceNotes)
            .insert(
              VoiceNotesCompanion.insert(
                entryId: entryId,
                fileName: (row['fileName'] as String?) ?? 'voice_note',
                encryptedPath:
                    stored?.encryptedPath ??
                    (row['encryptedPath'] as String? ?? ''),
                nonceBase64:
                    stored?.nonceBase64 ??
                    (row['nonceBase64'] as String? ?? ''),
                keyReference:
                    stored?.keyReference ??
                    (row['keyReference'] as String? ?? ''),
                durationMs: BackupRestoreService._asInt(row['durationMs']) ?? 0,
                transcript: Value(row['transcript'] as String?),
                createdAt: BackupRestoreService._dateValue(row['createdAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'revisions',
      insert: (row) async {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        return _db
            .into(_db.entryRevisions)
            .insert(
              EntryRevisionsCompanion.insert(
                entryId: entryId,
                title: Value(row['title'] as String?),
                contentJson: Value(row['contentJson'] as String?),
                plainText: Value(row['plainText'] as String?),
                createdAt: BackupRestoreService._dateValue(row['createdAt']),
              ),
            );
      },
    );

    await insertTable(
      table: 'backlinks',
      insert: (row) async {
        final sourceId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['sourceEntryId']),
        );
        final targetId = BackupRestoreService._mappedBacklinkTarget(plan, row);
        if (sourceId == null || targetId == null) return null;
        return _db
            .into(_db.backlinks)
            .insert(
              BacklinksCompanion.insert(
                sourceEntryId: sourceId,
                targetType: (row['targetType'] as String?) ?? 'entry',
                targetId: targetId,
              ),
            );
      },
    );

    await insertTable(
      table: 'entryMoods',
      insert: (row) async {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        return _db
            .into(_db.entryMoods)
            .insert(
              EntryMoodsCompanion.insert(
                entryId: entryId,
                mood: BackupRestoreService._asInt(row['mood']) ?? 3,
                note: Value(row['note'] as String?),
                createdAt: BackupRestoreService._dateValue(row['createdAt']),
                updatedAt: BackupRestoreService._dateValue(row['updatedAt']),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );

    await insertTable(
      table: 'searchPresets',
      insert: (row) => _db
          .into(_db.searchPresets)
          .insert(
            SearchPresetsCompanion.insert(
              name: (row['name'] as String?) ?? '',
              query: (row['query'] as String?) ?? '',
              resultType: Value(row['resultType'] as String?),
              createdAt: BackupRestoreService._dateValue(row['createdAt']),
              updatedAt: BackupRestoreService._dateValue(row['updatedAt']),
            ),
          ),
    );

    await insertTable(
      table: 'syncMetadata',
      insert: (row) async {
        final recordTable = (row['recordTable'] as String?) ?? '';
        final localId = plan.mappedId(
          recordTable,
          BackupRestoreService._asInt(row['localId']),
        );
        if (localId == null) return null;
        return _db
            .into(_db.syncMetadata)
            .insert(
              SyncMetadataCompanion.insert(
                recordTable: recordTable,
                localId: localId,
                syncId: (row['syncId'] as String?) ?? '',
                version: Value(
                  BackupRestoreService._asInt(row['version']) ?? 1,
                ),
                deviceId: (row['deviceId'] as String?) ?? '',
                isDeleted: Value((row['isDeleted'] as bool?) ?? false),
                lastSyncedAt: BackupRestoreService._nullableDateValue(
                  row['lastSyncedAt'],
                ),
                lastModifiedAt: BackupRestoreService._dateValue(
                  row['lastModifiedAt'],
                ),
              ),
            );
      },
    );

    await insertTable(
      table: 'timeCapsules',
      insert: (row) async {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        return _db
            .into(_db.timeCapsules)
            .insert(
              TimeCapsulesCompanion.insert(
                entryId: entryId,
                unlockDate: BackupRestoreService._dateValue(
                  row['unlockDate'],
                ).value,
                sealedAt: BackupRestoreService._dateValue(row['sealedAt']),
                isOpened: Value((row['isOpened'] as bool?) ?? false),
                openedAt: BackupRestoreService._nullableDateValue(
                  row['openedAt'],
                ),
                sealedCiphertext: (row['sealedCiphertext'] as String?) ?? '',
                ivBase64: (row['ivBase64'] as String?) ?? '',
                macBase64: (row['macBase64'] as String?) ?? '',
                sealedKeyCiphertext: Value(
                  row['sealedKeyCiphertext'] as String?,
                ),
                teaserMessage: Value(row['teaserMessage'] as String?),
                createdAt: BackupRestoreService._dateValue(row['createdAt']),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      },
    );
  }

  // ───────────────────────── database helpers ─────────────────────────

  /// Deletes user data in an order that respects foreign keys.
  Future<void> _clearUserData() async {
    await _db.delete(_db.syncMetadata).go();
    await _db.delete(_db.timeCapsules).go();
    await _db.delete(_db.entryMoods).go();
    await _db.delete(_db.backlinks).go();
    await _db.delete(_db.entryRevisions).go();
    await _db.delete(_db.voiceNotes).go();
    await _db.delete(_db.attachmentTexts).go();
    await _db.delete(_db.attachments).go();
    await _db.delete(_db.entryTags).go();
    await _db.delete(_db.journalTags).go();
    await _db.delete(_db.entries).go();
    await _db.delete(_db.tags).go();
    await _db.delete(_db.journals).go();
    await _db.delete(_db.searchPresets).go();
  }
}
