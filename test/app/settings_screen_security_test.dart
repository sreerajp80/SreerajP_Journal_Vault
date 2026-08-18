import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

void main() {
  late AppDatabase testDatabase;

  setUp(() async {
    testDatabase = AppDatabase.forExecutor(NativeDatabase.memory());
    await testDatabase.appSecurityDao.updateLockState(
      const AppSecurityCompanion(
        lockMode: Value('phone_lock'),
        isLocked: Value(true),
      ),
    );
  });

  tearDown(() async {
    await testDatabase.close();
  });

  Future<void> openSettings(
    WidgetTester tester, {
    ScreenSecurityStore? store,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      JournalVaultAppHost(
        database: testDatabase,
        overrides: <Override>[
          biometricAuthenticatorProvider.overrideWithValue(
            _AlwaysAllowBiometric(),
          ),
          appPinKeystoreProvider.overrideWithValue(_InMemoryAppPinKeystore()),
          if (store != null)
            screenSecurityStoreProvider.overrideWithValue(store),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // The switch lives on the Security section page, behind its card.
    await tester.tap(find.byKey(const Key('settings-card-security')));
    await tester.pumpAndSettle();
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('both lock modes show as radio options, current one picked', (
    tester,
  ) async {
    await openSettings(tester);

    final phone = find.byKey(const Key('settings-lock-mode-phone'));
    final app = find.byKey(const Key('settings-lock-mode-app'));
    expect(phone, findsOneWidget);
    expect(app, findsOneWidget);

    expect(
      find.text('Use the device biometric or PIN/pattern/password.'),
      findsOneWidget,
    );
    expect(
      find.text('Use a dedicated PIN that is verified inside the app.'),
      findsOneWidget,
    );

    // The lock state set up in setUp() is phone_lock.
    final group = tester.widget<RadioGroup<AppLockMode>>(
      find.byType(RadioGroup<AppLockMode>),
    );
    expect(group.groupValue, AppLockMode.phoneLock);

    // Tapping the already-active mode changes nothing and asks nothing.
    await tester.tap(phone);
    await tester.pumpAndSettle();
    expect(find.text('Switch lock mode?'), findsNothing);

    await disposeApp(tester);
  });

  testWidgets('screenshot blocking shows as on by default', (tester) async {
    await openSettings(tester);

    final tile = find.byKey(const Key('settings-screen-security'));
    expect(tile, findsOneWidget);
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);

    await disposeApp(tester);
  });

  testWidgets('turning it off asks first, and cancelling keeps it on', (
    tester,
  ) async {
    final store = InMemoryScreenSecurityStore();
    await openSettings(tester, store: store);

    await tester.tap(find.byKey(const Key('settings-screen-security')));
    await tester.pumpAndSettle();

    expect(find.text('Turn off screenshot blocking?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('settings-screen-security')),
          )
          .value,
      isTrue,
    );
    expect(await store.read(), isTrue);

    await disposeApp(tester);
  });

  testWidgets('confirming turns screenshot blocking off', (tester) async {
    final store = InMemoryScreenSecurityStore();
    await openSettings(tester, store: store);

    await tester.tap(find.byKey(const Key('settings-screen-security')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-screen-security-confirm')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('settings-screen-security')),
          )
          .value,
      isFalse,
    );
    expect(await store.read(), isFalse);
    expect(find.text('Screenshot blocking is off'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('turning it back on needs no confirmation', (tester) async {
    final store = InMemoryScreenSecurityStore(enabled: false);
    await openSettings(tester, store: store);

    await tester.tap(find.byKey(const Key('settings-screen-security')));
    await tester.pumpAndSettle();

    expect(find.text('Turn off screenshot blocking?'), findsNothing);
    expect(await store.read(), isTrue);
    expect(find.text('Screenshot blocking is on'), findsOneWidget);

    await disposeApp(tester);
  });
}

class _InMemoryAppPinKeystore implements AppPinKeystore {
  AppPinCredentialPayload? _stored;

  @override
  Future<AppPinCredentialPayload?> getCredential() async => _stored;

  @override
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  }) async {
    _stored = AppPinCredentialPayload(
      saltBase64: saltBase64,
      verifierBase64: verifierBase64,
      iterations: iterations,
    );
  }

  @override
  Future<void> clearCredential() async {
    _stored = null;
  }
}

class _AlwaysAllowBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.success;
}
