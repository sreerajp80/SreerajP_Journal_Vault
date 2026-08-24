import 'dart:convert';
import 'dart:typed_data';

/// The category of content received from an inbound Android Intent.
enum SharedPayloadType {
  /// Plain text, URL links, or formatted text notes.
  text,

  /// One or more images, voice files, or general documents.
  media,

  /// Sealed password-protected archive (.jvenc or .jvbk).
  sealedFile,
}

/// A media file or document received via an Android share or view intent.
class SharedMediaItem {
  const SharedMediaItem({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  bool get isImage => mimeType.startsWith('image/');
  bool get isSealedFile {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jvenc') || lower.endsWith('.jvbk');
  }

  factory SharedMediaItem.fromMap(Map<dynamic, dynamic> map) {
    final fileName = (map['fileName'] as String?) ?? 'shared_attachment';
    final mimeType = (map['mimeType'] as String?) ?? 'application/octet-stream';
    final bytesBase64 = map['bytesBase64'] as String?;
    final bytes = bytesBase64 != null
        ? base64Decode(bytesBase64)
        : Uint8List(0);

    return SharedMediaItem(
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  Map<String, dynamic> toMap() => {
    'fileName': fileName,
    'mimeType': mimeType,
    'bytesBase64': base64Encode(bytes),
  };
}

/// An inbound payload received from another app via Android's share sheet or view intent.
class SharedIntentPayload {
  const SharedIntentPayload({
    required this.type,
    this.text,
    this.subject,
    this.mediaItems = const [],
  });

  final SharedPayloadType type;
  final String? text;
  final String? subject;
  final List<SharedMediaItem> mediaItems;

  bool get hasMedia => mediaItems.isNotEmpty;
  bool get hasText => text != null && text!.trim().isNotEmpty;
  bool get isSealedFile =>
      type == SharedPayloadType.sealedFile ||
      (mediaItems.isNotEmpty && mediaItems.any((m) => m.isSealedFile));

  factory SharedIntentPayload.fromMap(Map<dynamic, dynamic> map) {
    final typeStr = map['type'] as String?;
    final type = switch (typeStr) {
      'sealedFile' => SharedPayloadType.sealedFile,
      'media' => SharedPayloadType.media,
      _ => SharedPayloadType.text,
    };

    final text = map['text'] as String?;
    final subject = map['subject'] as String?;
    final rawMediaList = (map['mediaItems'] as List<dynamic>?) ?? [];
    final mediaItems = rawMediaList
        .whereType<Map<dynamic, dynamic>>()
        .map(SharedMediaItem.fromMap)
        .toList();

    return SharedIntentPayload(
      type: type,
      text: text,
      subject: subject,
      mediaItems: mediaItems,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'text': text,
    'subject': subject,
    'mediaItems': mediaItems.map((m) => m.toMap()).toList(),
  };
}
