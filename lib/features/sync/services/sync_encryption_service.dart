import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Handles encryption and decryption of sync record payloads.
///
/// Uses AES-256-GCM with Argon2id key derivation — the same scheme as the
/// backup service — to ensure all data in transit is encrypted end-to-end.
/// The sync password is user-provided and never leaves the device.
class SyncEncryptionService {
  final AesGcm _algorithm = AesGcm.with256bits();

  final Argon2id _keyDerivation = Argon2id(
    parallelism: 1,
    memory: 65536,
    iterations: 3,
    hashLength: 32,
  );

  /// Derives a stable encryption key from the user's sync password and a
  /// device-bound salt.
  Future<SecretKey> deriveKey(String password, List<int> salt) async {
    return _keyDerivation.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  /// Encrypts a JSON-serialisable map into a Base64 string.
  ///
  /// The output format is: `base64([nonce_len(1)][nonce][mac(16)][ciphertext])`.
  Future<String> encryptRecord(
    Map<String, dynamic> data,
    SecretKey key,
  ) async {
    final plaintext = utf8.encode(jsonEncode(data));
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
    );

    final output = BytesBuilder();
    output.addByte(nonce.length);
    output.add(nonce);
    output.add(secretBox.mac.bytes);
    output.add(secretBox.cipherText);
    return base64Encode(output.toBytes());
  }

  /// Decrypts a Base64-encoded encrypted record back to a JSON map.
  Future<Map<String, dynamic>> decryptRecord(
    String encryptedBase64,
    SecretKey key,
  ) async {
    final data = base64Decode(encryptedBase64);
    final nonceLength = data[0];
    final nonce = data.sublist(1, 1 + nonceLength);
    final mac = Mac(data.sublist(1 + nonceLength, 1 + nonceLength + 16));
    final cipherText = data.sublist(1 + nonceLength + 16);

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final decrypted = await _algorithm.decrypt(secretBox, secretKey: key);
    return jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
  }

  /// Computes an encrypted checksum of the payload for integrity verification.
  Future<String> computeChecksum(List<String> encryptedRecords) async {
    final combined = encryptedRecords.join(':');
    final hash = await Sha256().hash(utf8.encode(combined));
    return base64Encode(Uint8List.fromList(hash.bytes));
  }
}
