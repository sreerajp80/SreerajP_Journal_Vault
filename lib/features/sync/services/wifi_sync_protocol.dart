import 'dart:convert';

import 'package:sreerajp_journal_vault/features/sync/services/sync_protocol.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_transport.dart';

/// Concrete [SyncProtocol] implementation operating over authenticated local TCP sockets.
class WifiSyncProtocol implements SyncProtocol {
  final WifiSyncHost? _host;
  final WifiSyncClient? _client;

  WifiSyncProtocol.forHost(WifiSyncHost host) : _host = host, _client = null;

  WifiSyncProtocol.forClient(WifiSyncClient client)
    : _client = client,
      _host = null;

  bool get isHost => _host != null;
  bool get isClient => _client != null;

  @override
  Future<bool> isAvailable() async {
    if (isHost) return _host!.hasClient;
    if (isClient) return true;
    return false;
  }

  /// Host only: sends [payload], then waits for the client's
  /// acknowledgement. Throws when none arrives, so the host marks nothing as
  /// synced and sends everything again next time.
  @override
  Future<SyncPushResult> push(SyncPayload payload) async {
    if (!isHost) {
      throw const SyncTransportException('Only the host sends.');
    }
    await _host!.sendPayload(jsonEncode(payload.toJson()));

    final SyncAck ack;
    try {
      final reply = await _host.receivePayload();
      ack = SyncAck.fromJson(jsonDecode(reply) as Map<String, dynamic>);
    } on SyncTransportException {
      rethrow;
    } catch (_) {
      throw const SyncTransportException(
        'The other phone did not confirm the sync.',
      );
    }
    return SyncPushResult(
      accepted: ack.applied,
      rejected: ack.skipped,
      conflicts: 0,
    );
  }

  /// Client only: tells the host the payload was applied.
  @override
  Future<void> acknowledge(SyncAck ack) async {
    if (!isClient) {
      throw const SyncTransportException('Only the client acknowledges.');
    }
    await _client!.sendPayload(jsonEncode(ack.toJson()));
  }

  @override
  Future<SyncPullResult> pull(
    DateTime? lastSyncTimestamp,
    String deviceId,
  ) async {
    if (isHost) {
      // In host-push mode, host does not wait on client payload
      return const SyncPullResult(records: []);
    }

    if (isClient) {
      final payloadJson = await _client!.awaitPayload();
      final decoded = jsonDecode(payloadJson) as Map<String, dynamic>;
      final payload = SyncPayload.fromJson(decoded);

      return SyncPullResult(
        records: payload.records,
        newHighWaterMark: payload.timestamp,
      );
    }

    throw const SyncTransportException('Sync transport not initialised.');
  }

  @override
  Future<SyncRemoteInfo> getRemoteInfo() async {
    return SyncRemoteInfo(
      serverVersion: '1.0.0',
      connectedDevices: 1,
      lastActivity: DateTime.now(),
    );
  }
}
