import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';

/// Credential data returned after creating a journal password.
///
/// Persist [credentialReference], [passwordSaltBase64],
/// [passwordVerifierBase64], and [passwordIterations] on the [Journal] row.
class JournalCredential {
  const JournalCredential({
    required this.credentialReference,
    required this.passwordSaltBase64,
    required this.passwordVerifierBase64,
    required this.passwordIterations,
  });

  final String credentialReference;
  final String passwordSaltBase64;
  final String passwordVerifierBase64;
  final int passwordIterations;
}

/// Handles password-based locking for individual journals.
///
/// Uses PBKDF2-HMAC-SHA256 to derive a verifier stored on the journal row.
/// The raw password is never stored. A random journal DEK is created via
/// [JournalSecretStore] alongside the verifier.
class JournalPasswordService {
  JournalPasswordService({required this._secretStore});

  final JournalSecretStore _secretStore;
  static const int _defaultIterations = 100000;
  static const int _saltLength = 16;

  final _sha256 = Sha256();

  /// Creates a credential for [journalId] using [password].
  ///
  /// Calls [JournalSecretStore.createSecret] to generate and store the journal
  /// DEK. Returns [JournalCredential] ready to be written to the journal row.
  Future<JournalCredential> createCredential({
    required int journalId,
    required String password,
  }) async {
    final credentialReference =
        '${journalId}_${DateTime.now().microsecondsSinceEpoch}';

    final salt = _generateSalt();
    final saltBase64 = base64.encode(salt);

    final verifierBytes = await _deriveVerifier(
      password,
      salt,
      _defaultIterations,
    );
    final verifierBase64 = base64.encode(verifierBytes);

    // Create and store the journal DEK in the secret store.
    await _secretStore.createSecret(credentialReference);

    return JournalCredential(
      credentialReference: credentialReference,
      passwordSaltBase64: saltBase64,
      passwordVerifierBase64: verifierBase64,
      passwordIterations: _defaultIterations,
    );
  }

  /// Returns true if [password] matches the stored verifier on [journal].
  Future<bool> verifyPassword({
    required Journal journal,
    required String password,
  }) async {
    if (journal.passwordSaltBase64 == null ||
        journal.passwordVerifierBase64 == null ||
        journal.passwordIterations == null) {
      return false;
    }

    final salt = base64.decode(journal.passwordSaltBase64!);
    final storedVerifier = base64.decode(journal.passwordVerifierBase64!);
    final iterations = journal.passwordIterations!;

    final derivedVerifier = await _deriveVerifier(password, salt, iterations);
    return _constantTimeEquals(derivedVerifier, storedVerifier);
  }

  /// Deletes the journal's DEK from the secret store.
  Future<void> deleteCredential(Journal journal) async {
    if (journal.credentialReference != null) {
      await _secretStore.deleteSecret(journal.credentialReference!);
    }
  }

  // ──────────────────────── helpers ────────────────────────

  Future<List<int>> _deriveVerifier(
    String password,
    List<int> salt,
    int iterations,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final derivedKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final derivedBytes = await derivedKey.extractBytes();
    // Hash the derived key once more so the verifier differs from the DEK.
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
