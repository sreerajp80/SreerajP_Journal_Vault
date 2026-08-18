import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_key_manager.dart';
import 'package:sreerajp_journal_vault/core/database/encrypted_database_opener.dart';
import 'package:sreerajp_journal_vault/core/database/plain_database_converter.dart';

/// On-device coverage of encryption at rest. **Needs a real device:**
///
/// ```
/// flutter test integration_test/encrypted_database_test.dart -d <device>
/// ```
///
/// The conversion itself is proven on the host in
/// `test/core/database/encrypted_database_test.dart`. What only a device can
/// show is the other half: that the Android Keystore hands back a working key,
/// and that the SQLCipher library is really inside the APK. If the build ever
/// packaged plain SQLite instead, these tests fail rather than the app quietly
/// writing journal text in the clear.
///
/// The test works in a temporary folder, so the vault on the device is never
/// touched. It does create the app's Keystore key if there is not one already,
/// which is harmless — that is exactly what the first real launch does.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory workDir;

  setUp(() async {
    final parent = await getApplicationDocumentsDirectory();
    workDir = await parent.createTemp('vault_cipher_it');
  });

  tearDown(() async {
    if (workDir.existsSync()) await workDir.delete(recursive: true);
  });

  testWidgets('the APK ships SQLCipher, not plain SQLite', (tester) async {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);

    expect(
      db.select('PRAGMA cipher_version;'),
      isNotEmpty,
      reason: 'plain SQLite answers this with nothing',
    );
  });

  testWidgets('the Keystore returns a usable 32-byte key', (tester) async {
    final key = await const PlatformDatabaseKeyManager().obtainKey(
      createIfMissing: true,
    );

    expect(key, isNotNull);
    expect(key!.bytes, hasLength(32));

    // The same key must come back on the next ask — a fresh key each time
    // would make every restart look like a corrupt vault.
    final again = await const PlatformDatabaseKeyManager().obtainKey(
      createIfMissing: false,
    );
    expect(again!.bytes, key.bytes);
  });

  testWidgets('a plain vault on the device is converted and keeps its rows', (
    tester,
  ) async {
    final vaultFile = File('${workDir.path}/journal_vault.sqlite');

    final plain = AppDatabase.forExecutor(NativeDatabase(vaultFile));
    final journalId = await plain.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'On device'),
    );
    await plain.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('Before the move'),
        plainText: const Value('a line that must survive the conversion'),
      ),
    );
    await plain.close();

    expect(PlainDatabaseConverter.isPlainSqliteFile(vaultFile), isTrue);

    final opened = await EncryptedDatabaseOpener(
      databaseDirectoryProvider: () async => workDir,
    ).open();
    addTearDown(opened.close);

    expect(
      await opened.entriesDao.getEntriesForJournal(journalId),
      hasLength(1),
    );
    expect(await opened.searchEntries('conversion'), hasLength(1));

    expect(PlainDatabaseConverter.isPlainSqliteFile(vaultFile), isFalse);
    expect(
      String.fromCharCodes(vaultFile.readAsBytesSync()),
      isNot(contains('a line that must survive the conversion')),
      reason:
          'the point of the whole change: entry text is no longer readable '
          'from the file itself',
    );
    expect(
      File(
        '${vaultFile.path}${PlainDatabaseConverter.plainBackupSuffix}',
      ).existsSync(),
      isFalse,
      reason: 'the plain copy is deleted once the encrypted vault has opened',
    );
  });
}
