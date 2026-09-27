import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Migration tests for the v1 -> v8 upgrade path.
///
/// The engineering standard names this a critical test area: a migration bug
/// destroys journal entries with no recovery path.
///
/// WHAT THIS TEST DOES AND DOES NOT PROVE
///
/// This project has no `drift_schemas/` snapshots, so drift's schema-verifier
/// (which replays the *real* historical DDL) cannot be used, and the snapshots
/// cannot be reconstructed after the fact. Instead each test builds the current
/// schema, strips exactly what a later version added, rewinds `user_version`,
/// and reopens the database so the real `onUpgrade` code runs.
///
/// That proves: every onUpgrade branch executes without error, recreates the
/// tables and columns it is supposed to, and does not destroy existing rows.
///
/// That does NOT prove: the historical v1..v7 table definitions were shaped
/// exactly like the stripped-down ones used here. If an old column differed
/// from today's, this test would not catch it.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vault_migration_test');
    dbFile = File('${tempDir.path}/vault.sqlite');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  AppDatabase openDb() => AppDatabase.forExecutor(NativeDatabase(dbFile));

  /// Tables introduced after v1, newest first, with the version that added them.
  const addedAfterV1 = <int, List<String>>{
    2: ['entry_tags', 'attachment_texts'],
    3: ['entry_revisions', 'voice_notes'],
    4: ['backup_logs'],
    5: ['sync_metadata', 'sync_conflicts', 'sync_logs'],
    6: [
      'auto_lock_profiles',
      'attachment_locks',
      'security_events',
      'entry_moods',
    ],
    9: ['user_templates'],
    10: ['time_capsules'],
    11: ['user_ritual_cards'],
  };

  const v7Columns = [
    'attachment_storage_tree_label',
    'attachment_migration_target',
    'attachment_migration_failure',
    'updated_at',
  ];

  const v8Columns = ['color_argb'];

  const ftsObjects = ['entries_fts', 'attachment_text_fts'];

  /// The Wi-Fi Sync change triggers added in v12.
  final syncTriggers = [
    for (final table in syncTrackedTables) ...[
      'sync_${table}_au',
      'sync_${table}_ad',
    ],
  ];

  Future<bool> tableExists(AppDatabase db, String name) async {
    final rows = await db
        .customSelect(
          'SELECT name FROM sqlite_master WHERE name = ?',
          variables: [Variable<String>(name)],
        )
        .get();
    return rows.isNotEmpty;
  }

  Future<Set<String>> columnsOf(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  /// Rewinds a freshly created v8 database to look like [version].
  Future<void> rewindTo(int version) async {
    final db = openDb();

    // Force onCreate to run, giving us the full current schema.
    await db.customSelect('SELECT 1').get();

    // Drop everything introduced after the target version.
    for (final entry in addedAfterV1.entries) {
      if (entry.key > version) {
        for (final table in entry.value) {
          await db.customStatement('DROP TABLE IF EXISTS $table');
        }
      }
    }

    if (version < 2) {
      // FTS virtual tables and their triggers arrived with v2.
      for (final trigger in [
        'entries_ai',
        'entries_ad',
        'entries_au',
        'att_text_ai',
        'att_text_ad',
        'att_text_au',
      ]) {
        await db.customStatement('DROP TRIGGER IF EXISTS $trigger');
      }
      for (final table in ftsObjects) {
        await db.customStatement('DROP TABLE IF EXISTS $table');
      }
    }

    if (version < 12) {
      for (final trigger in syncTriggers) {
        await db.customStatement('DROP TRIGGER IF EXISTS $trigger');
      }
    }

    if (version < 7) {
      for (final column in v7Columns) {
        await db.customStatement(
          'ALTER TABLE app_settings DROP COLUMN $column',
        );
      }
    }

    if (version < 8) {
      for (final column in v8Columns) {
        await db.customStatement('ALTER TABLE tags DROP COLUMN $column');
      }
    }

    // Self-check, done here while the connection is already open. Reopening to
    // inspect would run onUpgrade and recreate everything before we could look.
    //
    // Without this, every test below could pass vacuously: if the drops above
    // silently did nothing, the tables would still be present after the
    // "upgrade" and the assertions would prove nothing at all.
    final remaining =
        (await db.customSelect('SELECT name FROM sqlite_master').get())
            .map((r) => r.read<String>('name'))
            .toSet();

    for (final entry in addedAfterV1.entries) {
      if (entry.key > version) {
        for (final table in entry.value) {
          expect(
            remaining,
            isNot(contains(table)),
            reason:
                'rewindTo($version) failed to drop $table, so any '
                'assertion about it being recreated would be meaningless',
          );
        }
      }
    }

    if (version < 12) {
      for (final trigger in syncTriggers) {
        expect(
          remaining,
          isNot(contains(trigger)),
          reason: 'rewindTo($version) failed to drop trigger $trigger',
        );
      }
    }

    if (version < 7) {
      final columns = await columnsOf(db, 'app_settings');
      for (final column in v7Columns) {
        expect(
          columns,
          isNot(contains(column)),
          reason: 'rewindTo($version) failed to drop app_settings.$column',
        );
      }
    }

    if (version < 8) {
      final columns = await columnsOf(db, 'tags');
      for (final column in v8Columns) {
        expect(
          columns,
          isNot(contains(column)),
          reason: 'rewindTo($version) failed to drop tags.$column',
        );
      }
    }

    await db.customStatement('PRAGMA user_version = $version');
    await db.close();
  }

  group('schema upgrade', () {
    test('v1 -> v8 creates every table added along the way', () async {
      await rewindTo(1);

      final db = openDb();

      for (final entry in addedAfterV1.entries) {
        for (final table in entry.value) {
          expect(
            await tableExists(db, table),
            isTrue,
            reason: '$table (added in v${entry.key}) is missing after upgrade',
          );
        }
      }

      for (final fts in ftsObjects) {
        expect(
          await tableExists(db, fts),
          isTrue,
          reason: '$fts is missing after upgrade',
        );
      }

      await db.close();
    });

    test('v1 -> v8 adds the v7 app_settings columns', () async {
      await rewindTo(1);

      final db = openDb();
      final columns = await columnsOf(db, 'app_settings');

      for (final column in v7Columns) {
        expect(columns, contains(column));
      }

      await db.close();
    });

    test('v6 -> v7 adds only the v7 columns', () async {
      await rewindTo(6);

      final db = openDb();
      final columns = await columnsOf(db, 'app_settings');

      for (final column in v7Columns) {
        expect(columns, contains(column));
      }

      await db.close();
    });

    test('v1 -> v8 adds tags.color_argb', () async {
      await rewindTo(1);

      final db = openDb();
      final columns = await columnsOf(db, 'tags');

      for (final column in v8Columns) {
        expect(columns, contains(column));
      }

      await db.close();
    });

    test('v7 -> v8 adds only the v8 columns', () async {
      await rewindTo(7);

      final db = openDb();
      final columns = await columnsOf(db, 'tags');

      for (final column in v8Columns) {
        expect(columns, contains(column));
      }

      await db.close();
    });

    test('v8 -> v9 creates user_templates table', () async {
      await rewindTo(8);

      final db = openDb();
      expect(await tableExists(db, 'user_templates'), isTrue);

      await db.close();
    });

    test('v10 -> v11 creates user_ritual_cards table', () async {
      await rewindTo(10);

      final db = openDb();
      expect(await tableExists(db, 'user_ritual_cards'), isTrue);

      await db.close();
    });

    test('v11 -> v12 creates the sync change triggers', () async {
      await rewindTo(11);

      final db = openDb();
      for (final trigger in syncTriggers) {
        expect(await tableExists(db, trigger), isTrue, reason: trigger);
      }

      await db.close();
    });

    test('reports schema version 12 after upgrading', () async {
      await rewindTo(1);

      final db = openDb();
      final rows = await db.customSelect('PRAGMA user_version').get();

      expect(rows.single.read<int>('user_version'), 12);

      await db.close();
    });
  });

  group('data survival', () {
    test('journal and entry rows survive a v1 -> v8 upgrade', () async {
      // Write data while the database looks like v1.
      final seed = openDb();
      await seed.customSelect('SELECT 1').get();
      final journalId = await seed.journalsDao.createJournal(
        JournalsCompanion.insert(
          title: 'Pre-migration journal',
          description: const Value('Written before the upgrade'),
        ),
      );
      await seed.close();

      await rewindTo(1);

      final db = openDb();
      final journals = await db.journalsDao.getAllJournals();

      expect(journals, hasLength(1));
      expect(journals.single.id, journalId);
      expect(journals.single.title, 'Pre-migration journal');
      expect(journals.single.description, 'Written before the upgrade');

      await db.close();
    });

    test('tags written before v8 survive and start with no colour', () async {
      final seed = openDb();
      await seed.customSelect('SELECT 1').get();
      final tagId = await seed.tagsDao.getOrCreateTag('Pre-migration');
      await seed.close();

      await rewindTo(7);

      final db = openDb();
      final tags = await db.tagsDao.getAllTags();

      expect(tags, hasLength(1));
      expect(tags.single.id, tagId);
      expect(tags.single.name, 'pre-migration');
      expect(tags.single.colorArgb, isNull);

      // The new column must be writable straight after the upgrade.
      await db.tagsDao.setTagColor(tagId, 0xFF4A7FD4);
      final updated = await db.tagsDao.getAllTags();
      expect(updated.single.colorArgb, 0xFF4A7FD4);

      await db.close();
    });

    test('the upgraded database still accepts writes', () async {
      await rewindTo(1);

      final db = openDb();
      final id = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Post-migration journal'),
      );

      final journals = await db.journalsDao.getAllJournals();
      expect(journals.map((j) => j.id), contains(id));

      await db.close();
    });

    test('foreign keys are still enforced after the upgrade', () async {
      await rewindTo(1);

      final db = openDb();

      // beforeOpen sets PRAGMA foreign_keys = ON; an entry pointing at a
      // journal that does not exist must be rejected.
      await expectLater(
        db.entriesDao.createEntry(
          EntriesCompanion.insert(journalId: 999999, title: const Value('x')),
        ),
        throwsA(anything),
      );

      await db.close();
    });
  });

  group('sync change triggers', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    /// Gives [localId] of [table] synced metadata, as after a sync.
    Future<void> synced(String table, int localId) async {
      await db.syncMetadataDao.upsert(
        SyncMetadataCompanion.insert(
          recordTable: table,
          localId: localId,
          syncId: '$table-$localId',
          deviceId: 'this-phone',
          lastSyncedAt: Value(DateTime(2026, 9, 27)),
        ),
      );
    }

    Future<SyncMetadataData> meta(String table, int localId) async =>
        (await db.syncMetadataDao.getByRecord(table, localId))!;

    test('an update marks the record pending with a new version', () async {
      final j = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Old'),
      );
      await synced('journals', j);

      await db.journalsDao.updateJournalById(
        j,
        const JournalsCompanion(title: Value('New')),
      );

      final m = await meta('journals', j);
      expect(m.lastSyncedAt, isNull);
      expect(m.version, 2);
      expect(m.isDeleted, isFalse);
    });

    test('a delete leaves a tombstone, cascades included', () async {
      final j = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'J'),
      );
      final e = await db.entriesDao.createEntry(
        EntriesCompanion.insert(journalId: j),
      );
      final tag = await db.tagsDao.getOrCreateTag('t');
      await db.tagsDao.addTagToEntry(e, tag);
      final link = (await db.select(db.entryTags).get()).single.id;
      await synced('entries', e);
      await synced('entry_tags', link);

      await db.entriesDao.deleteEntryById(e);

      for (final (table, id) in [('entries', e), ('entry_tags', link)]) {
        final m = await meta(table, id);
        expect(m.isDeleted, isTrue, reason: table);
        expect(m.lastSyncedAt, isNull, reason: table);
      }
    });

    test('moving an attachment file does not mark it', () async {
      final j = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'J'),
      );
      final e = await db.entriesDao.createEntry(
        EntriesCompanion.insert(journalId: j),
      );
      final a = await db.attachmentsDao.createAttachment(
        AttachmentsCompanion.insert(
          entryId: e,
          fileName: 'photo.png',
          encryptedPath: 'app_private/a.bin',
          nonceBase64: 'n',
          keyReference: 'k',
          sizeBytes: 3,
        ),
      );
      await synced('attachments', a);

      await db.customStatement(
        "UPDATE attachments SET encrypted_path = 'sd_card/a.bin' WHERE id = $a",
      );
      expect((await meta('attachments', a)).lastSyncedAt, isNotNull);

      await db.customStatement(
        "UPDATE attachments SET file_name = 'renamed.png' WHERE id = $a",
      );
      expect((await meta('attachments', a)).lastSyncedAt, isNull);
    });

    test('a row that was never synced is left alone', () async {
      final j = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'J'),
      );
      await db.journalsDao.updateJournalById(
        j,
        const JournalsCompanion(title: Value('K')),
      );
      expect(await db.syncMetadataDao.getByRecord('journals', j), isNull);
    });
  });
}
