import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/features/backup/presentation/restore_backup_screen.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// The gate is a security control, so it gets its own test: the restore
/// controls must not be reachable until the check passes.
void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required AppPinKeystore keystore,
    required BiometricAuthenticator biometric,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPinKeystoreProvider.overrideWithValue(keystore),
          biometricAuthenticatorProvider.overrideWithValue(biometric),
          // testWidgets runs in a fake-async zone, so real file listing never
          // completes and its spinner would keep pumpAndSettle spinning too.
          availableBackupFilesProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: RestoreBackupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with a PIN set, the restore controls stay hidden until it is '
      'entered correctly', (tester) async {
    final keystore = _InMemoryAppPinKeystore();
    // PBKDF2 yields through timers that only fire when frames are pumped, so
    // deriving the PIN outside the fake-async zone is the only way it lands.
    await tester.runAsync(
      () => AppPinService(keystore: keystore).setPin('4321'),
    );

    await pumpScreen(
      tester,
      keystore: keystore,
      biometric: _AlwaysSuccessBiometric(),
    );

    expect(find.byKey(const Key('restore-pin-field')), findsOneWidget);
    expect(find.byKey(const Key('restore-pick-file')), findsNothing);

    // A wrong PIN keeps the gate shut.
    await tester.enterText(find.byKey(const Key('restore-pin-field')), '0000');
    await tester.tap(find.byKey(const Key('restore-pin-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restore-pick-file')), findsNothing);
    expect(find.text('That PIN is not right.'), findsOneWidget);

    // The right one opens it.
    await tester.enterText(find.byKey(const Key('restore-pin-field')), '4321');
    await tester.tap(find.byKey(const Key('restore-pin-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restore-pick-file')), findsOneWidget);
    expect(find.byKey(const Key('restore-open-backup')), findsOneWidget);
  });

  testWidgets('a failed device-credential check leaves the screen locked', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      keystore: _InMemoryAppPinKeystore(),
      biometric: _AlwaysFailsBiometric(),
    );

    expect(find.byKey(const Key('restore-pick-file')), findsNothing);
    expect(find.text('Could not unlock. Nothing was changed.'), findsOneWidget);
  });

  testWidgets('a device with no lock at all can still reach the restore flow', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      keystore: _InMemoryAppPinKeystore(),
      biometric: _NoLockBiometric(),
    );

    expect(find.byKey(const Key('restore-pick-file')), findsOneWidget);
    // The replace / merge choice only appears once a backup has been opened.
    expect(find.byKey(const Key('restore-mode-merge')), findsNothing);
  });
}

class _AlwaysSuccessBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.success;
}

class _AlwaysFailsBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.failed;
}

class _NoLockBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => false;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.unavailable;
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
