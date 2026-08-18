import 'dart:io';
import 'dart:typed_data';

import 'package:sreerajp_journal_vault/core/database/database_open_failure.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Copies a plain database into a new encrypted one, and verifies it.
///
/// Implemented in `encrypted_database_opener.dart` with SQLCipher. It is a
/// parameter rather than a direct call so that a test can force the copy to
/// fail at will, which is the only way to check what this class does with a
/// user's journal when something goes wrong.
///
/// Must throw if anything at all is wrong with [target]. Returning normally is
/// taken as a promise that [target] is a complete, readable, encrypted copy of
/// [source].
typedef PlainDatabaseConversionStep =
    Future<void> Function(File source, File target);

/// What [PlainDatabaseConverter.run] did.
enum PlainDatabaseConversionOutcome {
  /// No plain database was found. Either this is a fresh install, or the
  /// vault is already encrypted.
  notNeeded,

  /// A plain database was found and has been replaced by an encrypted copy.
  /// The plain original is still on disk until
  /// [PlainDatabaseConverter.discardPlainBackup] is called.
  converted,
}

/// Turns an existing plain vault into an encrypted one, without ever
/// overwriting the original.
///
/// Layer: core service. Only file moves and checks live here — no SQL, no
/// widgets.
///
/// The order below is the whole safety argument, so it is worth stating
/// plainly. The original file is never written to. It is renamed aside only
/// after the encrypted copy has been made *and* verified, and it is deleted
/// only after the app has opened the encrypted copy for real. Between those
/// steps a crash can leave three states on disk, and [run] recognises and
/// repairs all three before it does anything else.
class PlainDatabaseConverter {
  PlainDatabaseConverter({
    required this.databaseFile,
    required this.convertStep,
  });

  /// The live vault file, e.g. `journal_vault.sqlite`.
  final File databaseFile;

  final PlainDatabaseConversionStep convertStep;

  /// The encrypted copy while it is being written.
  static const String convertingSuffix = '.converting';

  /// The plain original, kept until the encrypted vault has opened once.
  static const String plainBackupSuffix = '.plain-backup';

  /// The 16 bytes every plain SQLite file starts with.
  static final Uint8List _plainSqliteHeader = Uint8List.fromList(
    'SQLite format 3'.codeUnits + [0],
  );

  File get _convertingFile => File('${databaseFile.path}$convertingSuffix');

  /// The plain original, still on disk after a conversion.
  File get plainBackupFile => File('${databaseFile.path}$plainBackupSuffix');

  /// Converts the vault if it is still plain.
  ///
  /// Throws [DatabaseOpenFailure] with
  /// [DatabaseOpenFailureKind.conversionFailed] if anything goes wrong. In
  /// that case the original file is exactly as it was.
  Future<PlainDatabaseConversionOutcome> run() async {
    _repairInterruptedRun();

    if (!databaseFile.existsSync()) {
      return PlainDatabaseConversionOutcome.notNeeded;
    }
    if (!isPlainSqliteFile(databaseFile)) {
      return PlainDatabaseConversionOutcome.notNeeded;
    }

    AppLogger.info('Vault is not encrypted yet; starting conversion');

    final target = _convertingFile;
    _deleteQuietly(target);

    try {
      await convertStep(databaseFile, target);
    } catch (error) {
      _deleteQuietly(target);
      AppLogger.error('Vault conversion failed while copying', error: error);
      throw const DatabaseOpenFailure(DatabaseOpenFailureKind.conversionFailed);
    }

    if (!target.existsSync() || target.lengthSync() == 0) {
      _deleteQuietly(target);
      AppLogger.error('Vault conversion produced no output');
      throw const DatabaseOpenFailure(DatabaseOpenFailureKind.conversionFailed);
    }

    _swapInEncryptedCopy(target);

    AppLogger.info('Vault conversion finished; plain copy held for one open');
    return PlainDatabaseConversionOutcome.converted;
  }

  /// Deletes the plain original. Call only once the encrypted vault has been
  /// opened successfully — this is the point of no return.
  void discardPlainBackup() {
    if (!plainBackupFile.existsSync()) return;
    _deleteQuietly(plainBackupFile);
    AppLogger.info('Plain vault copy deleted after a successful open');
  }

  /// True when [file] starts with the plain SQLite header.
  ///
  /// An encrypted SQLCipher file starts with random-looking bytes instead, so
  /// this is a reliable "is it still readable by anyone with a file browser?"
  /// check — and doubles as the after-the-fact proof in the integration test.
  static bool isPlainSqliteFile(File file) {
    if (!file.existsSync()) return false;
    final handle = file.openSync();
    try {
      final head = handle.readSync(_plainSqliteHeader.length);
      if (head.length < _plainSqliteHeader.length) return false;
      for (var i = 0; i < _plainSqliteHeader.length; i++) {
        if (head[i] != _plainSqliteHeader[i]) return false;
      }
      return true;
    } finally {
      handle.closeSync();
    }
  }

  /// Puts the verified encrypted copy in place of the original.
  ///
  /// The write-ahead log and shared-memory files belong to the *plain*
  /// database. Left behind, SQLite would take them for the new file's own and
  /// replay plain pages into an encrypted vault, so they go first.
  void _swapInEncryptedCopy(File target) {
    try {
      _deleteSidecars(databaseFile);
      _deleteSidecars(target);
      databaseFile.renameSync(plainBackupFile.path);
    } catch (error) {
      _deleteQuietly(target);
      AppLogger.error('Vault conversion failed before the swap', error: error);
      throw const DatabaseOpenFailure(DatabaseOpenFailureKind.conversionFailed);
    }

    try {
      target.renameSync(databaseFile.path);
    } catch (error) {
      // The original is safe under its backup name. Put it back so the app
      // opens the vault it had, rather than no vault at all.
      _restorePlainBackup();
      _deleteQuietly(target);
      AppLogger.error('Vault conversion failed during the swap', error: error);
      throw const DatabaseOpenFailure(DatabaseOpenFailureKind.conversionFailed);
    }
  }

  /// Repairs whatever a crash during an earlier run left behind.
  ///
  /// Three states are possible, and all three are recoverable:
  ///
  /// 1. A half-written `.converting` file — throw it away and start over.
  /// 2. No vault, but a `.plain-backup` — the crash landed between the two
  ///    renames. Put the original back.
  /// 3. A vault *and* a `.plain-backup` — the crash landed after the swap, or
  ///    before the backup was discarded. The vault is the live file; the
  ///    backup is a duplicate and goes.
  void _repairInterruptedRun() {
    if (_convertingFile.existsSync()) {
      AppLogger.warning('Discarding a half-written encrypted vault copy');
      _deleteQuietly(_convertingFile);
    }

    if (!plainBackupFile.existsSync()) return;

    if (!databaseFile.existsSync()) {
      AppLogger.warning('Restoring the vault after an interrupted conversion');
      _restorePlainBackup();
      return;
    }

    AppLogger.warning('Removing a leftover plain vault copy');
    _deleteQuietly(plainBackupFile);
  }

  void _restorePlainBackup() {
    try {
      plainBackupFile.renameSync(databaseFile.path);
    } catch (error) {
      AppLogger.error('Could not restore the plain vault copy', error: error);
    }
  }

  static void _deleteSidecars(File file) {
    for (final suffix in const ['-wal', '-shm', '-journal']) {
      _deleteQuietly(File('${file.path}$suffix'));
    }
  }

  static void _deleteQuietly(File file) {
    try {
      if (file.existsSync()) file.deleteSync();
    } catch (_) {
      // Nothing useful to do, and nothing here is required for correctness.
    }
  }
}
