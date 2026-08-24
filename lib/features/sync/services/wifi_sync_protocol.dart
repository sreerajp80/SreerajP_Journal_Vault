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

  @override
  Future<SyncPushResult> push(SyncPayload payload) async {
    final payloadJson = jsonEncode(payload.toJson());
    if (isHost) {
      await _host!.sendPayload(payloadJson);
    } else if (isClient) {
      await _client!.sendPayload(payloadJson);
    } else {
      throw const SyncTransportException('Sync transport not initialised.');
    }

    return SyncPushResult(
      accepted: payload.records.length,
      rejected: 0,
      conflicts: 0,
    );
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
