/// The one password-sealed file format this app writes.
///
/// Layer: core. Knows bytes and crypto only — no database, no file system, no
/// widgets, no user-visible wording.
///
/// It was written for the backup archive (A4.1) and now seals the export file
/// as well (A4.2), so the app has **one** versioned envelope instead of a
/// second, weaker one per feature.
///
/// Two on-disk shapes exist, and both can be read:
///
/// **Version 1** (every backup written before A4.1):
/// ```
/// [nonceLen:1][nonce][mac:16][ciphertext]
/// ```
/// The key came from Argon2id with a **fixed** salt, so the same password
/// produced the same key on every device and in every file. That is the
/// weakness version 2 removes; version 1 stays readable so no old backup is
/// orphaned. Nothing writes it any more.
///
/// **Version 2** (written now) — self-describing, with a random salt:
/// ```
/// ['J','V','B'][formatVersion:1][kdfId:1][memoryKib:4][iterations:1]
/// [parallelism:1][saltLen:1][salt][nonceLen:1][nonce][mac:16][ciphertext]
/// ```
/// The cost settings are written into the file, so a later build can raise
/// them without orphaning anything sealed today.
///
/// **Why Argon2id and not the PBKDF2 the sibling apps use.** What the shared
/// idea list asked for was an envelope that is versioned and self-describing.
/// This one is both, and it also records the KDF and its cost — which a
/// `v1:<salt>:<iv>:<ciphertext>` string cannot. Argon2id is memory-hard;
/// PBKDF2 is not. See `docs/security.md`.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// Envelope shape written by this build.
///
/// Deliberately **not** the same number as the backup archive's
/// `backupFormatVersion`: one says how the file is sealed, the other says what
/// the sealed bytes contain. They happen to both be 2 today.
const int vaultEnvelopeVersion = 2;

/// Shortest password accepted for a sealed file. Matches `sreerajp_todo`.
const int minimumVaultPasswordLength = 8;

// Detail codes carried on [VaultCorruptedException]. The strings are kept
// from the backup format so old log lines still read the same.

/// The password did not open the file.
const String vaultWrongPasswordDetails = 'wrong_passphrase';

/// The bytes are not a sealed file, or they are damaged.
const String vaultInvalidDataDetails = 'invalid_archive';

/// Thrown when a password is empty or shorter than
/// [minimumVaultPasswordLength].
class VaultPasswordException implements Exception {
  const VaultPasswordException([
    this.message =
        'The password must be at least '
        '$minimumVaultPasswordLength characters.',
  ]);

  final String message;

  @override
  String toString() => 'VaultPasswordException: $message';
}

/// Thrown when a file is not a sealed file, is damaged, or the password is
/// wrong.
///
/// A wrong password and a tampered file are the same event to AES-GCM — the
/// tag check fails either way — so [details] separates them only as far as we
/// honestly can.
class VaultCorruptedException implements Exception {
  const VaultCorruptedException([
    this.details,
    this.message = 'The file is damaged.',
  ]);

  final String? details;
  final String message;

  bool get isWrongPassword => details == vaultWrongPasswordDetails;

  @override
  String toString() => details == null
      ? 'VaultCorruptedException: $message'
      : 'VaultCorruptedException: $message ($details)';
}

/// Thrown when a sealed file was written by a newer envelope than this build
/// understands.
class VaultVersionTooNewException implements Exception {
  const VaultVersionTooNewException(this.fileVersion, this.supportedVersion);

  final int fileVersion;
  final int supportedVersion;

  @override
  String toString() =>
      'VaultVersionTooNewException: the file uses envelope version '
      '$fileVersion; this build understands $supportedVersion.';
}

/// Rejects a password that is empty or shorter than
/// [minimumVaultPasswordLength].
void validateVaultPassword(String password) {
  if (password.length < minimumVaultPasswordLength) {
    throw const VaultPasswordException();
  }
}

/// Argon2id settings used to turn a password into a key.
///
/// The version 2 envelope writes these numbers into the file, so a future
/// build can raise them without orphaning today's files.
class VaultKdfParameters {
  const VaultKdfParameters({
    this.memoryKib = 65536,
    this.iterations = 3,
    this.parallelism = 1,
  });

