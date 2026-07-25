import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

/// Platform Keystore-backed app PIN storage. Override in tests with an
/// in-memory fake.
final appPinKeystoreProvider = Provider<AppPinKeystore>((ref) {
  return MethodChannelAppPinKeystore();
});

final appPinServiceProvider = Provider<AppPinService>((ref) {
  return AppPinService(keystore: ref.watch(appPinKeystoreProvider));
});

/// Device-credential / biometric authenticator. Override in tests with a fake
/// that returns [BiometricAuthResult.success].
final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>((ref) {
  return LocalAuthBiometricAuthenticator();
});
