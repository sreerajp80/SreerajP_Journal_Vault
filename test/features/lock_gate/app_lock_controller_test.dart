import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('switchLockMode persists for the next controller instance', () async {
    final firstController = AppLockController(
      database: database,
      observeLifecycle: false,
    );
    await firstController.ready();

    await firstController.switchLockMode(AppLockMode.appLock);
    firstController.dispose();

    final secondController = AppLockController(
      database: database,
      observeLifecycle: false,
    );
    await secondController.ready();

    expect(secondController.lockMode, AppLockMode.appLock);
    expect(secondController.isLocked, isTrue);

    secondController.dispose();
  });

  test('paused lifecycle state relocks the app', () async {
    final controller = AppLockController(
      database: database,
      observeLifecycle: false,
    );
    await controller.ready();
    await controller.unlock();

    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);

    expect(controller.isLocked, isTrue);

    controller.dispose();
  });

  test('lock() persists isLocked=true so a crash cannot reopen unlocked',
      () async {
    final first = AppLockController(database: database, observeLifecycle: false);
    await first.ready();
    await first.switchLockMode(AppLockMode.appLock);
    await first.unlock();
    await first.lock();
    first.dispose();

    final settings = await database.appSecurityDao.getSecuritySettings();
    expect(settings.isLocked, isTrue);

    final second = AppLockController(database: database, observeLifecycle: false);
    await second.ready();
    expect(second.isLocked, isTrue);
    second.dispose();
  });

  test('cold launch always starts locked when a lock mode is configured',
      () async {
    final first = AppLockController(database: database, observeLifecycle: false);
    await first.ready();
    await first.switchLockMode(AppLockMode.phoneLock);
    await first.unlock();
    first.dispose();

    // Even with persisted isLocked=false, ready() must reset to locked because
    // a process kill is not a lifecycle event and we cannot distinguish it
    // from a normal cold start.
    final second = AppLockController(database: database, observeLifecycle: false);
    await second.ready();
    expect(second.lockMode, AppLockMode.phoneLock);
    expect(second.isLocked, isTrue);
    second.dispose();
  });

  test('cold launch leaves isLocked=false when no lock mode is configured',
      () async {
    final controller = AppLockController(
      database: database,
      observeLifecycle: false,
    );
    await controller.ready();

    expect(controller.lockMode, isNull);
    expect(controller.isLocked, isFalse);

    controller.dispose();
  });

  test('unlock() persists isLocked=false', () async {
    final controller = AppLockController(
      database: database,
      observeLifecycle: false,
    );
    await controller.ready();
    await controller.switchLockMode(AppLockMode.phoneLock);
    await controller.unlock();

    final settings = await database.appSecurityDao.getSecuritySettings();
    expect(settings.isLocked, isFalse);

    controller.dispose();
  });
}
