import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/stale_file_sweeper.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';
import 'package:sreerajp_journal_vault/features/entries/services/legacy_voice_note_mover.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_temp_file_sweeper.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_record_applier.dart';

/// Housekeeping that runs once, after the vault opens and before the first
/// screen, so nothing else is writing files yet.
///
/// 1. Moves voice notes from the old table into attachments.
/// 2. Deletes decrypted attachment copies left by the last run.
/// 3. Deletes scan photos left by an unfinished scan.
/// 4. Deletes picker copies, staged backups and unfinished recordings, and
///    encrypted files no row points at.
///
/// Also turns on the pause sweep for attachment copies handed to other apps.
/// Every step is guarded: a failure is logged and the app still starts.
Future<void> runStartupMaintenance({
  required AppDatabase database,
  required AttachmentTempFileManager tempFileManager,
  Future<Directory> Function() cacheDirectory = getTemporaryDirectory,
  Future<Directory> Function() documentsDirectory =
      getApplicationDocumentsDirectory,
}) async {
  await _guard(
    'voice note move',
    () => LegacyVoiceNoteMover(database).moveAll(),
  );
  await _guard('attachment copies', tempFileManager.start);
  await _guard(
    'scan photos',
    () => CacheOcrTempFileSweeper(cacheDirectory: cacheDirectory).sweepStale(),
  );
  await _guard(
    'stale files',
    () => StaleFileSweeper(
      cacheDirectory: cacheDirectory,
      documentsDirectory: documentsDirectory,
      referencedStoredPaths: () => storedFilePaths(database),
    ).run(),
  );
  tempFileManager.listenToAppLifecycle();
}

/// Every encrypted file path a database row points at, including the file
/// kept for the other phone's version of an open sync conflict.
Future<List<String>> storedFilePaths(AppDatabase database) async {
  final attachments = await database.select(database.attachments).get();
  final voiceNotes = await database.select(database.voiceNotes).get();
  return [
    for (final a in attachments) a.encryptedPath,
    for (final v in voiceNotes) v.encryptedPath,
    ...await conflictStoredFilePaths(database),
  ];
}

Future<void> _guard(String step, Future<Object?> Function() run) async {
  try {
    await run();
  } catch (e) {
    AppLogger.warning('Startup maintenance: $step failed (${e.runtimeType})');
  }
}
