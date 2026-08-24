import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_constants.dart';

/// Thrown when a wire message cannot be decrypted or is malformed.
class WifiSyncCryptoException implements Exception {
  final String message;
  const WifiSyncCryptoException(this.message);
  @override
  String toString() => 'WifiSyncCryptoException: $message';
}

/// A pairing target parsed from a QR (or built for one).
class QrPairing {
  final String host;
  final int port;
  final String code;
  const QrPairing({required this.host, required this.port, required this.code});
}

/// Result of parsing a scanned QR code.
class QrParseResult {
  final QrPairing? pairing;
  final String? error;
  const QrParseResult.ok(this.pairing) : error = null;
  const QrParseResult.fail(this.error) : pairing = null;
  bool get isOk => pairing != null;
}

/// Pure crypto and codec helpers for peer-to-peer Wi-Fi sync.
class WifiSyncCrypto {
  WifiSyncCrypto._();

  static final Random _secure = Random.secure();
  static final AesGcm _aesGcm = AesGcm.with256bits();
  static final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: WifiSyncConstants.pbkdf2Iterations,
    bits: WifiSyncConstants.keyLengthBytes * 8,
  );

  /// Generates [n] cryptographically secure random bytes.
  static Uint8List randomBytes(int n) {
    final out = Uint8List(n);
    for (var i = 0; i < n; i++) {
      out[i] = _secure.nextInt(256);
    }
    return out;
  }

  /// Generates a fresh 16-character pairing code without ambiguous glyphs.
  static String generatePairingCode() {
    const alphabet = WifiSyncConstants.codeAlphabet;
    const n = alphabet.length;
    const limit = 256 - (256 % n);
    final buf = StringBuffer();
    while (buf.length < WifiSyncConstants.codeLength) {
      final b = _secure.nextInt(256);
      if (b >= limit) continue;
      buf.write(alphabet[b % n]);
    }
    return buf.toString();
  }

  /// Normalizes a typed or scanned pairing code.
  static String normalizeCode(String raw) {
    return raw.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
  }

  /// Formats the pairing code into human-readable groups (e.g. `ABCD-EFGH-JKMN-PQRS`).
  static String formatCode(String code) {
    const g = WifiSyncConstants.codeDisplayGroup;
    final parts = <String>[];
    for (var i = 0; i < code.length; i += g) {
      parts.add(code.substring(i, i + g > code.length ? code.length : i + g));
    }
    return parts.join('-');
  }

  /// Checks if [code] is a valid pairing code.
  static bool isValidCode(String code) {
    final clean = normalizeCode(code);
    if (clean.length != WifiSyncConstants.codeLength) return false;
    for (final ch in clean.split('')) {
      if (!WifiSyncConstants.codeAlphabet.contains(ch)) return false;
    }
    return true;
  }

  /// Derives an AES-256 key from [code] and [salt] using PBKDF2-HMAC-SHA256.
  static Future<SecretKey> deriveKey(String code, List<int> salt) async {
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(normalizeCode(code))),
      nonce: salt,
    );
  }

  /// Seals [plaintext] under [key] using AES-256-GCM and returns a base64 string.
  static Future<String> encryptWire(SecretKey key, String plaintext) async {
    final bytes = utf8.encode(plaintext);
    final nonce = _aesGcm.newNonce();
    final box = await _aesGcm.encrypt(bytes, secretKey: key, nonce: nonce);

    final out = BytesBuilder(copy: false)
      ..addByte(nonce.length)
      ..add(nonce)
      ..add(box.mac.bytes)
      ..add(box.cipherText);

    return base64.encode(out.toBytes());
  }

  /// Decrypts a base64 wire line produced by [encryptWire].
  static Future<String> decryptWire(SecretKey key, String wire) async {
    late final Uint8List raw;
    try {
      raw = base64.decode(wire.trim());
    } catch (_) {
      throw const WifiSyncCryptoException('malformed wire line');
    }

    if (raw.length <= 1 + 16) {
      throw const WifiSyncCryptoException('wire line too short');
    }

    final nonceLen = raw[0];
    if (raw.length <= 1 + nonceLen + 16) {
      throw const WifiSyncCryptoException('wire line too short for nonce/mac');
    }

    final nonce = raw.sublist(1, 1 + nonceLen);
    final mac = Mac(raw.sublist(1 + nonceLen, 1 + nonceLen + 16));
    final cipherText = raw.sublist(1 + nonceLen + 16);

    try {
      final box = SecretBox(cipherText, nonce: nonce, mac: mac);
      final decrypted = await _aesGcm.decrypt(box, secretKey: key);
      return utf8.decode(decrypted);
    } catch (_) {
      throw const WifiSyncCryptoException('decryption failed (wrong code?)');
    }
  }

  /// Builds the pairing QR URI.
  static String buildQrUri(QrPairing p) {
    final uri = Uri(
      scheme: WifiSyncConstants.qrScheme,
      host: WifiSyncConstants.qrHost,
      queryParameters: {
        'v': WifiSyncConstants.protocolVersion.toString(),
        'h': p.host,
        'p': p.port.toString(),
        'c': p.code,
      },
    );
    return uri.toString();
  }

  /// Parses a scanned QR URI string strictly.
  static QrParseResult parseQrUri(String raw) {
    Uri uri;
    try {
      uri = Uri.parse(raw.trim());
    } catch (_) {
      return const QrParseResult.fail('This is not a valid pairing code.');
    }
    if (uri.scheme != WifiSyncConstants.qrScheme ||
        uri.host != WifiSyncConstants.qrHost) {
      return const QrParseResult.fail('This QR is not from this app.');
    }
    final v = int.tryParse(uri.queryParameters['v'] ?? '');
    if (v != WifiSyncConstants.protocolVersion) {
      return const QrParseResult.fail(
        'This pairing code is a different version.',
      );
    }
    final host = uri.queryParameters['h'];
    final port = int.tryParse(uri.queryParameters['p'] ?? '');
    final code = uri.queryParameters['c'];
    if (host == null || host.isEmpty) {
      return const QrParseResult.fail(
        'The pairing code is missing the address.',
      );
    }
    if (port == null || port < 1 || port > 65535) {
      return const QrParseResult.fail('The pairing code has a bad port.');
    }
    if (code == null || !isValidCode(code)) {
      return const QrParseResult.fail('The pairing code is malformed.');
    }
    return QrParseResult.ok(
      QrPairing(host: host, port: port, code: normalizeCode(code)),
    );
  }
}