  final int memoryKib;
  final int iterations;
  final int parallelism;

  Argon2id toAlgorithm() => Argon2id(
    parallelism: parallelism,
    memory: memoryKib,
    iterations: iterations,
    hashLength: 32,
  );
}

/// The settings the version 1 envelope used. **Never change these** — every
/// backup written before envelope version 2 was derived with exactly these
/// numbers, and changing them would make those files unreadable.
const VaultKdfParameters legacyVaultKdfParameters = VaultKdfParameters();

/// Seals and opens password-protected files.
class VaultEnvelope {
  VaultEnvelope({
    this.kdf = const VaultKdfParameters(),
    this.legacyKdf = legacyVaultKdfParameters,
    Random? random,
  }) : _random = random ?? Random.secure();

  /// Settings used when sealing new bytes.
  final VaultKdfParameters kdf;

  /// Settings used when opening a version 1 file. Overridable only so tests
  /// can run cheaply; production must leave it at the historical values.
  final VaultKdfParameters legacyKdf;

  final Random _random;

  static const List<int> _magic = [0x4a, 0x56, 0x42]; // 'JVB'
  static const int _kdfArgon2id = 1;
  static const int _saltLength = 16;
  static const int _macLength = 16;

  /// The fixed salt version 1 used: the bytes 0 to 15 in order.
  static final Uint8List _legacySalt = Uint8List.fromList(
    List<int>.generate(16, (i) => i),
  );

  final AesGcm _algorithm = AesGcm.with256bits();

  /// Which envelope wrote [bytes]: 2 for the current shape, 1 otherwise.
  ///
  /// The two cannot be confused: a version 1 file starts with a nonce length
  /// (12), never with the letter `J`.
  static int detectVersion(List<int> bytes) {
    if (bytes.length > _magic.length &&
        bytes[0] == _magic[0] &&
        bytes[1] == _magic[1] &&
        bytes[2] == _magic[2]) {
      return bytes[3];
    }
    return 1;
  }

  /// True when [bytes] were sealed by the current envelope.
  ///
  /// Used to tell a sealed file from a plain one before asking for a
  /// password — the same auto-detection `sreerajp_youtube_shortcut` does on
  /// import.
  static bool isSealed(List<int> bytes) =>
      bytes.length > _magic.length &&
      bytes[0] == _magic[0] &&
      bytes[1] == _magic[1] &&
      bytes[2] == _magic[2];

  /// Encrypts [plainBytes] under [password] using the current envelope.
  Future<Uint8List> seal({
    required List<int> plainBytes,
    required String password,
  }) async {
    validateVaultPassword(password);

    final salt = _randomBytes(_saltLength);
    final secretKey = await _deriveKey(password, salt, kdf);
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      plainBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    final out = BytesBuilder();
    out.add(_magic);
    out.addByte(vaultEnvelopeVersion);
    out.addByte(_kdfArgon2id);
    out.add(_uint32(kdf.memoryKib));
    out.addByte(kdf.iterations);
    out.addByte(kdf.parallelism);
    out.addByte(salt.length);
    out.add(salt);
    out.addByte(nonce.length);
    out.add(nonce);
    out.add(secretBox.mac.bytes);
    out.add(secretBox.cipherText);
    return out.toBytes();
  }

  /// Decrypts [sealedBytes] under [password], accepting either envelope.
  ///
  /// Throws [VaultCorruptedException] with [vaultWrongPasswordDetails] when
  /// the tag check fails — a wrong password and a tampered file look identical
  /// here — or [vaultInvalidDataDetails] when the bytes are not a sealed file
  /// at all.
  Future<Uint8List> open({
    required List<int> sealedBytes,
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const VaultCorruptedException(vaultWrongPasswordDetails);
    }
    final bytes = Uint8List.fromList(sealedBytes);
    return detectVersion(bytes) >= 2
        ? _openV2(bytes, password)
        : _openLegacy(bytes, password);
  }

