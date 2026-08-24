import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/method_channel_share_intent_service.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/share_intent_service.dart';

final shareIntentServiceProvider = Provider<ShareIntentService>((ref) {
  final service = MethodChannelShareIntentService();
  ref.onDispose(service.dispose);
  return service;
});

class PendingSharePayloadNotifier extends Notifier<SharedIntentPayload?> {
  StreamSubscription<SharedIntentPayload>? _sub;

  @override
  SharedIntentPayload? build() {
    final service = ref.watch(shareIntentServiceProvider);

    // Initial payload check
    service.getInitialSharedPayload().then((payload) {
      if (payload != null && state == null) {
        state = payload;
      }
    });

    _sub?.cancel();
    _sub = service.sharedPayloadStream.listen((payload) {
      state = payload;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return null;
  }

  void setPayload(SharedIntentPayload? payload) {
    state = payload;
  }

  void consumePayload() {
    state = null;
    ref.read(shareIntentServiceProvider).clearSharedPayload();
  }
}

final pendingSharePayloadProvider =
    NotifierProvider<PendingSharePayloadNotifier, SharedIntentPayload?>(
      PendingSharePayloadNotifier.new,
    );
