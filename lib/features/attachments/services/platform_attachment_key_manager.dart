import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';

import 'package:sreerajp_journal_vault/core/security/attachment_storage_constants.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_key_manager.dart';

/// [AttachmentKeyManager] backed by the Android Keystore via MethodChannel.
///
/// Keys are wrapped by an AES-256-GCM key stored in the Android Keystore and
/// cached in SharedPreferences on the platform side. The Dart layer only
/// ever sees the raw key bytes for the duration of an encrypt/decrypt call.
class PlatformAttachmentKeyManager implements AttachmentKeyManager {
  static const _channel = MethodChannel('sreerajp.journal_vault/attachment_keys');

  @override
  Future<AttachmentKeyMaterial> getOrCreateActiveKey() async {
    final encoded = await _channel.invokeMethod<String>(
      'getAttachmentKey',
      {
        'keyReference': activeAttachmentKeyReference,
        'createIfMissing': true,
      },
    );
    if (encoded == null) {
      throw AttachmentKeyUnavailableException(activeAttachmentKeyReference);
    }
    final keyBytes = base64.decode(encoded);
    return AttachmentKeyMaterial(
      keyReference: activeAttachmentKeyReference,
      secretKey: SecretKey(keyBytes),
    );
  }

  @override
  Future<SecretKey> loadKey(String keyReference) async {
    final encoded = await _channel.invokeMethod<String>(
      'getAttachmentKey',
      {
        'keyReference': keyReference,
        'createIfMissing': false,
      },
    );
    if (encoded == null) {
      throw AttachmentKeyUnavailableException(keyReference);
    }
    return SecretKey(base64.decode(encoded));
  }
}
