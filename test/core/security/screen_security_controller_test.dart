import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';

void main() {
  ProviderContainer containerWith(ScreenSecurityStore store) {
    final container = ProviderContainer(
      overrides: [screenSecurityStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts from the stored value, which defaults to protected', () async {
    final container = containerWith(InMemoryScreenSecurityStore());

    expect(await container.read(screenSecurityProvider.future), isTrue);
  });

  test('reads a stored off value', () async {
    final container = containerWith(
      InMemoryScreenSecurityStore(enabled: false),
    );

    expect(await container.read(screenSecurityProvider.future), isFalse);
  });

  test('turning protection off writes through and updates state', () async {
    final store = _RecordingStore();
    final container = containerWith(store);
    await container.read(screenSecurityProvider.future);

    await container.read(screenSecurityProvider.notifier).setEnabled(false);

    expect(store.writes, [false]);
    expect(container.read(screenSecurityProvider).value, isFalse);
  });

  test('turning protection back on writes through', () async {
    final store = _RecordingStore(enabled: false);
    final container = containerWith(store);
    await container.read(screenSecurityProvider.future);

    await container.read(screenSecurityProvider.notifier).setEnabled(true);

    expect(store.writes, [true]);
    expect(container.read(screenSecurityProvider).value, isTrue);
  });

  test('setting the value it already has writes nothing', () async {
    final store = _RecordingStore();
    final container = containerWith(store);
    await container.read(screenSecurityProvider.future);

    await container.read(screenSecurityProvider.notifier).setEnabled(true);

    expect(store.writes, isEmpty);
  });

  test('a failed write rolls the value back and throws', () async {
    final container = containerWith(_FailingStore());
    await container.read(screenSecurityProvider.future);

    await expectLater(
      container.read(screenSecurityProvider.notifier).setEnabled(false),
      throwsA(isA<ScreenSecurityPersistenceException>()),
    );
    expect(container.read(screenSecurityProvider).value, isTrue);
  });

  group('a screen holding protection on', () {
    test('turns the window on and saves nothing, then restores off', () async {
      final store = InMemoryScreenSecurityStore(enabled: false);
      final container = containerWith(store);
      await container.read(screenSecurityProvider.future);
      final controller = container.read(screenSecurityProvider.notifier);

      await controller.holdOn();
      expect(store.liveEnabled, isTrue);
      expect(store.enabled, isFalse);
      expect(container.read(screenSecurityProvider).value, isFalse);

      await controller.releaseHold();
      expect(store.liveEnabled, isFalse);
      expect(store.enabled, isFalse);
    });

    test('two holds keep the window on until both are released', () async {
      final store = InMemoryScreenSecurityStore(enabled: false);
      final container = containerWith(store);
      await container.read(screenSecurityProvider.future);
      final controller = container.read(screenSecurityProvider.notifier);

      await controller.holdOn();
      await controller.holdOn();
      await controller.releaseHold();
      expect(store.liveEnabled, isTrue);

      await controller.releaseHold();
      expect(store.liveEnabled, isFalse);
    });

    test('with the saved choice on, stays on and saves nothing', () async {
      final store = _RecordingStore();
      final container = containerWith(store);
      await container.read(screenSecurityProvider.future);
      final controller = container.read(screenSecurityProvider.notifier);

      await controller.holdOn();
      await controller.releaseHold();

      expect(store.writes, isEmpty);
      expect(store.applies, [true, true]);
    });

    test(
      'turning protection off during a hold saves off, keeps it on live',
      () async {
        final store = InMemoryScreenSecurityStore();
        final container = containerWith(store);
        await container.read(screenSecurityProvider.future);
        final controller = container.read(screenSecurityProvider.notifier);

        await controller.holdOn();
        await controller.setEnabled(false);
        expect(store.enabled, isFalse);
        expect(store.liveEnabled, isTrue);

        await controller.releaseHold();
        expect(store.liveEnabled, isFalse);
      },
    );

    test('a release without a hold changes nothing', () async {
      final store = _RecordingStore();
      final container = containerWith(store);
      await container.read(screenSecurityProvider.future);

      await container.read(screenSecurityProvider.notifier).releaseHold();

      expect(store.applies, isEmpty);
    });

    test('a failing live update never throws', () async {
      final container = containerWith(_FailingStore());
      await container.read(screenSecurityProvider.future);
      final controller = container.read(screenSecurityProvider.notifier);

      await expectLater(controller.holdOn(), completes);
      await expectLater(controller.releaseHold(), completes);
    });
  });
}

class _RecordingStore implements ScreenSecurityStore {
  _RecordingStore({this.enabled = true});

  final bool enabled;
  final List<bool> writes = [];
  final List<bool> applies = [];

  @override
  Future<bool> read() async => enabled;

  @override
  Future<void> write({required bool enabled}) async => writes.add(enabled);

  @override
  Future<void> apply({required bool enabled}) async => applies.add(enabled);
}

class _FailingStore implements ScreenSecurityStore {
  @override
  Future<bool> read() async => true;

  @override
  Future<void> write({required bool enabled}) async =>
      throw const ScreenSecurityPersistenceException();

  @override
  Future<void> apply({required bool enabled}) async =>
      throw StateError('no window');
}
