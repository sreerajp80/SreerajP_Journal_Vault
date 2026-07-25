import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Result of a biometric / device-credential authentication attempt.
enum BiometricAuthResult {
  /// User authenticated successfully.
  success,

  /// User explicitly cancelled or failed authentication.
  failed,

  /// The device cannot perform authentication (no enrollment, no hardware).
  unavailable,
}

/// Wraps `local_auth`'s device-credential / biometric prompt. Behind an
/// abstract interface so tests can substitute a fake.
abstract class BiometricAuthenticator {
  /// Returns true if the device has biometrics or a device PIN/pattern/password
  /// configured and available for prompts.
  Future<bool> canAuthenticate();

  /// Triggers the system unlock prompt with [reason] as user-facing text.
  Future<BiometricAuthResult> authenticate({required String reason});
}

class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> canAuthenticate() async {
    try {
      // isDeviceSupported() is true when the device has either a biometric
      // sensor or a configured device credential (PIN/pattern/password).
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return ok ? BiometricAuthResult.success : BiometricAuthResult.failed;
    } on PlatformException {
      return BiometricAuthResult.unavailable;
    }
  }
}
