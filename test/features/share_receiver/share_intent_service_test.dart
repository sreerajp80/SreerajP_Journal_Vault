import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/method_channel_share_intent_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'sreerajp.journal_vault/share_intent';
  late List<MethodCall> methodCalls;
  Map<String, dynamic>? initialShareResponse;

  setUp(() {
    methodCalls = [];
    initialShareResponse = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          call,
        ) async {
          methodCalls.add(call);
          if (call.method == 'getInitialShare') {
            return initialShareResponse;
          }
          if (call.method == 'clearPendingShare') {
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), null);
  });

  test('getInitialSharedPayload returns parsed payload when present', () async {
    final bytes = Uint8List.fromList([10, 20, 30]);
    initialShareResponse = {
      'type': 'media',
      'text': 'Shared link',
      'subject': 'Web Article',
      'mediaItems': [
        {
          'fileName': 'article.png',
          'mimeType': 'image/png',
          'bytesBase64': base64Encode(bytes),
        },
      ],
    };

    final service = MethodChannelShareIntentService();
    final result = await service.getInitialSharedPayload();

    expect(result, isNotNull);
    expect(result!.type, SharedPayloadType.media);
    expect(result.text, 'Shared link');
    expect(result.subject, 'Web Article');
    expect(result.mediaItems.length, 1);
    expect(result.mediaItems.first.fileName, 'article.png');
    expect(result.mediaItems.first.bytes, bytes);

    expect(methodCalls.any((c) => c.method == 'getInitialShare'), isTrue);
    service.dispose();
  });

  test('clearSharedPayload invokes clearPendingShare on channel', () async {
    final service = MethodChannelShareIntentService();
    await service.clearSharedPayload();

    expect(methodCalls.any((c) => c.method == 'clearPendingShare'), isTrue);
    service.dispose();
  });
}
