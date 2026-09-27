import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/method_channel_share_intent_service.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/incoming_entry_service.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/services/share_intent_service.dart';

/// Saves shared and received content as entries and journals. The
/// attachment import service is read only when a shared file is saved.
final incomingEntryServiceProvider = Provider<IncomingEntryService>((ref) {
  return IncomingEntryService(
    db: ref.watch(appDatabaseProvider),
    importService: () => ref.read(attachmentImportServiceProvider),
  );
});

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
