import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_key_manager.dart';
import 'package:sreerajp_journal_vault/core/database/database_open_failure.dart';
import 'package:sreerajp_journal_vault/core/database/encrypted_database_opener.dart';
import 'package:sreerajp_journal_vault/core/database/plain_database_converter.dart';

/// Tests the real conversion of a plain vault into an encrypted one.
///
/// These run against real SQLCipher: the `hooks:` block in `pubspec.yaml`
/// selects the SQLCipher build of `package:sqlite3` for every target, the test
/// runner included. That is what makes it possible to prove here — and not
/// only on a device — that a converted vault keeps every row and that the file
/// left on disk is no longer readable without the key.
void main() {
  late Directory tempDir;
  late File plainFile;
  late File encryptedFile;
  late DatabaseKey key;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('vault_cipher_test');
    plainFile = File('${tempDir.path}/journal_vault.sqlite');
    encryptedFile = File('${tempDir.path}/journal_vault.sqlite.converting');
    key = DatabaseKey(
      Uint8List.fromList(List<int>.generate(32, (i) => (i * 7 + 3) % 256)),
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Builds a plain vault with content worth losing, then closes it.
  Future<void> seedPlainVault() async {
    final db = AppDatabase.forExecutor(NativeDatabase(plainFile));
    final journalId = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Travel'),
    );
    await db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('First light'),
        plainText: const Value('the harbour was quiet that morning'),
      ),
    );
    await db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('Second day'),
        plainText: const Value('rain, and a very good sandwich'),
      ),
    );
    await db.close();
  }

  Database openEncrypted(File file) {
    final raw = sqlite3.open(file.path);
    unlockCipherDatabase(raw, key.sqlCipherRawKey);
    return raw;
  }

  test('SQLCipher is the library the tests and the app run against', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);

    final version = db.select('PRAGMA cipher_version;');
    expect(
      version,
      isNotEmpty,
      reason:
          'plain SQLite answers this pragma with nothing — if this fails, '
          'the build is writing journal text unencrypted',
    );
  });

  test(
    'a plain vault is readable by anyone; the converted one is not',
    () async {
      await seedPlainVault();
      expect(PlainDatabaseConverter.isPlainSqliteFile(plainFile), isTrue);
      expect(
        String.fromCharCodes(plainFile.readAsBytesSync()),
        contains('the harbour was quiet that morning'),
        reason: 'this is the risk the whole change exists to remove',
      );

      await convertPlainDatabaseToCipher(
        source: plainFile,
        target: encryptedFile,
        key: key,
      );

      expect(PlainDatabaseConverter.isPlainSqliteFile(encryptedFile), isFalse);
      expect(
        String.fromCharCodes(encryptedFile.readAsBytesSync()),
        isNot(contains('the harbour was quiet that morning')),
      );
    },
  );

  test('every row and the schema version survive the conversion', () async {
    await seedPlainVault();
    final expectedVersion = sqlite3.open(plainFile.path)
      ..execute('PRAGMA journal_mode = delete;');
    final schemaVersion = expectedVersion.userVersion;
    expectedVersion.close();

    await convertPlainDatabaseToCipher(
      source: plainFile,
      target: encryptedFile,
      key: key,
    );

    final raw = openEncrypted(encryptedFile);
    addTearDown(raw.close);

    expect(raw.userVersion, schemaVersion);
    expect(raw.select('SELECT * FROM journals;'), hasLength(1));
    expect(raw.select('SELECT * FROM entries;'), hasLength(2));
    expect(raw.select('PRAGMA integrity_check;').first.values.first, 'ok');
  });

  test('the converted vault opens through Drift and still searches', () async {
    await seedPlainVault();
    await convertPlainDatabaseToCipher(
      source: plainFile,
      target: encryptedFile,
      key: key,
    );

    final db = AppDatabase.forExecutor(
      NativeDatabase(
        encryptedFile,
        setup: (raw) => unlockCipherDatabase(raw, key.sqlCipherRawKey),
      ),
    );
    addTearDown(db.close);

    final entries = await db.entriesDao.getEntriesForJournal(1);
    expect(entries, hasLength(2));

    // The FTS index is rebuilt during the conversion, so search must still
    // work without the app re-indexing anything.
    final results = await db.searchEntries('sandwich');
    expect(results, hasLength(1));
    expect(results.first.title, 'Second day');

    // And the vault keeps working for writes after the move.
    await db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: 1,
        title: const Value('Third day'),
        plainText: const Value('the ferry was late'),
      ),
    );
    expect(await db.searchEntries('ferry'), hasLength(1));
  });

  test('the wrong key does not open the converted vault', () async {
    await seedPlainVault();
    await convertPlainDatabaseToCipher(
      source: plainFile,
      target: encryptedFile,
      key: key,
    );

    final otherKey = DatabaseKey(Uint8List(32));
    final raw = sqlite3.open(encryptedFile.path);
    addTearDown(raw.close);
    unlockCipherDatabase(raw, otherKey.sqlCipherRawKey);

    expect(
      () => raw.select('SELECT * FROM entries;'),
      throwsA(isA<SqliteException>()),
    );
  });

  group('EncryptedDatabaseOpener', () {
    late _RecordingKeyManager keyManager;
    late EncryptedDatabaseOpener opener;

    setUp(() {
      keyManager = _RecordingKeyManager(key);
      opener = EncryptedDatabaseOpener(
        keyManager: keyManager,
        databaseDirectoryProvider: () async => tempDir,
        temporaryDirectoryProvider: () async => tempDir,
      );
    });

    test('creates an encrypted vault on a fresh install', () async {
      final db = await opener.open();
      addTearDown(db.close);

      await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'New'),
      );

      expect(keyManager.createIfMissingCalls, [true]);
      expect(plainFile.existsSync(), isTrue);
      expect(PlainDatabaseConverter.isPlainSqliteFile(plainFile), isFalse);
    });

    test('converts an existing plain vault and then lets it go', () async {
      await seedPlainVault();

      final db = await opener.open();
      addTearDown(db.close);

      expect(await db.entriesDao.getEntriesForJournal(1), hasLength(2));
      expect(PlainDatabaseConverter.isPlainSqliteFile(plainFile), isFalse);
      expect(
        File(
          '${plainFile.path}${PlainDatabaseConverter.plainBackupSuffix}',
        ).existsSync(),
        isFalse,
        reason: 'the plain copy is deleted once the encrypted vault opened',
      );
    });

    test(
      'never makes a new key for a vault that is already encrypted',
      () async {
        await seedPlainVault();
        await (await opener.open()).close();

        keyManager.reset(available: false);

        await expectLater(
          opener.open(),
          throwsA(
            isA<DatabaseOpenFailure>().having(
              (f) => f.kind,
              'kind',
              DatabaseOpenFailureKind.keyUnavailable,
            ),
          ),
        );
        expect(
          keyManager.createIfMissingCalls,
          [false],
          reason:
              'a new key here would strand the journal behind a healthy '
              'looking but unreadable database',
        );
      },
    );

    test('reopens an encrypted vault with the same key', () async {
      final first = await opener.open();
      await first.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Kept'),
      );
      await first.close();

      final second = await opener.open();
      addTearDown(second.close);

      expect(await second.journalsDao.getAllJournals(), hasLength(1));
    });
  });

  test('a key is 32 bytes and renders as a raw key, never as itself', () {
    expect(key.sqlCipherRawKey, matches(RegExp(r"^x'[0-9a-f]{64}'$")));
    expect(key.toString(), 'DatabaseKey(<redacted>)');
    expect(() => DatabaseKey(Uint8List(16)), throwsA(isA<ArgumentError>()));
  });
}

/// A [DatabaseKeyManager] that hands out a fixed key and remembers how it was
/// asked, so the `createIfMissing` decision can be checked directly.
class _RecordingKeyManager implements DatabaseKeyManager {
  _RecordingKeyManager(this._key);

  final DatabaseKey _key;
  final List<bool> createIfMissingCalls = <bool>[];
  bool _available = true;

  void reset({required bool available}) {
    createIfMissingCalls.clear();
    _available = available;
  }

  @override
  Future<DatabaseKey?> obtainKey({required bool createIfMissing}) async {
    createIfMissingCalls.add(createIfMissing);
    return _available ? _key : null;
  }
}
