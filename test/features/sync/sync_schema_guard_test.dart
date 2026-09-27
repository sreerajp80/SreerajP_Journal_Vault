import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_protocol.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_schema_guard.dart';

void main() {
  late AppDatabase db;
  late SyncSchemaGuard guard;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    guard = SyncSchemaGuard(db, syncableTables: SyncEngine.syncableTables);
  });

  tearDown(() => db.close());

  group('isSyncable', () {
    test('accepts every syncable table', () {
      for (final table in SyncEngine.syncableTables) {
        expect(guard.isSyncable(table), isTrue, reason: table);
      }
    });

    test('rejects tables that must not sync, and SQL in the name', () {
      for (final table in [
        'app_security',
        'sync_metadata',
        'sqlite_master',
        'entries; DROP TABLE journals',
        '',
      ]) {
        expect(guard.isSyncable(table), isFalse, reason: table);
      }
    });
  });

  group('knownColumns', () {
    test('keeps real columns and drops unknown ones', () {
      final kept = guard.knownColumns('journals', {
        'id': 1,
        'title': 'Travel',
        'column_from_a_newer_app': 'x',
        'title = title; DROP TABLE journals; --': 'y',
      });

      expect(kept, {'id': 1, 'title': 'Travel'});
    });

    test('returns nothing for a table that does not sync', () {
      expect(guard.knownColumns('app_security', {'lock_mode': null}), isEmpty);
    });
  });

  test(
    'a pulled record for a table that does not sync is skipped, the rest applies',
    () async {
      final encryption = SyncEncryptionService();
      const password = 'pairing-code';
      final key = await encryption.deriveKey(
        password,
        List.generate(16, (i) => i),
      );
      Future<SyncRecord> record(
        String syncId,
        String table,
        Map<String, dynamic> data,
      ) async => SyncRecord(
        syncId: syncId,
        recordTable: table,
        version: 1,
        deviceId: 'other-phone',
        isDeleted: false,
        lastModifiedAt: DateTime(2026, 9, 27),
        encryptedData: await encryption.encryptRecord(data, key),
      );

      final protocol = _FakeProtocol([
        await record('s-1', 'app_security', {
          'lock_mode': null,
          'is_locked': false,
        }),
        await record('s-2', 'journals', {
          'id': 7,
          'title': 'From the other phone',
          'unknown_column': 'dropped',
        }),
      ]);

      final status = await SyncEngine(
        db: db,
        protocol: protocol,
        encryption: encryption,
        deviceId: 'this-phone',
        role: SyncRole.receiver,
      ).performSync(syncPassword: password, maxRetries: 0);

      expect(status, SyncStatus.success);
      final journals = await db.journalsDao.getAllJournals();
      expect(journals.map((j) => j.title), ['From the other phone']);
      expect(await db.select(db.appSecurity).get(), isEmpty);
    },
  );
}

class _FakeProtocol implements SyncProtocol {
  _FakeProtocol(this._records);

  final List<SyncRecord> _records;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<SyncPushResult> push(SyncPayload payload) async => SyncPushResult(
    accepted: payload.records.length,
    rejected: 0,
    conflicts: 0,
  );

  @override
  Future<SyncPullResult> pull(
    DateTime? lastSyncTimestamp,
    String deviceId,
  ) async => SyncPullResult(records: _records);

  @override
  Future<SyncRemoteInfo> getRemoteInfo() async =>
      const SyncRemoteInfo(serverVersion: 'test', connectedDevices: 1);

  @override
  Future<void> acknowledge(SyncAck ack) async {}
}
