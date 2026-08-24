import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as crypto;

import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';

/// Thrown when a scanned string is not a usable frame or decoding fails.
class AirqrFrameException implements Exception {
  final String message;
  const AirqrFrameException(this.message);

  @override
  String toString() => 'AirqrFrameException: $message';
}

/// The manifest frame: describes the transfer set and integrity hash.
class AirqrManifest {
  final int totalFrames;
  final String kind;
  final Uint8List salt;
  final String digest;
  final bool gzipped;
  final bool encrypted;

  const AirqrManifest({
    required this.totalFrames,
    required this.kind,
    required this.salt,
    required this.digest,
    required this.gzipped,
    required this.encrypted,
  });
}

/// One data frame carrying a chunk of the wire payload.
class AirqrDataFrame {
  final int index;
  final int totalFrames;
  final Uint8List bytes;

  const AirqrDataFrame({
    required this.index,
    required this.totalFrames,
    required this.bytes,
  });
}

/// A parsed frame (manifest or data frame).
class AirqrParsedFrame {
  final AirqrManifest? manifest;
  final AirqrDataFrame? data;

  const AirqrParsedFrame.manifest(AirqrManifest this.manifest) : data = null;
  const AirqrParsedFrame.data(AirqrDataFrame this.data) : manifest = null;

  bool get isManifest => manifest != null;
}

/// A complete encoded transfer ready to stream.
class AirqrEncoded {
  final String manifestFrame;
  final List<String> dataFrames;
  final int payloadBytes;
  final int wireBytes;

  const AirqrEncoded({
    required this.manifestFrame,
    required this.dataFrames,
    required this.payloadBytes,
    required this.wireBytes,
  });

  int get totalFrames => dataFrames.length;

  /// Ordered frame stream starting with manifest.
  List<String> get allFrames => [manifestFrame, ...dataFrames];
}

/// Core framing, compression, and encryption codec for AirQR.
class AirqrCodec {
  AirqrCodec._();

  static final _gcm = crypto.AesGcm.with256bits();

