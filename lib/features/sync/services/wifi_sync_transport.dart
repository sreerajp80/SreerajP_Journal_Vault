import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:sreerajp_journal_vault/features/sync/services/bounded_line_reader.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_constants.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_crypto.dart';

/// Host-side phases surfaced to the UI and providers.
enum HostPhase {
  listening,
  connected,
  syncing,
  completed,
  denied,
  stopped,
  error,
}

/// Thrown for transport-level failures.
class SyncTransportException implements Exception {
  final String message;
  const SyncTransportException(this.message);
  @override
  String toString() => 'SyncTransportException: $message';
}

/// The Host (Sender / Sync Server).
///
/// Binds an ephemeral TCP socket, handles the cryptographic handshake with a single
/// client at a time, holds the connection open, and exchanges sync payloads.
class WifiSyncHost {
  final ServerSocket _server;
  final Uint8List _salt;
  final SecretKey _sessionKey;
  final String _pairingCode;

  final StreamController<HostPhase> _phases =
      StreamController<HostPhase>.broadcast();

  Socket? _client;
  BoundedLineReader? _reader;
  bool _authenticated = false;
  bool _stopped = false;

  final Completer<void> _clientConnected = Completer<void>();

  WifiSyncHost._(
    this._server,
    this._salt,
    this._sessionKey,
    this._pairingCode,
  ) {
    _server.listen(_onConnection, onError: (_) => _emit(HostPhase.error));
    _emit(HostPhase.listening);
  }

  /// Binds an ephemeral port on all IPv4 interfaces and starts listening.
  static Future<WifiSyncHost> start({
    required String code,
    int port = 0,
  }) async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    final salt = WifiSyncCrypto.randomBytes(WifiSyncConstants.saltLength);
    final key = await WifiSyncCrypto.deriveKey(code, salt);
    return WifiSyncHost._(server, salt, key, code);
  }

  int get port => _server.port;
  String get pairingCode => _pairingCode;

  /// Stream of host phases (listening → connected → …).
  Stream<HostPhase> get phases => _phases.stream;

  /// Completes once a client has authenticated successfully.
  Future<void> get clientConnected => _clientConnected.future;

  bool get hasClient => _authenticated && _client != null;

  void _emit(HostPhase p) {
    if (!_phases.isClosed) _phases.add(p);
  }

  Future<void> _onConnection(Socket socket) async {
    // Single client at a time: if we already have one, refuse immediately.
    if (_client != null) {
      socket.destroy();
      return;
    }
    _client = socket;
    final reader = BoundedLineReader(
      socket,
      maxLineBytes: WifiSyncConstants.payloadLineCap,
    );
    _reader = reader;

    try {
      // 1. Send the salt in the clear.
      socket.add(utf8.encode('${base64.encode(_salt)}\n'));
      await socket.flush();

      // 2. Read the client's HELLO and verify by decrypting with the session key.
      final helloWire = await reader.readLineWithTimeout(
        WifiSyncConstants.socketTimeout,
      );

      String hello;
      try {
        hello = await WifiSyncCrypto.decryptWire(_sessionKey, helloWire);
      } catch (_) {
        // Wrong code / decryption failure: tell the client and reset.
        socket.add(utf8.encode('${WifiSyncConstants.denied}\n'));
        await socket.flush();
        _emit(HostPhase.denied);
        await _dropClient();
        return;
      }

      if (hello != WifiSyncConstants.helloSync) {
        socket.add(utf8.encode('${WifiSyncConstants.denied}\n'));
        await socket.flush();
        _emit(HostPhase.denied);
        await _dropClient();
        return;
      }

      // 3. Good auth — reply with sealed ACCEPT.
      final acceptWire = await WifiSyncCrypto.encryptWire(
        _sessionKey,
        WifiSyncConstants.acceptSync,
      );
      socket.add(utf8.encode('$acceptWire\n'));
      await socket.flush();

      _authenticated = true;
      _emit(HostPhase.connected);
      if (!_clientConnected.isCompleted) _clientConnected.complete();

      // Track if client disconnects while waiting.
      reader.closed.then((_) {
        if (!_stopped && _authenticated) {
          _authenticated = false;
          _client = null;
          _emit(HostPhase.listening);
        }
      });
    } catch (_) {
      await _dropClient();
      if (!_stopped) _emit(HostPhase.listening);
    }
  }

  Future<void> _dropClient() async {
    final c = _client;
    _client = null;
    _authenticated = false;
    try {
      await _reader?.dispose();
    } catch (_) {}
    _reader = null;
    c?.destroy();
  }

  /// Sends a sealed payload string to the connected client.
  Future<void> sendPayload(String payload) async {
    final c = _client;
    if (!_authenticated || c == null) {
      throw const SyncTransportException('No device is connected.');
    }
    _emit(HostPhase.syncing);
    final encrypted = await WifiSyncCrypto.encryptWire(_sessionKey, payload);
    c.add(utf8.encode('$encrypted\n'));
    await c.flush();
  }

  /// Receives a sealed payload string from the connected client.
  Future<String> receivePayload() async {
    final c = _client;
    final r = _reader;
    if (!_authenticated || c == null || r == null) {
      throw const SyncTransportException('No device is connected.');
    }

    final wire = await r.readLineWithTimeout(
      WifiSyncConstants.payloadWaitTimeout,
    );
    return await WifiSyncCrypto.decryptWire(_sessionKey, wire);
  }

  Future<void> stop() async {
    _stopped = true;
    await _dropClient();
    try {
      await _server.close();
    } catch (_) {}
    _emit(HostPhase.stopped);
    await _phases.close();
  }
}

