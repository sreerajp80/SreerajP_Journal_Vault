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
    } on LocalAuthException {
      return false;
    } on PlatformException {
      // local_auth 3.x reports failures as LocalAuthException, but a platform
      // implementation can still surface a raw channel error.
      return false;
    }
  }

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        // local_auth 3.0 replaced AuthenticationOptions.stickyAuth with this.
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricAuthResult.success : BiometricAuthResult.failed;
    } on LocalAuthException catch (e) {
      return _resultForCode(e.code);
    } on PlatformException {
      return BiometricAuthResult.unavailable;
    }
  }

  /// Maps a structured `local_auth` 3.x failure code onto our three states.
  ///
  /// The plugin documents that new codes may be added without a breaking
  /// change, so this must keep a fallback branch.
  static BiometricAuthResult _resultForCode(LocalAuthExceptionCode code) {
    switch (code) {
      // The user is present and could try again — treat as a failed attempt.
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.userRequestedFallback:
      case LocalAuthExceptionCode.timeout:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.authInProgress:
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        return BiometricAuthResult.failed;

      // The device cannot authenticate right now — fall back to the app PIN.
      case LocalAuthExceptionCode.noCredentialsSet:
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
      case LocalAuthExceptionCode.uiUnavailable:
      case LocalAuthExceptionCode.deviceError:
      case LocalAuthExceptionCode.unknownError:
        return BiometricAuthResult.unavailable;
    }
  }
}
