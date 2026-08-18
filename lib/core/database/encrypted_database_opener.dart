import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_key_manager.dart';
import 'package:sreerajp_journal_vault/core/database/database_open_failure.dart';
import 'package:sreerajp_journal_vault/core/database/plain_database_converter.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// The vault file name. Unchanged from the plain-SQLite days on purpose: an
/// existing install must find its own database, not a new empty one.
const String vaultDatabaseFileName = 'journal_vault.sqlite';

/// Opens the encrypted vault, converting a plain one first if it finds one.
///
/// Layer: core service. It knows about files, keys and SQL; it knows nothing
/// about widgets or navigation.
///
/// The cipher itself is chosen at build time: the `hooks:` block in
/// `pubspec.yaml` tells `package:sqlite3` to use its SQLCipher build instead of
/// plain SQLite, on the device and on the test runner alike. Nothing here can
/// turn encryption on if that setting is wrong, so [_openWithKey] checks the
/// result twice rather than trusting it.
///
/// Every failure comes back as a [DatabaseOpenFailure]. None is recovered from
/// automatically, because every "recovery" available at this point would mean
/// discarding the user's journal — see `lib/app/vault_unavailable_app.dart`.
class EncryptedDatabaseOpener {
  EncryptedDatabaseOpener({
    DatabaseKeyManager? keyManager,
    Future<Directory> Function()? databaseDirectoryProvider,
    Future<Directory> Function()? temporaryDirectoryProvider,
  }) : _keyManager = keyManager ?? const PlatformDatabaseKeyManager(),
       _databaseDirectoryProvider =
           databaseDirectoryProvider ?? getApplicationDocumentsDirectory,
       _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory;

  final DatabaseKeyManager _keyManager;
  final Future<Directory> Function() _databaseDirectoryProvider;
  final Future<Directory> Function() _temporaryDirectoryProvider;

  /// Opens the vault, ready to use.
  Future<AppDatabase> open() async {
    await _useAppTemporaryDirectory();

    final directory = await _databaseDirectoryProvider();
    final file = File(p.join(directory.path, vaultDatabaseFileName));

    final key = await _loadKey(file);
    final converter = PlainDatabaseConverter(
      databaseFile: file,
      convertStep: (source, target) => convertPlainDatabaseToCipher(
        source: source,
        target: target,
        key: key,
      ),
    );

    final outcome = await converter.run();
    final database = await _openWithKey(file, key);

    if (outcome == PlainDatabaseConversionOutcome.converted) {
      // The encrypted vault has now been opened and read for real. Only now is
      // it safe to let go of the plain original.
      converter.discardPlainBackup();
    }

    return database;
  }

  /// Points sqlite3's scratch files somewhere the app can actually write.
  ///
  /// Without this, sqlite3 would try `/tmp` on Android, which is out of reach
  /// inside the app sandbox.
  Future<void> _useAppTemporaryDirectory() async {
    sqlite3.tempDirectory = (await _temporaryDirectoryProvider()).path;
  }

  Future<DatabaseKey> _loadKey(File file) async {
    // A key may be created for a vault that does not exist yet, and for one
    // that is still plain. It must never be created for a file that is already
    // encrypted: that file was written under a key that is now gone, so a new
    // key would not open it, and the journal would be lost behind a database
    // that looks perfectly healthy.
    final createIfMissing =
        !file.existsSync() || PlainDatabaseConverter.isPlainSqliteFile(file);

    try {
      final key = await _keyManager.obtainKey(createIfMissing: createIfMissing);
      if (key == null) {
        AppLogger.fatal('No database key is available for the vault');
        throw const DatabaseOpenFailure(DatabaseOpenFailureKind.keyUnavailable);
      }
      return key;
    } on DatabaseKeyUnavailableException catch (error) {
      AppLogger.fatal('The database key could not be read', error: error);
      throw const DatabaseOpenFailure(DatabaseOpenFailureKind.keyUnavailable);
    }
  }

  Future<AppDatabase> _openWithKey(File file, DatabaseKey key) async {
    final rawKey = key.sqlCipherRawKey;

    final database = AppDatabase.forExecutor(
      NativeDatabase.createBackgroundConnection(
        file,
        // Runs in drift's background isolate, on the fresh handle, before any
        // other statement. It must capture nothing but this string.
        setup: (raw) => unlockCipherDatabase(raw, rawKey),
      ),
    );

    try {
      // Forces the connection to open for real. A wrong key, a corrupt file,
      // or a missing cipher all surface here rather than at the first screen
      // that tries to read an entry.
      await database.customSelect('SELECT count(*) FROM sqlite_master').get();
    } catch (error) {
      await database.close();
      AppLogger.fatal('The vault could not be opened', error: error);
      throw const DatabaseOpenFailure(DatabaseOpenFailureKind.openFailed);
    }

    // Belt and braces against a build that quietly linked plain SQLite: if the
    // file on disk still reads as plain SQLite after a successful open, then
    // journal text is sitting there in the clear and the app must not carry on
    // writing to it.
    if (PlainDatabaseConverter.isPlainSqliteFile(file)) {
      await database.close();
      AppLogger.fatal('The vault opened unencrypted; refusing to use it');
      throw const DatabaseOpenFailure(
        DatabaseOpenFailureKind.cipherUnavailable,
      );
    }

    return database;
  }
}

