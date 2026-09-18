part of 'backup_restore_service.dart';

extension _BackupRestoreServicePart1 on BackupRestoreService {
  /// Decides, row by row, what a merge would add.
  ///
  /// Matching is by content, never by id: the archive's ids are dropped on
  /// import, so an id can never point at the wrong row. Rows the app already
  /// holds are recorded in [_RestorePlan.existingIds], which also gives the
  /// insert step its old-to-new id map for free.
  Future<void> _planMerge(_ReadArchive archive, _RestorePlan plan) async {
    Future<void> planTable({
      required String table,
      required Future<Map<String, int>> Function() existingKeys,
      required String? Function(Map<String, dynamic> row) keyOf,
    }) async {
      final rows = archive.tables[table] ?? const [];
      if (rows.isEmpty) return;

      final existing = await existingKeys();
      var added = 0;
      var skipped = 0;

      for (final row in rows) {
        final oldId = BackupRestoreService._asInt(row['id']);
        final key = keyOf(row);
        final match = key == null ? null : existing[key];
        if (match != null) {
          skipped++;
          if (oldId != null) plan.mapExisting(table, oldId, match);
        } else {
          added++;
          if (oldId != null) plan.markForInsert(table, oldId);
        }
      }

      plan.outcomes[table] = RestoreTableOutcome(
        added: added,
        skipped: skipped,
      );
    }

    await planTable(
      table: 'journals',
      existingKeys: () async {
        final rows = await _db.select(_db.journals).get();
        return {
          for (final j in rows)
            '${j.title}|${j.createdAt.toIso8601String()}': j.id,
        };
      },
      keyOf: (row) => '${row['title']}|${row['createdAt']}',
    );

    await planTable(
      table: 'tags',
      existingKeys: () async {
        final rows = await _db.select(_db.tags).get();
        return {for (final t in rows) t.name.toLowerCase(): t.id};
      },
      keyOf: (row) => (row['name'] as String?)?.toLowerCase(),
    );

    await planTable(
      table: 'entries',
      existingKeys: () async {
        final rows = await _db.select(_db.entries).get();
        return {
          for (final e in rows)
            '${e.journalId}|${e.title}|${e.createdAt.toIso8601String()}': e.id,
        };
      },
      keyOf: (row) {
        final journalId = plan.mappedId(
          'journals',
          BackupRestoreService._asInt(row['journalId']),
        );
        if (journalId == null) return null; // new journal ⇒ new entry
        return '$journalId|${row['title']}|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'attachments',
      existingKeys: () async {
        final rows = await _db.select(_db.attachments).get();
        return {
          for (final a in rows)
            '${a.entryId}|${a.fileName}|${a.createdAt.toIso8601String()}': a.id,
        };
      },
      keyOf: (row) {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        return '$entryId|${row['fileName']}|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'voiceNotes',
      existingKeys: () async {
        final rows = await _db.select(_db.voiceNotes).get();
        return {
          for (final v in rows)
            '${v.entryId}|${v.fileName}|${v.createdAt.toIso8601String()}': v.id,
        };
      },
      keyOf: (row) {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        return '$entryId|${row['fileName']}|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'revisions',
      existingKeys: () async {
        final rows = await _db.select(_db.entryRevisions).get();
        return {
          for (final r in rows)
            '${r.entryId}|${r.createdAt.toIso8601String()}': r.id,
        };
      },
      keyOf: (row) {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        if (entryId == null) return null;
        return '$entryId|${row['createdAt']}';
      },
    );

    await planTable(
      table: 'entryMoods',
      existingKeys: () async {
        final rows = await _db.select(_db.entryMoods).get();
        return {for (final m in rows) '${m.entryId}': m.id};
      },
      keyOf: (row) {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        return entryId?.toString();
      },
    );

    await planTable(
      table: 'searchPresets',
      existingKeys: () async {
        final rows = await _db.select(_db.searchPresets).get();
        return {for (final s in rows) '${s.name}|${s.query}': s.id};
      },
      keyOf: (row) => '${row['name']}|${row['query']}',
    );

    await planTable(
      table: 'timeCapsules',
      existingKeys: () async {
        final rows = await _db.select(_db.timeCapsules).get();
        return {for (final tc in rows) '${tc.entryId}': tc.id};
      },
      keyOf: (row) {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        return entryId?.toString();
      },
    );

    await planTable(
      table: 'journalTags',
      existingKeys: () async {
        final rows = await _db.select(_db.journalTags).get();
        return {for (final jt in rows) '${jt.journalId}|${jt.tagId}': jt.id};
      },
      keyOf: (row) {
        final journalId = plan.mappedId(
          'journals',
          BackupRestoreService._asInt(row['journalId']),
        );
        final tagId = plan.mappedId(
          'tags',
          BackupRestoreService._asInt(row['tagId']),
        );
        if (journalId == null || tagId == null) return null;
        return '$journalId|$tagId';
      },
    );

    await planTable(
      table: 'entryTags',
      existingKeys: () async {
        final rows = await _db.select(_db.entryTags).get();
        return {for (final et in rows) '${et.entryId}|${et.tagId}': et.id};
      },
      keyOf: (row) {
        final entryId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['entryId']),
        );
        final tagId = plan.mappedId(
          'tags',
          BackupRestoreService._asInt(row['tagId']),
        );
        if (entryId == null || tagId == null) return null;
        return '$entryId|$tagId';
      },
    );

    await planTable(
      table: 'backlinks',
      existingKeys: () async {
        final rows = await _db.select(_db.backlinks).get();
        return {
          for (final b in rows)
            '${b.sourceEntryId}|${b.targetType}|${b.targetId}': b.id,
        };
      },
      keyOf: (row) {
        final sourceId = plan.mappedId(
          'entries',
          BackupRestoreService._asInt(row['sourceEntryId']),
        );
        final targetId = BackupRestoreService._mappedBacklinkTarget(plan, row);
        if (sourceId == null || targetId == null) return null;
        return '$sourceId|${row['targetType']}|$targetId';
      },
    );

    await planTable(
      table: 'syncMetadata',
      existingKeys: () async {
        final rows = await _db.select(_db.syncMetadata).get();
        return {for (final s in rows) '${s.recordTable}|${s.syncId}': s.id};
      },
      keyOf: (row) => '${row['recordTable']}|${row['syncId']}',
    );
  }

  Future<int> _countUserRows() async {
    var total = 0;
    total += (await _db.select(_db.journals).get()).length;
    total += (await _db.select(_db.entries).get()).length;
    total += (await _db.select(_db.tags).get()).length;
    total += (await _db.select(_db.journalTags).get()).length;
    total += (await _db.select(_db.entryTags).get()).length;
    total += (await _db.select(_db.attachments).get()).length;
    total += (await _db.select(_db.voiceNotes).get()).length;
    total += (await _db.select(_db.entryRevisions).get()).length;
    total += (await _db.select(_db.backlinks).get()).length;
    total += (await _db.select(_db.entryMoods).get()).length;
    total += (await _db.select(_db.searchPresets).get()).length;
    total += (await _db.select(_db.syncMetadata).get()).length;
    return total;
  }

  Future<List<String>> _currentPayloadPaths() async {
    final paths = <String>[];
    for (final a in await _db.select(_db.attachments).get()) {
      paths.add(a.encryptedPath);
    }
    for (final v in await _db.select(_db.voiceNotes).get()) {
      paths.add(v.encryptedPath);
    }
    return paths;
  }

  Future<void> _deleteFiles(List<String> paths) async {
    final fileCipher = cipher;
    if (fileCipher == null) return;
    for (final path in paths) {
      if (path.isEmpty) continue;
      try {
        await fileCipher.deleteStoredFile(path);
      } catch (_) {
        // A file we cannot delete is wasted space, not a failed restore.
      }
    }
  }

  /// Rebuilds the FTS index from the tables it mirrors.
  ///
  /// The triggers keep it in step row by row, but a restore inserts in bulk
  /// and a replace deletes in bulk, so rebuilding is both cheaper and safer
  /// than trusting every trigger fired.
  Future<void> _rebuildSearchIndex() async {
    try {
      await _db.customStatement(
        "INSERT INTO entries_fts(entries_fts) VALUES('rebuild')",
      );
      await _db.customStatement(
        "INSERT INTO attachment_text_fts(attachment_text_fts) VALUES('rebuild')",
      );
    } catch (e) {
      // Search being stale is not worth failing a restore over.
      AppLogger.warning('Search index rebuild after restore failed', error: e);
    }
  }

  Future<void> _assertIntegrity() async {
    final rows = await _db.customSelect('PRAGMA integrity_check').get();
    final status = rows.isEmpty ? null : rows.first.data.values.first;
    if (status != 'ok') {
      throw const BackupCorruptedException(backupIntegrityCheckFailedDetails);
    }
  }
}
