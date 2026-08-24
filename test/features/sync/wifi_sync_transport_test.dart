import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_crypto.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_transport.dart';

void main() {
  group('WifiSyncTransport', () {
    test(
      'Host and Client complete authenticated handshake and transfer payload',
      () async {
        final pairingCode = WifiSyncCrypto.generatePairingCode();

        // Start Host on loopback
        final host = await WifiSyncHost.start(code: pairingCode);
        expect(host.port > 0, isTrue);

        // Connect Client
        final client = await WifiSyncClient.connect(
          host: '127.0.0.1',
          port: host.port,
          code: pairingCode,
        );

        // Wait for host connection event
        await host.clientConnected;
        expect(host.hasClient, isTrue);

        // Host pushes sealed payload to Client
        const testPayload =
            '{"message": "Hello from Host!", "entries": [1, 2, 3]}';
        await host.sendPayload(testPayload);

        final received = await client.awaitPayload();
        expect(received, testPayload);

        await client.close();
        await host.stop();
      },
    );

    test(
      'Client with incorrect code is rejected with SyncTransportException',
      () async {
        final hostCode = WifiSyncCrypto.generatePairingCode();
        const wrongCode = '2222333344445555';

        final host = await WifiSyncHost.start(code: hostCode);

        expect(
          () => WifiSyncClient.connect(
            host: '127.0.0.1',
            port: host.port,
            code: wrongCode,
          ),
          throwsA(isA<SyncTransportException>()),
        );

        await host.stop();
      },
    );

    test('Host enforces single client lock and drops second client', () async {
      final pairingCode = WifiSyncCrypto.generatePairingCode();

      final host = await WifiSyncHost.start(code: pairingCode);

      final client1 = await WifiSyncClient.connect(
        host: '127.0.0.1',
        port: host.port,
        code: pairingCode,
      );

      await host.clientConnected;

      // Second client attempts connection
      final rawSocket2 = await Socket.connect('127.0.0.1', host.port);

      // Host should drop client2 immediately
      await expectLater(rawSocket2.map((e) => e).toList(), completion(isEmpty));

      rawSocket2.destroy();
      await client1.close();
      await host.stop();
    });
  });
}
