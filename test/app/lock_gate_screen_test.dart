import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

void main() {
  late AppDatabase testDatabase;

  setUp(() {
    testDatabase = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await testDatabase.close();
  });

  Future<void> pumpLockGate(
    WidgetTester tester, {
    required String lockMode,
    AppPinKeystore? keystore,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await testDatabase.appSecurityDao.updateLockState(
      AppSecurityCompanion(
        lockMode: Value(lockMode),
        isLocked: const Value(true),
      ),
    );

    await tester.pumpWidget(
      JournalVaultAppHost(
        database: testDatabase,
        overrides: <Override>[
          biometricAuthenticatorProvider.overrideWithValue(
            _AlwaysAllowBiometric(),
          ),
          appPinKeystoreProvider.overrideWithValue(
            keystore ?? _InMemoryAppPinKeystore(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('phone lock shows the headline, mode chip and unlock button', (
    tester,
  ) async {
    await pumpLockGate(tester, lockMode: 'phone_lock');

    expect(find.text('Your journal is locked'), findsOneWidget);
    expect(find.text('Unlock to open your entries.'), findsOneWidget);
    expect(find.text('Phone Lock'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.byKey(const Key('phone-lock-unlock-button')), findsOneWidget);
    // The old app bar is gone.
    expect(find.text('App Lock Gate'), findsNothing);
    expect(find.byKey(const Key('app-lock-pin-field')), findsNothing);

    await disposeApp(tester);
  });

  testWidgets('app lock shows the PIN field and a hide/show toggle', (
    tester,
  ) async {
    final keystore = _InMemoryAppPinKeystore();
    // PBKDF2 never finishes inside the fake-async zone, so derive the
    // credential on the real clock.
    await tester.runAsync(
      () => AppPinService(keystore: keystore).setPin('1234'),
    );
    await pumpLockGate(tester, lockMode: 'app_lock', keystore: keystore);

    expect(find.text('Separate App Lock'), findsOneWidget);
    final field = find.byKey(const Key('app-lock-pin-field'));
    expect(field, findsOneWidget);
    expect(tester.widget<TextField>(field).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_rounded));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).obscureText, isFalse);

    await disposeApp(tester);
  });

  testWidgets('a wrong PIN shows the error pill', (tester) async {
    final keystore = _InMemoryAppPinKeystore();
    // PBKDF2 never finishes inside the fake-async zone, so derive the
    // credential on the real clock.
    await tester.runAsync(
      () => AppPinService(keystore: keystore).setPin('1234'),
    );
    await pumpLockGate(tester, lockMode: 'app_lock', keystore: keystore);

    expect(find.byIcon(Icons.error_outline_rounded), findsNothing);

    await tester.enterText(find.byKey(const Key('app-lock-pin-field')), '0000');
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect PIN.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

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
