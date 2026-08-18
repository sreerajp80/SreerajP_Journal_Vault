import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';

/// [JournalSecretStore] backed by the `sreerajp.journal_vault/journal_lock`
/// MethodChannel implemented in `MainActivity.kt`. The native side wraps the
/// secret with a Keystore-resident AES key before persisting it in
/// SharedPreferences, so the raw bytes never reach disk in plaintext.
class MethodChannelJournalSecretStore implements JournalSecretStore {
  MethodChannelJournalSecretStore({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('sreerajp.journal_vault/journal_lock');

  final MethodChannel _channel;
  static const int _secretLength = 32;

  @override
  Future<List<int>> createSecret(String credentialReference) async {
    final rng = Random.secure();
    final bytes = List<int>.generate(_secretLength, (_) => rng.nextInt(256));
    await _channel.invokeMethod<void>('storeJournalSecret', <String, Object?>{
      'credentialReference': credentialReference,
      'secretBase64': base64.encode(bytes),
    });
    return bytes;
  }

  @override
  Future<List<int>> loadSecret(String credentialReference) async {
    try {
      final secretBase64 = await _channel.invokeMethod<String>(
        'loadJournalSecret',
        <String, Object?>{'credentialReference': credentialReference},
      );
      if (secretBase64 == null) {
        throw JournalSecretUnavailableException(credentialReference);
      }
      return base64.decode(secretBase64);
    } on PlatformException catch (error) {
      if (error.code == 'missing_secret') {
        throw JournalSecretUnavailableException(credentialReference);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteSecret(String credentialReference) async {
    await _channel.invokeMethod<void>('deleteJournalSecret', <String, Object?>{
      'credentialReference': credentialReference,
    });
  }
}
