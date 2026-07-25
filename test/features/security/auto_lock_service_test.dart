import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/security/services/auto_lock_service.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AutoLockService service;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    service = AutoLockService(
      database: database,
      securityEventService: SecurityEventService(database: database),
    );
  });

  tearDown(() async {
    service.dispose();
    await database.close();
  });

  test('activating a profile deactivates all others', () async {
    final aId =
        await service.createProfile(name: 'A', timeoutSeconds: 60);
    final bId =
        await service.createProfile(name: 'B', timeoutSeconds: 120);
    final cId =
        await service.createProfile(name: 'C', timeoutSeconds: 300);

    await service.activateProfile(aId);
    var profiles = await service.getAllProfiles();
    expect(profiles.singleWhere((p) => p.id == aId).isActive, isTrue);
    expect(profiles.where((p) => p.isActive).map((p) => p.id), [aId]);

    await service.activateProfile(bId);
    profiles = await service.getAllProfiles();
    expect(profiles.where((p) => p.isActive).map((p) => p.id), [bId]);

    await service.activateProfile(cId);
    profiles = await service.getAllProfiles();
    expect(profiles.where((p) => p.isActive).map((p) => p.id), [cId]);
  });

  test('deactivateAll clears all active flags', () async {
    final aId = await service.createProfile(name: 'A', timeoutSeconds: 60);
    final bId = await service.createProfile(name: 'B', timeoutSeconds: 120);
    await service.activateProfile(aId);
    await service.activateProfile(bId);

    await service.deactivateAll();

    final profiles = await service.getAllProfiles();
    expect(profiles.every((p) => !p.isActive), isTrue);
  });

  test('updateProfile updates only the requested fields', () async {
    final id = await service.createProfile(
      name: 'Default',
      timeoutSeconds: 300,
    );

    await service.updateProfile(id: id, timeoutSeconds: 120);

    final profile = (await service.getAllProfiles()).single;
    expect(profile.name, 'Default');
    expect(profile.timeoutSeconds, 120);
    expect(profile.lockOnMinimize, isTrue);
  });

  test('deleteProfile removes the row', () async {
    final id = await service.createProfile(name: 'X', timeoutSeconds: 60);
    expect(await service.getAllProfiles(), hasLength(1));
    await service.deleteProfile(id);
    expect(await service.getAllProfiles(), isEmpty);
  });

  test('onAppMinimized triggers lock when active profile requires it',
      () async {
    final id = await service.createProfile(
      name: 'Strict',
      timeoutSeconds: 60,
    );
    await service.activateProfile(id);

    expect(await service.onAppMinimized(), isTrue);
  });

  test('onAppMinimized is a no-op without an active profile', () async {
    expect(await service.onAppMinimized(), isFalse);
  });

  test('recordActivity tracks the latest activity timestamp', () async {
    final before = DateTime.now();
    expect(service.lastActivity, isNull);

    service.recordActivity();
    // Allow the awaited db read inside recordActivity to settle.
    await Future<void>.delayed(Duration.zero);

    final last = service.lastActivity!;
    expect(last.isAfter(before) || last.isAtSameMomentAs(before), isTrue);
  });

  test('lock_triggered event is logged when the inactivity timer fires',
      () async {
    // _triggerLock only logs when a lock mode is configured.
    await database.appSecurityDao.updateLockState(
      const AppSecurityCompanion(lockMode: Value('phone_lock')),
    );

    final id = await service.createProfile(
      name: 'Quick',
      timeoutSeconds: 1,
    );
    await service.activateProfile(id);

    // The Timer fires after 1s (real time); poll briefly with a check loop
    // rather than fakeAsync because AutoLockService uses real Timers.
    var elapsed = 0;
    while (elapsed < 3000) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      elapsed += 200;
      final events =
          await database.securityEventsDao.getRecentEvents();
      if (events.any((e) => e.eventType == 'lock_triggered')) {
        return; // success
      }
    }
    fail('Inactivity Timer did not log a lock_triggered event in 3 seconds');
  }, timeout: const Timeout(Duration(seconds: 10)));
}
