import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_id_generator.dart';

void main() {
  group('SyncIdGenerator.generate', () {
    test('produces a UUID for the given device + table + localId', () {
      final id = SyncIdGenerator.generate(
        deviceId: 'device-A',
        table: 'journals',
        localId: 7,
      );
      expect(id, hasLength(36));
      expect(
        id,
        matches(
          RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$'),
        ),
      );
    });

    test('is deterministic for identical inputs', () {
      final a = SyncIdGenerator.generate(
        deviceId: 'device-A',
        table: 'journals',
        localId: 7,
      );
      final b = SyncIdGenerator.generate(
        deviceId: 'device-A',
        table: 'journals',
        localId: 7,
      );
      expect(a, b);
    });

    test('changes when deviceId differs', () {
      final a = SyncIdGenerator.generate(
        deviceId: 'device-A',
        table: 'entries',
        localId: 1,
      );
      final b = SyncIdGenerator.generate(
        deviceId: 'device-B',
        table: 'entries',
        localId: 1,
      );
      expect(a, isNot(b));
    });

    test('changes when table differs', () {
      final a = SyncIdGenerator.generate(
        deviceId: 'd',
        table: 'journals',
        localId: 1,
      );
      final b = SyncIdGenerator.generate(
        deviceId: 'd',
        table: 'entries',
        localId: 1,
      );
      expect(a, isNot(b));
    });

    test('changes when localId differs', () {
      final a = SyncIdGenerator.generate(
        deviceId: 'd',
        table: 'entries',
        localId: 1,
      );
      final b = SyncIdGenerator.generate(
        deviceId: 'd',
        table: 'entries',
        localId: 2,
      );
      expect(a, isNot(b));
    });
  });

  group('SyncIdGenerator.generateDeviceId', () {
    test('is deterministic for the same androidId + fingerprint', () async {
      final a = await SyncIdGenerator.generateDeviceId(
        androidId: 'abc',
        buildFingerprint: 'pixel/8/release-keys',
      );
      final b = await SyncIdGenerator.generateDeviceId(
        androidId: 'abc',
        buildFingerprint: 'pixel/8/release-keys',
      );
      expect(a, b);
    });

    test('produces a 32-char lowercase hex fingerprint', () async {
      final id = await SyncIdGenerator.generateDeviceId(androidId: 'abc');
      expect(id, hasLength(32));
      expect(id, matches(RegExp(r'^[0-9a-f]{32}$')));
    });

    test('changes when androidId differs', () async {
      final a = await SyncIdGenerator.generateDeviceId(androidId: 'abc');
      final b = await SyncIdGenerator.generateDeviceId(androidId: 'xyz');
      expect(a, isNot(b));
    });
  });
}
