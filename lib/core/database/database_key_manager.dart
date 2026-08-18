import 'dart:convert';

import 'package:flutter/services.dart';

/// The raw key that unlocks the SQLCipher database.
///
/// Layer: core. Holds key material, so it must never be logged, put in an
/// exception message, or written anywhere except into SQLCipher itself.
/// [toString] is overridden for exactly that reason.
class DatabaseKey {
  DatabaseKey(this.bytes) {
    if (bytes.length != databaseKeyLengthBytes) {
      throw ArgumentError.value(
        bytes.length,
        'bytes.length',
        'A SQLCipher raw key must be $databaseKeyLengthBytes bytes',
      );
    }
  }

  /// Builds a key from the base64 form the platform channel returns.
  factory DatabaseKey.fromBase64(String encoded) =>
      DatabaseKey(base64.decode(encoded));

  final Uint8List bytes;

  /// The key in SQLCipher's raw-key form, `x'<64 hex chars>'`.
  ///
  /// A raw key is used deliberately: it tells SQLCipher to take these bytes as
  /// the key directly and skip its PBKDF2 step, which would otherwise add a
  /// noticeable delay to every open for no gain — the bytes already come from
  /// a random source, not from a password.
  ///
  /// Note the exact spelling SQLCipher expects. As a pragma it must be wrapped
  /// in double quotes, `PRAGMA key = "x'…'"`; a bare `x'…'` blob literal is
  /// read as a *different* key and the database will not open. In `ATTACH` it
  /// is bound as an ordinary text parameter instead.
  String get sqlCipherRawKey {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return "x'$hex'";
  }

  @override
  String toString() => 'DatabaseKey(<redacted>)';
}

/// Length of a SQLCipher raw key: AES-256 needs 32 bytes.
const int databaseKeyLengthBytes = 32;

/// Supplies the database encryption key.
///
/// Layer: core service. Knows nothing about widgets, Drift, or file paths.
abstract class DatabaseKeyManager {
  /// Returns the key, or null when none exists yet and [createIfMissing] is
  /// false.
  ///
  /// Callers must pass `createIfMissing: false` whenever an encrypted database
  /// file already exists. Creating a fresh key in that situation would leave
  /// the real vault permanently unreadable while the app looked healthy —
  /// which the user would experience as silent data loss.
  Future<DatabaseKey?> obtainKey({required bool createIfMissing});
}

/// [DatabaseKeyManager] backed by the Android Keystore over a `MethodChannel`.
///
/// The platform side generates 32 bytes from `SecureRandom`, wraps them with
/// AES-256-GCM under a Keystore-resident key, and stores only `iv:ciphertext`
/// in a private SharedPreferences file. Dart sees the raw bytes only for as
/// long as it takes to hand them to SQLCipher.
class PlatformDatabaseKeyManager implements DatabaseKeyManager {
  const PlatformDatabaseKeyManager({MethodChannel? channel})
    : _channel = channel ?? _defaultChannel;

  static const MethodChannel _defaultChannel = MethodChannel(
    'sreerajp.journal_vault/database_key',
  );

  final MethodChannel _channel;

  @override
  Future<DatabaseKey?> obtainKey({required bool createIfMissing}) async {
    try {
      final encoded = await _channel.invokeMethod<String>('getDatabaseKey', {
        'createIfMissing': createIfMissing,
      });
      if (encoded == null || encoded.isEmpty) return null;
      return DatabaseKey.fromBase64(encoded);
    } on PlatformException catch (error) {
      // 'missing_key' is the expected answer to "is there a key yet?" and is
      // not a failure. Anything else is.
      if (error.code == 'missing_key') return null;
      throw DatabaseKeyUnavailableException(error.code);
    } on MissingPluginException {
      throw const DatabaseKeyUnavailableException('channel_unavailable');
    }
  }
}

/// Thrown when the key cannot be read from the Keystore.
///
/// Carries a short reason code only — never the platform error message, which
/// could quote data.
class DatabaseKeyUnavailableException implements Exception {
  const DatabaseKeyUnavailableException(this.reasonCode);

  final String reasonCode;

  @override
  String toString() => 'DatabaseKeyUnavailableException($reasonCode)';
}
