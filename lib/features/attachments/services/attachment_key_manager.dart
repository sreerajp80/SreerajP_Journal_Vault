import 'package:cryptography/cryptography.dart';

/// Holds a resolved encryption key and its reference identifier.
class AttachmentKeyMaterial {
  const AttachmentKeyMaterial({
    required this.keyReference,
    required this.secretKey,
  });

  final String keyReference;
  final SecretKey secretKey;
}

/// Thrown when a key for the given [keyReference] cannot be found.
class AttachmentKeyUnavailableException implements Exception {
  const AttachmentKeyUnavailableException(this.keyReference);

  final String keyReference;

  @override
  String toString() => 'AttachmentKeyUnavailableException($keyReference)';
}

/// Manages AES encryption keys used for attachment storage.
abstract class AttachmentKeyManager {
  /// Returns (or creates) the active encryption key material.
  Future<AttachmentKeyMaterial> getOrCreateActiveKey();

  /// Loads the key for a previously stored [keyReference].
  ///
  /// Throws [AttachmentKeyUnavailableException] if not found.
  Future<SecretKey> loadKey(String keyReference);
}