/// Unlocks a freshly opened handle and proves the cipher is real.
///
/// Top-level because drift sends it to its background isolate.
void unlockCipherDatabase(Database raw, String rawKey) {
  // Double quotes are required here: `PRAGMA key = x'…'` parses as a blob
  // literal and yields a different key, which fails much later and looks like
  // a corrupt vault.
  raw.execute('PRAGMA key = "$rawKey";');

  final cipher = raw.select('PRAGMA cipher_version;');
  final version = cipher.isEmpty
      ? ''
      : (cipher.first.values.first?.toString() ?? '');
  if (version.isEmpty) {
    // Plain SQLite answers this pragma with nothing. Failing here stops the
    // app before a single journal entry can be written unencrypted.
    throw StateError('SQLCipher is not the loaded sqlite3 library');
  }
}

/// Copies a plain vault into a new encrypted one and verifies the copy.
///
/// This is the real [PlainDatabaseConversionStep]. It runs before drift opens
/// anything, and it never writes to [source].
///
/// It throws on any doubt at all. The caller treats a thrown error as "leave
/// the plain vault exactly as it is".
Future<void> convertPlainDatabaseToCipher({
  required File source,
  required File target,
  required DatabaseKey key,
}) async {
  final rawKey = key.sqlCipherRawKey;

  // Opened with no key: SQLCipher reads a plain database just as SQLite does,
  // as long as no key is ever set on it.
  final plain = sqlite3.open(source.path);
  final int userVersion;
  final Map<String, int> rowCounts;
  try {
    userVersion = plain.userVersion;
    rowCounts = _countRows(plain);

    // Both the path and the key are bound as parameters — the key especially,
    // because an inline blob literal here would produce a database that no
    // later `PRAGMA key` can open.
    plain.execute('ATTACH DATABASE ? AS encrypted KEY ?;', [
      target.path,
      rawKey,
    ]);
    plain.execute("SELECT sqlcipher_export('encrypted');");
    plain.execute('PRAGMA encrypted.user_version = $userVersion;');
    plain.execute('DETACH DATABASE encrypted;');
  } finally {
    plain.close();
  }

  final encrypted = sqlite3.open(target.path);
  try {
    unlockCipherDatabase(encrypted, rawKey);

    final integrity = encrypted.select('PRAGMA integrity_check;');
    final verdict = integrity.isEmpty
        ? ''
        : integrity.first.values.first?.toString();
    if (verdict != 'ok') {
      throw StateError('The encrypted copy failed its integrity check');
    }

    if (encrypted.userVersion != userVersion) {
      throw StateError('The encrypted copy has the wrong schema version');
    }

    final copiedCounts = _countRows(encrypted);
    for (final entry in rowCounts.entries) {
      if (copiedCounts[entry.key] != entry.value) {
        // Table names are schema, not user data, so this is safe to say.
        throw StateError('Rows were lost copying ${entry.key}');
      }
    }

    // The search index is derived data. `sqlcipher_export` does carry it
    // across, but rebuilding costs little and removes any chance of the vault
    // opening with a stale or half-copied index.
    for (final index in const ['entries_fts', 'attachment_text_fts']) {
      if (_hasTable(encrypted, index)) {
        encrypted.execute("INSERT INTO $index($index) VALUES('rebuild');");
      }
    }
  } finally {
    encrypted.close();
  }
}

/// Row counts for every real user table, keyed by table name.
///
/// FTS5 tables and their shadow tables (`*_fts_data`, `*_fts_idx`, …) are
/// skipped: the index is rebuilt afterwards, so its counts are expected to
/// differ.
Map<String, int> _countRows(Database database) {
  final names = database
      .select(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '%_fts%';",
      )
      .map((row) => row['name'] as String)
      .toList();

  return {
    for (final name in names)
      name:
          database.select('SELECT count(*) AS c FROM "$name";').first['c']
              as int,
  };
}

bool _hasTable(Database database, String name) => database.select(
  'SELECT name FROM sqlite_master WHERE name = ?;',
  [name],
).isNotEmpty;
