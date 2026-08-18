/// Why the encrypted vault could not be opened.
///
/// Layer: core. Every value here is a dead end for the app — there is no
/// safe automatic recovery, because every recovery that would "fix" it means
/// throwing the user's journal away.
enum DatabaseOpenFailureKind {
  /// The Keystore has no key for this vault, or it can no longer be unwrapped.
  ///
  /// Usual causes: the Keystore was wiped, the app's data was cleared while
  /// the database file survived, or the device was restored from an image.
  keyUnavailable,

  /// SQLCipher is not the library that was actually loaded.
  ///
  /// This is a build problem, not a user problem — see `docs/dependencies.md`.
  /// The app refuses to continue rather than write journal text in plain form.
  cipherUnavailable,

  /// A plain database was found but could not be converted to an encrypted one.
  ///
  /// The plain file is left exactly as it was; nothing has been deleted.
  conversionFailed,

  /// The database file exists and the key exists, but the file will not open.
  ///
  /// Usually a corrupt file, or a file encrypted with a different key.
  openFailed,
}

/// Thrown when the vault cannot be opened. Shown to the user through
/// `lib/app/vault_unavailable_app.dart`.
///
/// Deliberately carries no path, no key material, and no raw database error
/// text — the message is a short fixed string per [kind].
class DatabaseOpenFailure implements Exception {
  const DatabaseOpenFailure(this.kind);

  final DatabaseOpenFailureKind kind;

  @override
  String toString() => 'DatabaseOpenFailure(${kind.name})';
}
