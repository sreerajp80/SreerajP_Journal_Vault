import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';

/// Interface for receiving shared text, links, and media from Android intent channels.
abstract class ShareIntentService {
  /// Fetches the payload that launched the app, if any.
  Future<SharedIntentPayload?> getInitialSharedPayload();

  /// Stream of shared payloads received while the app is already open.
  Stream<SharedIntentPayload> get sharedPayloadStream;

  /// Clears any pending shared payload from native memory.
  Future<void> clearSharedPayload();

  /// Cleans up resources.
  void dispose();
}
