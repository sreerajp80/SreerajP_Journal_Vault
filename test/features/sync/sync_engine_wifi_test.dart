import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_crypto.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_protocol.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_transport.dart';

void main() {
  group('SyncEngine over WifiSyncTransport', () {
    late AppDatabase dbHost;
    late AppDatabase dbClient;

    setUp(() {
      dbHost = AppDatabase.forExecutor(NativeDatabase.memory());
      dbClient = AppDatabase.forExecutor(NativeDatabase.memory());
    });

    tearDown(() async {
      await dbHost.close();
      await dbClient.close();
    });

    test(
      'Host pushes journals and entries to Client over authenticated Wi-Fi socket',
      () async {
        // 1. Create data on Host
        final journalId = await dbHost.journalsDao.createJournal(
          JournalsCompanion.insert(
            title: 'Travel Log',
            description: const Value('Notes from my journeys'),
          ),
        );

        await dbHost.entriesDao.createEntry(
          EntriesCompanion.insert(
            journalId: journalId,
            title: const Value('Arrival in Kochi'),
            contentJson: const Value(
              '{"ops":[{"insert":"Landed safely.\\n"}]}',
            ),
            plainText: const Value('Landed safely.'),
          ),
        );

        // Verify Client DB is initially empty
        final initialClientJournals = await dbClient.journalsDao
            .getAllJournals();
        expect(initialClientJournals.isEmpty, isTrue);

        // 2. Start Host
        final pairingCode = WifiSyncCrypto.generatePairingCode();
        final host = await WifiSyncHost.start(code: pairingCode);

        // 3. Connect Client
        final client = await WifiSyncClient.connect(
          host: '127.0.0.1',
          port: host.port,
          code: pairingCode,
        );
        await host.clientConnected;

        final encryption = SyncEncryptionService();

        final hostEngine = SyncEngine(
          db: dbHost,
          protocol: WifiSyncProtocol.forHost(host),
          encryption: encryption,
          deviceId: 'device-host-1',
        );

        final clientEngine = SyncEngine(
          db: dbClient,
          protocol: WifiSyncProtocol.forClient(client),
          encryption: encryption,
          deviceId: 'device-client-2',
        );

        // 4. Run sync in parallel: Host pushes, Client pulls
        final hostFuture = hostEngine.performSync(syncPassword: pairingCode);
        final clientFuture = clientEngine.performSync(
          syncPassword: pairingCode,
        );

        final results = await Future.wait([hostFuture, clientFuture]);

        expect(results[0], SyncStatus.success);
        expect(results[1], SyncStatus.success);

        // 5. Verify Client received the journal and entry
        final syncedJournals = await dbClient.journalsDao.getAllJournals();
        expect(syncedJournals.length, 1);
        expect(syncedJournals.first.title, 'Travel Log');

        final syncedEntries = await dbClient.entriesDao.getEntriesForJournal(
          syncedJournals.first.id,
        );
        expect(syncedEntries.length, 1);
        expect(syncedEntries.first.title, 'Arrival in Kochi');
        expect(syncedEntries.first.plainText, 'Landed safely.');

        await client.close();
        await host.stop();
      },
    );
  });
}
