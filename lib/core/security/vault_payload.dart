/// A tiny header that travels **inside** the sealed bytes.
///
/// Layer: core. Pure Dart — bytes and JSON, nothing else.
///
/// [VaultEnvelope] says how a file was sealed but not what is inside it. An
/// encrypted export has to carry its own file name and format so it can be
/// written back out under the right name later. That name must not be readable
/// from outside the encryption — a file called `Therapy notes.md` names the
/// very thing the password is hiding — so the header is sealed with the
/// payload, not written beside it.
///
/// Shape:
/// ```
/// ['J','V','P','1'][headerLen:2 big-endian][header JSON utf8][file bytes]
/// ```
///
/// Payloads with no header — every backup archive, which seals a plain zip —
/// read back as raw bytes with a null [VaultPayload.header]. So nothing
/// written before this existed has to change.
library;

import 'dart:convert';
import 'dart:typed_data';

/// Magic for a payload that carries a header: `JVP1`.
const List<int> vaultPayloadMagic = [0x4a, 0x56, 0x50, 0x31];

/// Extension given to a sealed file. Chosen so nothing else on the phone
/// claims it, and so the file cannot be opened by mistake in a text editor.
const String vaultSealedFileExtension = 'jvenc';

/// The `kind` an export file writes into its header.
const String vaultPayloadKindExport = 'export';

/// The largest header we will read. A real one is a few hundred bytes; the
/// cap stops a damaged file from claiming a huge length.
const int _maxHeaderLength = 8192;

/// What a sealed payload says about itself.
class VaultPayloadHeader {
  const VaultPayloadHeader({
    required this.kind,
    required this.fileName,
    this.mimeType,
    this.createdAt,
  });

  factory VaultPayloadHeader.fromJson(Map<String, dynamic> json) {
    return VaultPayloadHeader(
      kind: json['kind'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      mimeType: json['mimeType'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// What the payload is. Only [vaultPayloadKindExport] exists today; the
  /// field is here so a future kind does not need a new format.
  final String kind;

  /// The name the file had before it was sealed, extension included.
  final String fileName;

  final String? mimeType;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'fileName': fileName,
    if (mimeType != null) 'mimeType': mimeType,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}

/// A payload read back out of a sealed file.
class VaultPayload {
  const VaultPayload({required this.bytes, this.header});

  /// The file itself.
  final Uint8List bytes;

  /// Null when the payload carried no header — a backup archive, or anything
  /// sealed before headers existed.
  final VaultPayloadHeader? header;
}

/// Puts [header] in front of [bytes], ready to be sealed.
Uint8List wrapVaultPayload({
  required List<int> bytes,
  required VaultPayloadHeader header,
}) {
  final headerBytes = utf8.encode(jsonEncode(header.toJson()));
  final out = BytesBuilder();
  out.add(vaultPayloadMagic);
  out.addByte((headerBytes.length >> 8) & 0xff);
  out.addByte(headerBytes.length & 0xff);
  out.add(headerBytes);
  out.add(bytes);
  return out.toBytes();
}

/// Reads a payload back.
///
/// Bytes that do not start with `JVP1`, and bytes whose header cannot be read,
/// come back as a payload with a null header and the original bytes untouched.
/// That is deliberate: a readable file is better than an error, and the
/// envelope has already proved the bytes were not tampered with.
VaultPayload unwrapVaultPayload(List<int> bytes) {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

  const prefixLength = 6; // magic(4) + headerLen(2)
  if (data.length < prefixLength || !_startsWithMagic(data)) {
    return VaultPayload(bytes: data);
  }

  final headerLength = (data[4] << 8) | data[5];
  if (headerLength <= 0 ||
      headerLength > _maxHeaderLength ||
      prefixLength + headerLength > data.length) {
    return VaultPayload(bytes: data);
  }

  try {
    final json =
        jsonDecode(
              utf8.decode(
                Uint8List.sublistView(
                  data,
                  prefixLength,
                  prefixLength + headerLength,
                ),
              ),
            )
            as Map<String, dynamic>;
    return VaultPayload(
      bytes: Uint8List.sublistView(data, prefixLength + headerLength),
      header: VaultPayloadHeader.fromJson(json),
    );
  } catch (_) {
    return VaultPayload(bytes: data);
  }
}

bool _startsWithMagic(Uint8List data) {
  for (var i = 0; i < vaultPayloadMagic.length; i++) {
    if (data[i] != vaultPayloadMagic[i]) return false;
  }
  return true;
}
