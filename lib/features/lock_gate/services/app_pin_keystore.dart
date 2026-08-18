import 'package:flutter/services.dart';

/// Salt + verifier metadata stored on the platform Keystore.
///
/// The raw PIN is never present here; only the PBKDF2 salt and verifier.
class AppPinCredentialPayload {
  const AppPinCredentialPayload({
    required this.saltBase64,
    required this.verifierBase64,
    required this.iterations,
  });

  final String saltBase64;
  final String verifierBase64;
  final int iterations;
}

/// Stores the app-lock PIN salt + verifier on the platform Keystore.
///
/// Test implementations may use an in-memory map.
abstract class AppPinKeystore {
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  });

  /// Returns the stored credential, or null if no credential has been set.
  Future<AppPinCredentialPayload?> getCredential();

  Future<void> clearCredential();
}

/// [AppPinKeystore] backed by the `sreerajp.journal_vault/app_pin_lock`
/// MethodChannel implemented in `MainActivity.kt`.
class MethodChannelAppPinKeystore implements AppPinKeystore {
  MethodChannelAppPinKeystore({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('sreerajp.journal_vault/app_pin_lock');

  final MethodChannel _channel;

  @override
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  }) async {
    await _channel.invokeMethod<void>('setAppPinCredential', <String, Object?>{
      'saltBase64': saltBase64,
      'verifierBase64': verifierBase64,
      'iterations': iterations,
    });
  }

  @override
  Future<AppPinCredentialPayload?> getCredential() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getAppPinCredential',
    );
    if (result == null) return null;
    final salt = result['saltBase64'];
    final verifier = result['verifierBase64'];
    final iterations = result['iterations'];
    if (salt is! String || verifier is! String || iterations is! int) {
      return null;
    }
    return AppPinCredentialPayload(
      saltBase64: salt,
      verifierBase64: verifier,
      iterations: iterations,
    );
  }

  @override
  Future<void> clearCredential() async {
    await _channel.invokeMethod<void>('clearAppPinCredential');
  }
}
