import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/security/keyboard_privacy_controller.dart';

void main() {
  ProviderContainer containerWith(KeyboardPrivacyStore store) {
    final container = ProviderContainer(
      overrides: [keyboardPrivacyStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('is on by default', () {
    final container = containerWith(InMemoryKeyboardPrivacyStore());

    expect(container.read(keyboardPrivacyProvider), isTrue);
  });

  test('reads a stored off value', () {
    final container = containerWith(
      InMemoryKeyboardPrivacyStore(enabled: false),
    );

    expect(container.read(keyboardPrivacyProvider), isFalse);
  });

  test('a store that cannot be read counts as on', () {
    final container = containerWith(_BrokenStore());

    expect(container.read(keyboardPrivacyProvider), isTrue);
  });

  test('setEnabled saves and updates the value', () async {
    final store = InMemoryKeyboardPrivacyStore();
    final container = containerWith(store);

    await container.read(keyboardPrivacyProvider.notifier).setEnabled(false);

    expect(store.enabled, isFalse);
    expect(container.read(keyboardPrivacyProvider), isFalse);
  });

  test('a failed save keeps the old value and reports it', () async {
    final container = containerWith(_BrokenStore(readValue: true));

    await expectLater(
      container.read(keyboardPrivacyProvider.notifier).setEnabled(false),
      throwsA(isA<KeyboardPrivacyPersistenceException>()),
    );
    expect(container.read(keyboardPrivacyProvider), isTrue);
  });

  group('SharedPreferences store', () {
    test('a missing value reads as on', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesKeyboardPrivacyStore(
        await SharedPreferences.getInstance(),
      );

      expect(store.read(), isTrue);
    });

    test('saves under keyboard_privacy', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = SharedPreferencesKeyboardPrivacyStore(prefs);

      await store.write(enabled: false);

      expect(prefs.getBool(KeyboardPrivacyStore.prefKey), isFalse);
      expect(store.read(), isFalse);
    });
  });
}

class _BrokenStore implements KeyboardPrivacyStore {
  _BrokenStore({this.readValue});

  /// Null makes [read] throw too.
  final bool? readValue;

  @override
  bool read() => readValue ?? (throw StateError('unreadable'));

  @override
  Future<void> write({required bool enabled}) async =>
      throw StateError('unwritable');
}