/// The Client (Receiver / Connecting Peer).
///
/// Connects to the host, completes the authenticated handshake, and exchanges payloads.
class WifiSyncClient {
  final Socket _socket;
  final BoundedLineReader _reader;
  final SecretKey _sessionKey;

  WifiSyncClient._(this._socket, this._reader, this._sessionKey);

  /// Connects to [host]:[port], reads the salt, derives the session key from [code],
  /// sends HELLO, and awaits ACCEPT.
  static Future<WifiSyncClient> connect({
    required String host,
    required int port,
    required String code,
  }) async {
    final Socket socket;
    try {
      socket = await Socket.connect(
        host,
        port,
        timeout: WifiSyncConstants.connectTimeout,
      );
    } catch (e) {
      throw SyncTransportException('Could not connect: ${_safeError(e)}');
    }

    // Initial reader with payload line cap
    final reader = BoundedLineReader(
      socket,
      maxLineBytes: WifiSyncConstants.payloadLineCap,
    );

    try {
      // 1. Read salt (clear).
      final saltLine = await reader.readLineWithTimeout(
        WifiSyncConstants.socketTimeout,
      );
      final salt = base64.decode(saltLine.trim());
      final key = await WifiSyncCrypto.deriveKey(
        code,
        Uint8List.fromList(salt),
      );

      // 2. Send HELLO sealed under derived session key.
      final helloWire = await WifiSyncCrypto.encryptWire(
        key,
        WifiSyncConstants.helloSync,
      );
      socket.add(utf8.encode('$helloWire\n'));
      await socket.flush();

      // 3. Read reply: either DENIED (clear) or sealed ACCEPT.
      final reply = await reader.readLineWithTimeout(
        WifiSyncConstants.socketTimeout,
      );
      if (reply.trim() == WifiSyncConstants.denied) {
        socket.destroy();
        throw const SyncTransportException('The pairing code was rejected.');
      }

      String accept;
      try {
        accept = await WifiSyncCrypto.decryptWire(key, reply);
      } catch (_) {
        socket.destroy();
        throw const SyncTransportException('Incorrect pairing code.');
      }

      if (accept != WifiSyncConstants.acceptSync) {
        socket.destroy();
        throw const SyncTransportException('Unexpected reply from host.');
      }

      return WifiSyncClient._(socket, reader, key);
    } on SyncTransportException {
      rethrow;
    } catch (e) {
      socket.destroy();
      throw SyncTransportException('Could not connect: ${_safeError(e)}');
    }
  }

  /// Sends a sealed payload string to the host.
  Future<void> sendPayload(String payload) async {
    final encrypted = await WifiSyncCrypto.encryptWire(_sessionKey, payload);
    _socket.add(utf8.encode('$encrypted\n'));
    await _socket.flush();
  }

  /// Awaits and decrypts a sealed payload from the host.
  Future<String> awaitPayload() async {
    final wire = await _reader.readLineWithTimeout(
      WifiSyncConstants.payloadWaitTimeout,
    );
    try {
      return await WifiSyncCrypto.decryptWire(_sessionKey, wire);
    } catch (_) {
      throw const SyncTransportException(
        'The received data could not be decrypted.',
      );
    }
  }

  Future<void> close() async {
    await _reader.dispose();
    _socket.destroy();
  }

  static String _safeError(Object e) {
    if (e is TimeoutException) return 'Connection timed out';
    if (e is SocketException) return 'Network unreachable or host closed';
    return 'Connection error';
  }
}

/// Discovers non-loopback local IPv4 addresses on this device for pairing display.
Future<List<String>> localIpv4Addresses() async {
  final result = <String>[];
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) {
          result.add(addr.address);
        }
      }
    }
  } catch (_) {
    // Return empty list on interface query errors
  }
  return result;
}
