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
}

class _RecordingStore implements ScreenSecurityStore {
  _RecordingStore({this.enabled = true});

  final bool enabled;
  final List<bool> writes = [];

  @override
  Future<bool> read() async => enabled;

  @override
  Future<void> write({required bool enabled}) async => writes.add(enabled);
}

class _FailingStore implements ScreenSecurityStore {
  @override
  Future<bool> read() async => true;

  @override
  Future<void> write({required bool enabled}) async =>
      throw const ScreenSecurityPersistenceException();
}
