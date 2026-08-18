import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

/// Stands in for the platform implementation so the mapping from
/// `local_auth` 3.x structured errors onto [BiometricAuthResult] can be tested
/// without a device.
class _FakeLocalAuthPlatform extends LocalAuthPlatform {
  _FakeLocalAuthPlatform({
    this.authenticateResult = true,
    this.authenticateError,
    this.deviceSupported = true,
    this.deviceSupportedError,
  });

  final bool authenticateResult;
  final Object? authenticateError;
  final bool deviceSupported;
  final Object? deviceSupportedError;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    if (authenticateError != null) throw authenticateError!;
    return authenticateResult;
  }

  @override
  Future<bool> isDeviceSupported() async {
    if (deviceSupportedError != null) throw deviceSupportedError!;
    return deviceSupported;
  }
}

void main() {
  final originalPlatform = LocalAuthPlatform.instance;

  tearDown(() {
    LocalAuthPlatform.instance = originalPlatform;
  });

  BiometricAuthenticator authenticatorWith(_FakeLocalAuthPlatform fake) {
    LocalAuthPlatform.instance = fake;
    return LocalAuthBiometricAuthenticator();
  }

  group('canAuthenticate', () {
    test('is true when the platform reports the device is supported', () async {
      final auth = authenticatorWith(_FakeLocalAuthPlatform());
      expect(await auth.canAuthenticate(), isTrue);
    });

    test('is false when the device is not supported', () async {
      final auth = authenticatorWith(
        _FakeLocalAuthPlatform(deviceSupported: false),
      );
      expect(await auth.canAuthenticate(), isFalse);
    });

    test('is false on a LocalAuthException instead of throwing', () async {
      final auth = authenticatorWith(
        _FakeLocalAuthPlatform(
          deviceSupportedError: const LocalAuthException(
            code: LocalAuthExceptionCode.deviceError,
          ),
        ),
      );
      expect(await auth.canAuthenticate(), isFalse);
    });

    test('is false on a raw PlatformException instead of throwing', () async {
      final auth = authenticatorWith(
        _FakeLocalAuthPlatform(
          deviceSupportedError: PlatformException(code: 'channel_error'),
        ),
      );
      expect(await auth.canAuthenticate(), isFalse);
    });
  });

  group('authenticate', () {
    test('returns success when the platform authenticates', () async {
      final auth = authenticatorWith(_FakeLocalAuthPlatform());
      expect(
        await auth.authenticate(reason: 'Unlock'),
        BiometricAuthResult.success,
      );
    });

    test('returns failed when the challenge is failed', () async {
      final auth = authenticatorWith(
        _FakeLocalAuthPlatform(authenticateResult: false),
      );
      expect(
        await auth.authenticate(reason: 'Unlock'),
        BiometricAuthResult.failed,
      );
    });

    // The user is present and can retry, so the lock gate must not fall
    // straight through to the PIN fallback for these.
    const retryableCodes = <LocalAuthExceptionCode>[
      LocalAuthExceptionCode.userCanceled,
      LocalAuthExceptionCode.userRequestedFallback,
      LocalAuthExceptionCode.timeout,
      LocalAuthExceptionCode.systemCanceled,
      LocalAuthExceptionCode.authInProgress,
      LocalAuthExceptionCode.temporaryLockout,
      LocalAuthExceptionCode.biometricLockout,
    ];

    for (final code in retryableCodes) {
      test('maps ${code.name} to failed', () async {
        final auth = authenticatorWith(
          _FakeLocalAuthPlatform(
            authenticateError: LocalAuthException(code: code),
          ),
        );
        expect(
          await auth.authenticate(reason: 'Unlock'),
          BiometricAuthResult.failed,
        );
      });
    }

    // The device genuinely cannot authenticate — the caller should offer the
    // app PIN instead.
    const unavailableCodes = <LocalAuthExceptionCode>[
      LocalAuthExceptionCode.noCredentialsSet,
      LocalAuthExceptionCode.noBiometricsEnrolled,
      LocalAuthExceptionCode.noBiometricHardware,
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable,
      LocalAuthExceptionCode.uiUnavailable,
      LocalAuthExceptionCode.deviceError,
      LocalAuthExceptionCode.unknownError,
    ];

    for (final code in unavailableCodes) {
      test('maps ${code.name} to unavailable', () async {
        final auth = authenticatorWith(
          _FakeLocalAuthPlatform(
            authenticateError: LocalAuthException(code: code),
          ),
        );
        expect(
          await auth.authenticate(reason: 'Unlock'),
          BiometricAuthResult.unavailable,
        );
      });
    }

    test('maps a raw PlatformException to unavailable', () async {
      final auth = authenticatorWith(
        _FakeLocalAuthPlatform(
          authenticateError: PlatformException(code: 'channel_error'),
        ),
      );
      expect(
        await auth.authenticate(reason: 'Unlock'),
        BiometricAuthResult.unavailable,
      );
    });
  });
}
