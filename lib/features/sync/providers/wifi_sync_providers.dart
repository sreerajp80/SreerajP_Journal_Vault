import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/providers/sync_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_crypto.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_protocol.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_transport.dart';

const String _prefDeviceIdKey = 'vault_sync_device_id';

/// Stable device ID for vector clocks and sync metadata.
final syncDeviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString(_prefDeviceIdKey);
  if (id == null || id.isEmpty) {
    id = const Uuid().v4();
    await prefs.setString(_prefDeviceIdKey, id);
  }
  return id;
});

/// List of local non-loopback IPv4 addresses.
final localIpv4ListProvider = FutureProvider<List<String>>((ref) async {
  return localIpv4Addresses();
});

/// State for the active Host session.
class HostSessionState {
  final WifiSyncHost? host;
  final HostPhase phase;
  final String? pairingCode;
  final int? port;

  const HostSessionState({
    this.host,
    this.phase = HostPhase.stopped,
    this.pairingCode,
    this.port,
  });

  HostSessionState copyWith({
    WifiSyncHost? host,
    HostPhase? phase,
    String? pairingCode,
    int? port,
  }) {
    return HostSessionState(
      host: host ?? this.host,
      phase: phase ?? this.phase,
      pairingCode: pairingCode ?? this.pairingCode,
      port: port ?? this.port,
    );
  }
}

/// Manages the Host lifecycle (Send Mode).
class WifiSyncHostNotifier extends Notifier<HostSessionState> {
  StreamSubscription<HostPhase>? _phaseSub;

  @override
  HostSessionState build() {
    ref.onDispose(() {
      _phaseSub?.cancel();
      state.host?.stop();
    });
    return const HostSessionState();
  }

  Future<void> startHost() async {
    await stopHost();
    try {
      final code = WifiSyncCrypto.generatePairingCode();
      final host = await WifiSyncHost.start(code: code);
      _phaseSub = host.phases.listen((phase) {
        state = state.copyWith(phase: phase);
      });
      state = HostSessionState(
        host: host,
        phase: HostPhase.listening,
        pairingCode: code,
        port: host.port,
      );
    } catch (e) {
      // The phase is what the screen shows; the reason is only logged.
      AppLogger.warning(
        'wifi sync: host could not start',
        error: AppLogger.redact(e),
      );
      state = const HostSessionState(phase: HostPhase.error);
    }
  }

  Future<void> stopHost() async {
    _phaseSub?.cancel();
    _phaseSub = null;
    await state.host?.stop();
    state = const HostSessionState();
  }
}

final wifiSyncHostProvider =
    NotifierProvider<WifiSyncHostNotifier, HostSessionState>(
      WifiSyncHostNotifier.new,
    );

/// Progress & state for client connections (Receive Mode).
enum ClientSyncStep {
  idle,
  connecting,
  authenticating,
  syncing,
  completed,
  error,
}

class ClientSyncState {
  final ClientSyncStep step;
  final SyncStatus? syncStatus;

  /// True when the last attempt failed. The reason itself is logged, not
  /// carried here: the screen words a failure in the user's language rather
  /// than showing a socket error.
  final bool hasFailed;

  const ClientSyncState({
    this.step = ClientSyncStep.idle,
    this.syncStatus,
    this.hasFailed = false,
  });

  ClientSyncState copyWith({
    ClientSyncStep? step,
    SyncStatus? syncStatus,
    bool? hasFailed,
  }) {
    return ClientSyncState(
      step: step ?? this.step,
      syncStatus: syncStatus ?? this.syncStatus,
      hasFailed: hasFailed ?? this.hasFailed,
    );
  }
}

class WifiSyncClientNotifier extends Notifier<ClientSyncState> {
  @override
  ClientSyncState build() => const ClientSyncState();

  Future<SyncStatus> connectAndSync({
    required String host,
    required int port,
    required String code,
  }) async {
    state = const ClientSyncState(step: ClientSyncStep.connecting);

    WifiSyncClient? client;
    try {
      state = state.copyWith(step: ClientSyncStep.authenticating);

      client = await WifiSyncClient.connect(host: host, port: port, code: code);

      state = state.copyWith(step: ClientSyncStep.syncing);

      final protocol = WifiSyncProtocol.forClient(client);
      final db = ref.read(appDatabaseProvider);
      final encryption = ref.read(syncEncryptionServiceProvider);
      final deviceId = await ref.read(syncDeviceIdProvider.future);
      final cipher = ref.read(backupAttachmentCipherProvider);

      final engine = SyncEngine(
        db: db,
        protocol: protocol,
        encryption: encryption,
        deviceId: deviceId,
        attachmentCipher: cipher,
      );

      // Perform sync using the derived session pairing code
      final result = await engine.performSync(syncPassword: code);

      state = ClientSyncState(
        step: ClientSyncStep.completed,
        syncStatus: result,
      );

      // Refresh DB data providers
      ref.invalidate(recentSyncLogsProvider);
      ref.invalidate(latestSuccessfulSyncProvider);

      return result;
    } catch (e) {
      // The reason is logged, redacted, and never put on screen raw.
      AppLogger.warning(
        'wifi sync: client run failed',
        error: AppLogger.redact(e),
      );
      state = const ClientSyncState(
        step: ClientSyncStep.error,
        hasFailed: true,
      );
      return SyncStatus.failed;
    } finally {
      await client?.close();
    }
  }

  void reset() {
    state = const ClientSyncState();
  }
}

final wifiSyncClientProvider =
    NotifierProvider<WifiSyncClientNotifier, ClientSyncState>(
      WifiSyncClientNotifier.new,
    );
