import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';

void main() {
  group('SharedMediaItem', () {
    test('serializes and deserializes correctly', () {
      final bytes = Uint8List.fromList(utf8.encode('test image content'));
      final item = SharedMediaItem(
        fileName: 'photo.jpg',
        mimeType: 'image/jpeg',
        bytes: bytes,
      );

      expect(item.isImage, isTrue);
      expect(item.isSealedFile, isFalse);

      final map = item.toMap();
      final restored = SharedMediaItem.fromMap(map);

      expect(restored.fileName, 'photo.jpg');
      expect(restored.mimeType, 'image/jpeg');
      expect(restored.bytes, bytes);
      expect(restored.isImage, isTrue);
    });

    test('detects sealed export and backup archives', () {
      final item1 = SharedMediaItem(
        fileName: 'backup.jvbk',
        mimeType: 'application/octet-stream',
        bytes: Uint8List(0),
      );
      final item2 = SharedMediaItem(
        fileName: 'export.jvenc',
        mimeType: 'application/octet-stream',
        bytes: Uint8List(0),
      );
      final item3 = SharedMediaItem(
        fileName: 'notes.txt',
        mimeType: 'text/plain',
        bytes: Uint8List(0),
      );

      expect(item1.isSealedFile, isTrue);
      expect(item2.isSealedFile, isTrue);
      expect(item3.isSealedFile, isFalse);
    });
  });

  group('SharedIntentPayload', () {
    test('deserializes text payload', () {
      final map = {
        'type': 'text',
        'text': 'Shared quote or URL: https://example.com',
        'subject': 'Daily Inspiration',
        'mediaItems': <Map<String, dynamic>>[],
      };

      final payload = SharedIntentPayload.fromMap(map);
      expect(payload.type, SharedPayloadType.text);
      expect(payload.text, 'Shared quote or URL: https://example.com');
      expect(payload.subject, 'Daily Inspiration');
      expect(payload.hasText, isTrue);
      expect(payload.hasMedia, isFalse);
      expect(payload.isSealedFile, isFalse);
    });

    test('deserializes media payload', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final map = {
        'type': 'media',
        'text': 'Look at this photo',
        'subject': null,
        'mediaItems': [
          {
            'fileName': 'capture.png',
            'mimeType': 'image/png',
            'bytesBase64': base64Encode(bytes),
          },
        ],
      };

      final payload = SharedIntentPayload.fromMap(map);
      expect(payload.type, SharedPayloadType.media);
      expect(payload.hasMedia, isTrue);
      expect(payload.mediaItems.length, 1);
      expect(payload.mediaItems.first.fileName, 'capture.png');
      expect(payload.mediaItems.first.bytes, bytes);
      expect(payload.mediaItems.first.isImage, isTrue);
    });

    test('detects sealed file payload', () {
      final map = {
        'type': 'sealedFile',
        'text': null,
        'subject': null,
        'mediaItems': [
          {
            'fileName': 'vault_backup.jvbk',
            'mimeType': 'application/octet-stream',
            'bytesBase64': base64Encode(Uint8List(16)),
          },
        ],
      };

      final payload = SharedIntentPayload.fromMap(map);
      expect(payload.type, SharedPayloadType.sealedFile);
      expect(payload.isSealedFile, isTrue);
    });
  });
}
