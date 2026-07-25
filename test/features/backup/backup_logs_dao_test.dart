import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> createLog({
    required String status,
    DateTime? startedAt,
    String trigger = 'manual',
  }) {
    return db.backupLogsDao.createLog(BackupLogsCompanion.insert(
      status: status,
      trigger: Value(trigger),
      startedAt: startedAt != null ? Value(startedAt) : const Value.absent(),
    ));
  }

  group('createLog + updateLog', () {
    test('inserts a new in-progress row that can be marked success later',
        () async {
      final id = await createLog(status: 'in_progress');
      await db.backupLogsDao.updateLog(
        id,
        BackupLogsCompanion(
          status: const Value('success'),
          backupPath: const Value('/tmp/backup.vault'),
          sizeBytes: const Value(2048),
          entryCount: const Value(5),
          attachmentCount: const Value(2),
          completedAt: Value(DateTime.utc(2026, 5, 9, 12)),
        ),
      );

      final log = (await db.backupLogsDao.getAllLogs()).single;
      expect(log.status, 'success');
      expect(log.backupPath, '/tmp/backup.vault');
      expect(log.sizeBytes, 2048);
      expect(log.entryCount, 5);
    });
  });

  group('getRecentLogs', () {
    test('returns logs ordered by startedAt desc with the given limit',
        () async {
      for (var i = 0; i < 5; i++) {
        await createLog(
          status: 'success',
          startedAt: DateTime.utc(2026, 5, i + 1, 12),
        );
      }
      final recent = await db.backupLogsDao.getRecentLogs(limit: 3);
      expect(recent, hasLength(3));
      expect(
        recent.first.startedAt.isAtSameMomentAs(DateTime.utc(2026, 5, 5, 12)),
        isTrue,
      );
      expect(
        recent.last.startedAt.isAtSameMomentAs(DateTime.utc(2026, 5, 3, 12)),
        isTrue,
      );
    });
  });

  group('getLatestSuccessful', () {
    test('returns null when there are no successful runs', () async {
      await createLog(status: 'failed');
      expect(await db.backupLogsDao.getLatestSuccessful(), isNull);
    });

    test('returns the latest success ignoring failures and in_progress',
        () async {
      final s1 = await createLog(status: 'success');
      await db.backupLogsDao.updateLog(s1, BackupLogsCompanion(
        completedAt: Value(DateTime.utc(2026, 5)),
      ));
      final s2 = await createLog(status: 'success');
      await db.backupLogsDao.updateLog(s2, BackupLogsCompanion(
        completedAt: Value(DateTime.utc(2026, 5, 5)),
      ));
      await createLog(status: 'failed');

      final latest = await db.backupLogsDao.getLatestSuccessful();
      expect(latest, isNotNull);
      expect(
        latest!.completedAt!.isAtSameMomentAs(DateTime.utc(2026, 5, 5)),
        isTrue,
      );
    });
  });

  group('getFailureCountSince', () {
    test('counts failed runs after the given timestamp only', () async {
      await createLog(
        status: 'failed',
        startedAt: DateTime.utc(2026, 4),
      );
      await createLog(
        status: 'failed',
        startedAt: DateTime.utc(2026, 5, 5),
      );
      await createLog(
        status: 'failed',
        startedAt: DateTime.utc(2026, 5, 6),
      );
      await createLog(
        status: 'success',
        startedAt: DateTime.utc(2026, 5, 6),
      );

      final count = await db.backupLogsDao
          .getFailureCountSince(DateTime.utc(2026, 5));
      expect(count, 2);
    });
  });

  group('deleteOldLogs', () {
    test('keeps the most recent N logs (default 50)', () async {
      for (var i = 0; i < 60; i++) {
        await createLog(
          status: 'success',
          startedAt: DateTime.utc(2026).add(Duration(hours: i)),
        );
      }

      await db.backupLogsDao.deleteOldLogs();
      final all = await db.backupLogsDao.getAllLogs();
      expect(all, hasLength(50));
      // The remaining ones should be the most recent (highest startedAt).
      final earliest = all.last.startedAt.toUtc();
      expect(earliest.isAfter(DateTime.utc(2026, 1, 1, 9)), isTrue);
    });

    test('honors a custom keepCount', () async {
      for (var i = 0; i < 10; i++) {
        await createLog(
          status: 'success',
          startedAt: DateTime.utc(2026).add(Duration(hours: i)),
        );
      }
      await db.backupLogsDao.deleteOldLogs(keepCount: 4);
      expect(await db.backupLogsDao.getAllLogs(), hasLength(4));
    });

    test('is a no-op when there are fewer logs than keepCount', () async {
      for (var i = 0; i < 3; i++) {
        await createLog(status: 'success');
      }
      await db.backupLogsDao.deleteOldLogs(keepCount: 10);
      expect(await db.backupLogsDao.getAllLogs(), hasLength(3));
    });
  });
}