  /// Writes a version 1 file. Exists so tests can prove old backups still
  /// open; nothing in the app calls it.
  @visibleForTesting
  Future<Uint8List> sealLegacyV1({
    required List<int> plainBytes,
    required String password,
  }) async {
    final secretKey = await _deriveKey(password, _legacySalt, legacyKdf);
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      plainBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    final out = BytesBuilder();
    out.addByte(nonce.length);
    out.add(nonce);
    out.add(secretBox.mac.bytes);
    out.add(secretBox.cipherText);
    return out.toBytes();
  }

  Future<Uint8List> _openV2(Uint8List bytes, String password) async {
    // magic(3) + version(1) + kdfId(1) + memory(4) + iterations(1)
    // + parallelism(1) + saltLen(1) = 12 bytes of header before the salt.
    const headerLength = 12;
    if (bytes.length < headerLength) {
      throw const VaultCorruptedException(vaultInvalidDataDetails);
    }

    final envelopeVersion = bytes[3];
    if (envelopeVersion > vaultEnvelopeVersion) {
      throw VaultVersionTooNewException(envelopeVersion, vaultEnvelopeVersion);
    }
    if (bytes[4] != _kdfArgon2id) {
      throw const VaultCorruptedException(vaultInvalidDataDetails);
    }

    // The file carries the settings it was written with, so raising the
    // defaults later cannot orphan it.
    final fileKdf = VaultKdfParameters(
      memoryKib: _readUint32(bytes, 5),
      iterations: bytes[9],
      parallelism: bytes[10],
    );
    final saltLength = bytes[11];

    var offset = headerLength;
    final salt = _slice(bytes, offset, saltLength);
    offset += saltLength;

    if (offset >= bytes.length) {
      throw const VaultCorruptedException(vaultInvalidDataDetails);
    }
    final nonceLength = bytes[offset];
    offset += 1;

    final nonce = _slice(bytes, offset, nonceLength);
    offset += nonceLength;

    final mac = _slice(bytes, offset, _macLength);
    offset += _macLength;

    if (offset > bytes.length) {
      throw const VaultCorruptedException(vaultInvalidDataDetails);
    }
    final cipherText = bytes.sublist(offset);

    return _decrypt(
      cipherText: cipherText,
      nonce: nonce,
      mac: mac,
      password: password,
      salt: salt,
      kdf: fileKdf,
    );
  }

  Future<Uint8List> _openLegacy(Uint8List bytes, String password) async {
    if (bytes.isEmpty) {
      throw const VaultCorruptedException(vaultInvalidDataDetails);
    }
    final nonceLength = bytes[0];
    if (nonceLength == 0 || bytes.length < 1 + nonceLength + _macLength) {
      throw const VaultCorruptedException(vaultInvalidDataDetails);
    }

    final nonce = _slice(bytes, 1, nonceLength);
    final mac = _slice(bytes, 1 + nonceLength, _macLength);
    final cipherText = bytes.sublist(1 + nonceLength + _macLength);

    return _decrypt(
      cipherText: cipherText,
      nonce: nonce,
      mac: mac,
      password: password,
      salt: _legacySalt,
      kdf: legacyKdf,
    );
  }

  Future<Uint8List> _decrypt({
    required Uint8List cipherText,
    required Uint8List nonce,
    required Uint8List mac,
    required String password,
    required Uint8List salt,
    required VaultKdfParameters kdf,
  }) async {
    final secretKey = await _deriveKey(password, salt, kdf);
    try {
      final clear = await _algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: secretKey,
      );
      return Uint8List.fromList(clear);
    } catch (_) {
      // AES-GCM cannot tell a wrong password from a damaged file.
      throw const VaultCorruptedException(vaultWrongPasswordDetails);
    }
  }

  Future<SecretKey> _deriveKey(
    String password,
    Uint8List salt,
    VaultKdfParameters kdf,
  ) {
    return kdf.toAlgorithm().deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  static Uint8List _slice(Uint8List bytes, int start, int length) {
    if (start < 0 || length < 0 || start + length > bytes.length) {
      throw const VaultCorruptedException(vaultInvalidDataDetails);
    }
    return Uint8List.sublistView(bytes, start, start + length);
  }

  static List<int> _uint32(int value) => [
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];

  static int _readUint32(Uint8List bytes, int offset) =>
      (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}
