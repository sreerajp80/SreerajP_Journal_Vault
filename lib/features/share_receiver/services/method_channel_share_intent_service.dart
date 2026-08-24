import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/share_intent_service.dart';

class MethodChannelShareIntentService implements ShareIntentService {
  MethodChannelShareIntentService({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('sreerajp.journal_vault/share_intent') {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  final MethodChannel _channel;
  final _streamController = StreamController<SharedIntentPayload>.broadcast();

  @override
  Stream<SharedIntentPayload> get sharedPayloadStream =>
      _streamController.stream;

  @override
  Future<SharedIntentPayload?> getInitialSharedPayload() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('getInitialShare');
      if (raw is Map) {
        return SharedIntentPayload.fromMap(raw);
      }
      return null;
    } catch (e) {
      AppLogger.warning('Failed to retrieve initial shared payload', error: e);
      return null;
    }
  }

  @override
  Future<void> clearSharedPayload() async {
    try {
      await _channel.invokeMethod<void>('clearPendingShare');
    } catch (e) {
      AppLogger.warning('Failed to clear pending shared payload', error: e);
    }
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onShareReceived') {
      try {
        final raw = call.arguments;
        if (raw is Map) {
          final payload = SharedIntentPayload.fromMap(raw);
          _streamController.add(payload);
        }
      } catch (e) {
        AppLogger.warning(
          'Failed to parse incoming share intent payload',
          error: e,
        );
      }
    }
  }

  @override
  void dispose() {
    _streamController.close();
  }
}
