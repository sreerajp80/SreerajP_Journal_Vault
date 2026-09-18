// Test doubles shared by the tests next to this file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

class FailingThemeModeStore extends ThemeModeStore {
  @override
  ThemeMode read() => ThemeMode.light;

  @override
  Future<void> save(ThemeMode mode) async {
    throw const ThemeModePersistenceException();
  }

  @override
  Future<void> saveAppThemeMode(AppThemeMode mode) async {
    throw const ThemeModePersistenceException();
  }
}

class FakeBiometricAuthenticator implements BiometricAuthenticator {
  BiometricAuthResult nextResult = BiometricAuthResult.success;

  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      nextResult;
}

class InMemoryAppPinKeystore implements AppPinKeystore {
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

Future<void> unlockPhoneLock(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
  await tester.pumpAndSettle();
}

/// Walks the app through paused → hidden → inactive → resumed so any
/// `AppLifecycleListener` registered by Flutter or plugins observes valid
/// transitions.
Future<void> cycleLifecyclePauseResume(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pumpAndSettle();
  }
}

Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.idle();
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pumpAndSettle();
}
