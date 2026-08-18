import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';

/// Derives and verifies the app-lock PIN against the platform-stored
/// PBKDF2 salt + verifier. The raw PIN is never stored, only a derived
/// 256-bit verifier hashed once more with SHA-256.
class AppPinService {
  AppPinService({required this._keystore});

  final AppPinKeystore _keystore;
  static const int _defaultIterations = 100000;
  static const int _saltLength = 16;

  final _sha256 = Sha256();

  Future<bool> hasPin() async => (await _keystore.getCredential()) != null;

  /// Derives a fresh salt + verifier for [pin] and persists them via the
  /// keystore. Replaces any prior credential.
  Future<void> setPin(String pin) async {
    if (pin.isEmpty) {
      throw ArgumentError.value(pin, 'pin', 'PIN must not be empty');
    }
    final salt = _generateSalt();
    final verifier = await _deriveVerifier(pin, salt, _defaultIterations);
    await _keystore.setCredential(
      saltBase64: base64.encode(salt),
      verifierBase64: base64.encode(verifier),
      iterations: _defaultIterations,
    );
  }

  /// Returns true if [pin] matches the stored verifier. Returns false if no
  /// credential is stored.
  Future<bool> verifyPin(String pin) async {
    final credential = await _keystore.getCredential();
    if (credential == null) return false;

    final salt = base64.decode(credential.saltBase64);
    final stored = base64.decode(credential.verifierBase64);
    final derived = await _deriveVerifier(pin, salt, credential.iterations);
    return _constantTimeEquals(derived, stored);
  }

  Future<void> clearPin() => _keystore.clearCredential();

  Future<List<int>> _deriveVerifier(
    String pin,
    List<int> salt,
    int iterations,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final derivedKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    final derivedBytes = await derivedKey.extractBytes();
    final hash = await _sha256.hash(derivedBytes);
    return hash.bytes;
  }

  List<int> _generateSalt() {
    final rng = Random.secure();
    return List<int>.generate(_saltLength, (_) => rng.nextInt(256));
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