  /// Generates a random 16-character pairing code without ambiguous glyphs.
  static String generatePairingCode() {
    final rand = Random.secure();
    const chars = AirqrConstants.codeAlphabet;
    return List.generate(
      AirqrConstants.codeLength,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  /// Formats code as `XXXX-XXXX-XXXX-XXXX`.
  static String formatCode(String code) {
    final clean = code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (clean.length != AirqrConstants.codeLength) return clean;
    return '${clean.substring(0, 4)}-${clean.substring(4, 8)}-${clean.substring(8, 12)}-${clean.substring(12, 16)}';
  }

  /// Normalizes formatted code back to raw uppercase alphanumeric string.
  static String normalizeCode(String code) {
    return code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  }

  /// Derives an AES-256 key using PBKDF2-HMAC-SHA256 from [code] and [salt].
  static Future<crypto.SecretKey> deriveKey(String code, Uint8List salt) async {
    final pbkdf2 = crypto.Pbkdf2(
      macAlgorithm: crypto.Hmac.sha256(),
      iterations: AirqrConstants.pbkdf2Iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: crypto.SecretKey(utf8.encode(normalizeCode(code))),
      nonce: salt,
    );
  }

  /// Encodes [payload] into an [AirqrEncoded] frame sequence.
  static Future<AirqrEncoded> encode({
    required AirqrPayload payload,
    String? pairingCode,
    int chunkBytes = AirqrConstants.frameChunkBytes,
  }) async {
    final rawBytes = payload.toBytes();
    final payloadBytes = rawBytes.length;

    // 1. Calculate SHA-256 digest of plaintext
    final digestHex = sha256.convert(rawBytes).toString();

    // 2. Gzip compress
    final compressedBytes = gzip.encode(rawBytes);

    // 3. Encrypt if pairing code is provided
    Uint8List wireBytes;
    Uint8List salt = Uint8List(0);
    final isEncrypted = pairingCode != null && pairingCode.trim().isNotEmpty;

    if (isEncrypted) {
      final rand = Random.secure();
      salt = Uint8List.fromList(
        List.generate(AirqrConstants.saltBytes, (_) => rand.nextInt(256)),
      );
      final key = await deriveKey(pairingCode, salt);
      final nonce = List.generate(12, (_) => rand.nextInt(256));

      final secretBox = await _gcm.encrypt(
        compressedBytes,
        secretKey: key,
        nonce: nonce,
      );

      final combined = <int>[
        ...secretBox.nonce,
        ...secretBox.mac.bytes,
        ...secretBox.cipherText,
      ];
      wireBytes = Uint8List.fromList(combined);
    } else {
      wireBytes = Uint8List.fromList(compressedBytes);
    }

    // 4. Chunk into frames
    final chunks = <Uint8List>[];
    for (var i = 0; i < wireBytes.length; i += chunkBytes) {
      final end = (i + chunkBytes < wireBytes.length)
          ? i + chunkBytes
          : wireBytes.length;
      chunks.add(Uint8List.sublistView(wireBytes, i, end));
    }
    final totalFrames = chunks.length;

    // 5. Build manifest URI
    final manifestParams = <String, String>{
      AirqrConstants.keyVersion: '${AirqrConstants.protocolVersion}',
      AirqrConstants.keyTotal: '$totalFrames',
      AirqrConstants.keyKind: payload.kind,
      AirqrConstants.keyDigest: digestHex,
      AirqrConstants.keyGzip: '1',
      AirqrConstants.keyEncrypted: isEncrypted ? '1' : '0',
    };
    if (isEncrypted) {
      manifestParams[AirqrConstants.keySalt] = base64Url.encode(salt);
    }
    final manifestUri = Uri(
      scheme: AirqrConstants.scheme,
      host: AirqrConstants.hostManifest,
      queryParameters: manifestParams,
    ).toString();

    // 6. Build data frame URIs
    final dataFrames = <String>[];
    for (var i = 0; i < chunks.length; i++) {
      final frameUri = Uri(
        scheme: AirqrConstants.scheme,
        host: AirqrConstants.hostFrame,
        queryParameters: {
          AirqrConstants.keyVersion: '${AirqrConstants.protocolVersion}',
          AirqrConstants.keyIndex: '$i',
          AirqrConstants.keyTotal: '$totalFrames',
          AirqrConstants.keyData: base64Url.encode(chunks[i]),
        },
      ).toString();
      dataFrames.add(frameUri);
    }

    return AirqrEncoded(
      manifestFrame: manifestUri,
      dataFrames: dataFrames,
      payloadBytes: payloadBytes,
      wireBytes: wireBytes.length,
    );
  }

  /// Parses a raw scanned QR string into an [AirqrParsedFrame].
  static AirqrParsedFrame parseFrame(String raw) {
    if (raw.length > AirqrConstants.maxRawFrameLength) {
      throw const AirqrFrameException('Frame exceeds length limits.');
    }

    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != AirqrConstants.scheme) {
      throw const AirqrFrameException('Not an AirQR frame.');
    }

    final params = uri.queryParameters;
    final vStr = params[AirqrConstants.keyVersion];
    final v = int.tryParse(vStr ?? '');
    if (v == null || v != AirqrConstants.protocolVersion) {
      throw const AirqrFrameException('Unsupported AirQR version.');
    }

    if (uri.host == AirqrConstants.hostManifest) {
      final total = int.tryParse(params[AirqrConstants.keyTotal] ?? '');
      final kind =
          params[AirqrConstants.keyKind] ?? AirqrConstants.kindSnapshot;
      final digest = params[AirqrConstants.keyDigest] ?? '';
      final isGzip = params[AirqrConstants.keyGzip] == '1';
      final isEncrypted = params[AirqrConstants.keyEncrypted] == '1';
      final saltStr = params[AirqrConstants.keySalt];
      final salt = saltStr != null && saltStr.isNotEmpty
          ? Uint8List.fromList(base64Url.decode(saltStr))
          : Uint8List(0);

      if (total == null || total < 1 || total > AirqrConstants.maxFrames) {
        throw const AirqrFrameException('Invalid frame count in manifest.');
      }
      if (digest.length != 64) {
        throw const AirqrFrameException('Invalid digest in manifest.');
      }

      return AirqrParsedFrame.manifest(
        AirqrManifest(
          totalFrames: total,
          kind: kind,
          salt: salt,
          digest: digest,
          gzipped: isGzip,
          encrypted: isEncrypted,
        ),
      );
    } else if (uri.host == AirqrConstants.hostFrame) {
      final index = int.tryParse(params[AirqrConstants.keyIndex] ?? '');
      final total = int.tryParse(params[AirqrConstants.keyTotal] ?? '');
      final dataB64 = params[AirqrConstants.keyData];

      if (index == null || total == null || dataB64 == null) {
        throw const AirqrFrameException('Missing frame parameters.');
      }
      if (index < 0 || index >= total || total > AirqrConstants.maxFrames) {
        throw const AirqrFrameException('Frame index out of bounds.');
      }

      final bytes = Uint8List.fromList(base64Url.decode(dataB64));
      return AirqrParsedFrame.data(
        AirqrDataFrame(index: index, totalFrames: total, bytes: bytes),
      );
    } else {
      throw const AirqrFrameException('Unknown frame host.');
    }
  }

  /// Reassembles, decrypts, decompresses, and validates a complete set of chunks.
  static Future<AirqrPayload> decodePayload({
    required AirqrManifest manifest,
    required List<Uint8List?> chunks,
    String? pairingCode,
  }) async {
    if (chunks.length != manifest.totalFrames || chunks.any((c) => c == null)) {
      throw const AirqrFrameException('Cannot decode incomplete frames.');
    }

    // 1. Join all chunk bytes
    final builder = BytesBuilder(copy: false);
    for (final c in chunks) {
      builder.add(c!);
    }
    final wireBytes = builder.takeBytes();

    // 2. Decrypt if sealed
    List<int> unsealedBytes;
    if (manifest.encrypted) {
      if (pairingCode == null || pairingCode.trim().isEmpty) {
        throw const AirqrFrameException('Pairing code is required.');
      }
      if (wireBytes.length < 28) {
        // 12 bytes nonce + 16 bytes MAC
        throw const AirqrFrameException('Ciphertext is too short.');
      }

      final key = await deriveKey(pairingCode, manifest.salt);
      final nonce = wireBytes.sublist(0, 12);
      final mac = crypto.Mac(wireBytes.sublist(12, 28));
      final cipherText = wireBytes.sublist(28);

      final box = crypto.SecretBox(cipherText, nonce: nonce, mac: mac);

      try {
        unsealedBytes = await _gcm.decrypt(box, secretKey: key);
      } catch (_) {
        throw const AirqrFrameException(
          'Incorrect pairing code or corrupt data.',
        );
      }
    } else {
      unsealedBytes = wireBytes;
    }

    // 3. Decompress if gzipped
    List<int> decompressed;
    if (manifest.gzipped) {
      try {
        decompressed = gzip.decode(unsealedBytes);
      } catch (_) {
        throw const AirqrFrameException('Decompression failed.');
      }
    } else {
      decompressed = unsealedBytes;
    }

    // 4. Verify SHA-256 digest
    final computedDigest = sha256.convert(decompressed).toString();
    if (computedDigest.toLowerCase() != manifest.digest.toLowerCase()) {
      throw const AirqrFrameException(
        'Integrity check failed: digest mismatch.',
      );
    }

    // 5. Parse payload
    return AirqrPayload.fromBytes(decompressed);
  }
}
