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
          role: SyncRole.sender,
        );

        final clientEngine = SyncEngine(
          db: dbClient,
          protocol: WifiSyncProtocol.forClient(client),
          encryption: encryption,
          deviceId: 'device-client-2',
          role: SyncRole.receiver,
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

    test(
      'over the socket, a receiver with its own journals keeps entries apart',
      () async {
        // The client already has journals, so its row numbers differ.
        await dbClient.journalsDao.createJournal(
          JournalsCompanion.insert(title: 'Client one'),
        );
        await dbClient.journalsDao.createJournal(
          JournalsCompanion.insert(title: 'Client two'),
        );
        final hostJournal = await dbHost.journalsDao.createJournal(
          JournalsCompanion.insert(title: 'Host journal'),
        );
        await dbHost.entriesDao.createEntry(
          EntriesCompanion.insert(
            journalId: hostJournal,
            title: const Value('Host entry'),
          ),
        );

        final pairingCode = WifiSyncCrypto.generatePairingCode();
        final host = await WifiSyncHost.start(code: pairingCode);
        final client = await WifiSyncClient.connect(
          host: '127.0.0.1',
          port: host.port,
          code: pairingCode,
        );
        await host.clientConnected;
        final encryption = SyncEncryptionService();

        final results = await Future.wait([
          SyncEngine(
            db: dbHost,
            protocol: WifiSyncProtocol.forHost(host),
            encryption: encryption,
            deviceId: 'device-host-1',
            role: SyncRole.sender,
          ).performSync(syncPassword: pairingCode),
          SyncEngine(
            db: dbClient,
            protocol: WifiSyncProtocol.forClient(client),
            encryption: encryption,
            deviceId: 'device-client-2',
            role: SyncRole.receiver,
          ).performSync(syncPassword: pairingCode),
        ]);
        expect(results, [SyncStatus.success, SyncStatus.success]);

        final journals = await dbClient.journalsDao.getAllJournals();
        final synced = journals.singleWhere((j) => j.title == 'Host journal');
        final entries = await dbClient.entriesDao.getEntriesForJournal(
          synced.id,
        );
        expect(entries.single.title, 'Host entry');
        for (final own in journals.where((j) => j.id != synced.id)) {
          expect(
            await dbClient.entriesDao.getEntriesForJournal(own.id),
            isEmpty,
          );
        }

        await client.close();
        await host.stop();
      },
    );

    test(
      'over the socket, an edit and a delete reach the client',
      () async {
        final journal = await dbHost.journalsDao.createJournal(
          JournalsCompanion.insert(title: 'Trip'),
        );
        final edited = await dbHost.entriesDao.createEntry(
          EntriesCompanion.insert(
            journalId: journal,
            title: const Value('Before'),
          ),
        );
        final removed = await dbHost.entriesDao.createEntry(
          EntriesCompanion.insert(
            journalId: journal,
            title: const Value('Goes away'),
          ),
        );

        Future<void> syncOverSocket() async {
          final code = WifiSyncCrypto.generatePairingCode();
          final host = await WifiSyncHost.start(code: code);
          final client = await WifiSyncClient.connect(
            host: '127.0.0.1',
            port: host.port,
            code: code,
          );
          await host.clientConnected;
          final encryption = SyncEncryptionService();
          final results = await Future.wait([
            SyncEngine(
              db: dbHost,
              protocol: WifiSyncProtocol.forHost(host),
              encryption: encryption,
              deviceId: 'device-host-1',
              role: SyncRole.sender,
            ).performSync(syncPassword: code, maxRetries: 0),
            SyncEngine(
              db: dbClient,
              protocol: WifiSyncProtocol.forClient(client),
              encryption: encryption,
              deviceId: 'device-client-2',
              role: SyncRole.receiver,
            ).performSync(syncPassword: code, maxRetries: 0),
          ]);
          expect(results, [SyncStatus.success, SyncStatus.success]);
          await client.close();
          await host.stop();
        }

        await syncOverSocket();

        await dbHost.entriesDao.updateEntryById(
          edited,
          const EntriesCompanion(title: Value('After')),
        );
        await dbHost.entriesDao.deleteEntryById(removed);
        await syncOverSocket();

        final titles = [
          for (final e in await dbClient.select(dbClient.entries).get())
            e.title,
        ];
        expect(titles, ['After']);
        // The host received the acknowledgement: nothing is left pending.
        expect(await dbHost.syncMetadataDao.pendingSyncIds(), isEmpty);
      },
      // Two sessions, each deriving its key with Argon2id on both sides.
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
