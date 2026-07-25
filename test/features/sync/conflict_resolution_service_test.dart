import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/services/conflict_resolution_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late ConflictResolutionService service;

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    service = ConflictResolutionService(
      db: database,
      encryption: SyncEncryptionService(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<({int journalId, String syncId, int conflictId})> seedConflict({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: local['title'] as String? ?? 'Local'),
    );
    const syncId = 'sync-test-id';
    await database.syncMetadataDao.upsert(
      SyncMetadataCompanion.insert(
        recordTable: 'journals',
        localId: journalId,
        syncId: syncId,
        deviceId: 'device-A',
      ),
    );
    final conflictId = await database.syncConflictsDao.createConflict(
      SyncConflictsCompanion.insert(
        syncId: syncId,
        recordTable: 'journals',
        localVersion: 1,
        remoteVersion: 2,
        localDataJson: jsonEncode(local),
        remoteDataJson: jsonEncode(remote),
      ),
    );
    return (journalId: journalId, syncId: syncId, conflictId: conflictId);
  }

  test('keep_local marks the conflict resolved and bumps the local version',
      () async {
    final seeded = await seedConflict(
      local: {'title': 'Local'},
      remote: {'title': 'Remote'},
    );

    expect(
      (await database.syncConflictsDao.getPendingConflicts()),
      hasLength(1),
    );

    await service.resolveConflict(
      conflictId: seeded.conflictId,
      resolution: ConflictResolution.keepLocal,
    );

    expect(
      await database.syncConflictsDao.getPendingConflicts(),
      isEmpty,
    );
    final updated =
        await database.syncConflictsDao.getConflictById(seeded.conflictId);
    expect(updated.status, 'resolved');

    // Local journal title is unchanged.
    final journal =
        await database.journalsDao.getJournalById(seeded.journalId);
    expect(journal.title, 'Local');

    // Sync metadata version bumped.
    final meta = await database.syncMetadataDao.getBySyncId(seeded.syncId);
    expect(meta?.version, greaterThan(1));
  });

  test('keep_remote applies the remote payload to the local journal record',
      () async {
    final seeded = await seedConflict(
      local: {'title': 'Local'},
      remote: {'title': 'RemoteWins'},
    );

    await service.resolveConflict(
      conflictId: seeded.conflictId,
      resolution: ConflictResolution.keepRemote,
    );

    final journal =
        await database.journalsDao.getJournalById(seeded.journalId);
    expect(journal.title, 'RemoteWins');
    final updated =
        await database.syncConflictsDao.getConflictById(seeded.conflictId);
    expect(updated.status, 'resolved');
  });

  test('merged resolution requires explicit merged data', () async {
    final seeded = await seedConflict(
      local: {'title': 'Local'},
      remote: {'title': 'Remote'},
    );

    expect(
      service.resolveConflict(
        conflictId: seeded.conflictId,
        resolution: ConflictResolution.merged,
      ),
      throwsA(isA<ConflictResolutionException>()),
    );
  });

  test('merged resolution applies the supplied merged payload', () async {
    final seeded = await seedConflict(
      local: {'title': 'Local'},
      remote: {'title': 'Remote'},
    );

    await service.resolveConflict(
      conflictId: seeded.conflictId,
      resolution: ConflictResolution.merged,
      mergedData: {'title': 'Merged'},
    );

    final journal =
        await database.journalsDao.getJournalById(seeded.journalId);
    expect(journal.title, 'Merged');
    final updated =
        await database.syncConflictsDao.getConflictById(seeded.conflictId);
    expect(updated.status, 'resolved');
  });
}
