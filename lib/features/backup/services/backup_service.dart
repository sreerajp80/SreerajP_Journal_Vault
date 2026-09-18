import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/backup_format.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';

part 'backup_service_models.dart';

/// Creates and verifies encrypted backup archives.
///
/// Layer: service. Reads the database and writes files; knows nothing about
/// widgets or navigation.
///
/// A backup is a ZIP sealed by [VaultEnvelope] (AES-256-GCM under a key
/// derived from the user's password). Inside:
///
/// - `manifest.json` — format version, database schema version, counts.
/// - `database.json` — every user-data table as JSON rows.
/// - `attachments/<id>` and `voice_notes/<id>` — the files themselves.
///
/// **Format version 2 stores those files as plain bytes** inside the sealed
/// container, rather than copying them still encrypted with the device key as
/// version 1 did. Version 1 archives could only ever be opened again on the
/// device that wrote them, which made them useless for the case a backup
/// exists for. The trade-off is that the backup password is now the only
/// thing protecting attachment content in the file — see `docs/security.md`.
class BackupService {
  BackupService(
    this._db, {
    this.cipher,
    VaultEnvelope? envelope,
    this.backupDirectoryProvider,
  }) : _envelope = envelope ?? VaultEnvelope();

  final AppDatabase _db;

  /// Decrypts attachment files on the way out. Null means the archive is
  /// written without file contents — rows only.
  final BackupAttachmentCipher? cipher;

  final VaultEnvelope _envelope;

  /// Where backup files are written. Defaults to `backups/` inside the app's
  /// documents directory; injectable so tests can use a temporary folder.
  final Future<Directory> Function()? backupDirectoryProvider;

  /// Creates an encrypted backup archive.
  ///
  /// [password] must be at least [minimumVaultPasswordLength] characters.
  Future<BackupResult> createBackup({
    required String password,
    String triggerType = 'manual',
  }) async {
    validateVaultPassword(password);

    final logId = await _db.backupLogsDao.createLog(
      BackupLogsCompanion.insert(
        status: 'in_progress',
        trigger: Value(triggerType),
      ),
    );

    try {
      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = p.join(
        backupDir.path,
        'journal_backup_$timestamp.vault',
      );

      final dbExport = await _exportDatabase();
      final tableCounts = {
        for (final entry in dbExport.entries)
          entry.key: (entry.value as List<dynamic>).length,
      };
      final entryCount = tableCounts['entries'] ?? 0;
      final attachmentCount = tableCounts['attachments'] ?? 0;

      final manifest = BackupManifest(
        formatVersion: backupFormatVersion,
        schemaVersion: _db.schemaVersion,
        createdAt: DateTime.now(),
        entryCount: entryCount,
        attachmentCount: attachmentCount,
        journalCount: tableCounts['journals'] ?? 0,
        tableCounts: tableCounts,
      );

      final archive = Archive();
      archive.addFile(
        _archiveFileFromString(
          backupManifestFileName,
          jsonEncode(manifest.toJson()),
        ),
      );
      archive.addFile(
        _archiveFileFromString(backupDatabaseFileName, jsonEncode(dbExport)),
      );

      final fileReport = await _addPayloadFiles(archive, dbExport);

      final zipBytes = ZipEncoder().encode(archive);
      final sealed = await _envelope.seal(
        plainBytes: Uint8List.fromList(zipBytes),
        password: password,
      );

      final file = File(backupPath);
      await file.writeAsBytes(sealed, flush: true);
      final sizeBytes = await file.length();

      await _db.backupLogsDao.updateLog(
        logId,
        BackupLogsCompanion(
          status: const Value('success'),
          backupPath: Value(backupPath),
          sizeBytes: Value(sizeBytes),
          entryCount: Value(entryCount),
          attachmentCount: Value(attachmentCount),
          completedAt: Value(DateTime.now()),
        ),
      );
      await _db.backupLogsDao.deleteOldLogs();

      return BackupResult(
        path: backupPath,
        sizeBytes: sizeBytes,
        entryCount: entryCount,
        attachmentCount: attachmentCount,
        filesIncluded: fileReport.included,
        filesFailed: fileReport.failed,
      );
    } catch (e) {
      await _db.backupLogsDao.updateLog(
        logId,
        BackupLogsCompanion(
          status: const Value('failed'),
          errorMessage: Value(e.toString()),
          completedAt: Value(DateTime.now()),
        ),
      );
      rethrow;
    }
  }

  /// Checks that a backup file decrypts and holds a readable manifest.
  Future<BackupVerification> verifyBackup({
    required String backupPath,
    required String password,
  }) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        return const BackupVerification(
          isValid: false,
          error: 'Backup file not found',
        );
      }

      final decrypted = await _envelope.open(
        sealedBytes: await file.readAsBytes(),
        password: password,
      );

      final archive = ZipDecoder().decodeBytes(decrypted);
      final manifestFile = archive.findFile(backupManifestFileName);
      if (manifestFile == null) {
        return const BackupVerification(
          isValid: false,
          error: 'Invalid backup: missing manifest',
        );
      }

      final manifest = BackupManifest.fromJson(
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>,
      );

      return BackupVerification(
        isValid: true,
        entryCount: manifest.entryCount,
        attachmentCount: manifest.attachmentCount,
        journalCount: manifest.journalCount,
        createdAt: manifest.createdAt,
        formatVersion: manifest.formatVersion,
      );
    } catch (e) {
      return BackupVerification(
        isValid: false,
        error: 'Verification failed: $e',
      );
    }
  }

  /// Lists the backup files this app has written, newest first.
  ///
  /// Without this the user cannot see that any backup exists, which makes the
  /// restore screen guesswork. Copied from `sreerajp_todo`.
  Future<List<BackupFileInfo>> listBackups() async {
    final backupDir = await _getBackupDirectory();
    if (!await backupDir.exists()) return const [];

    final infos = <BackupFileInfo>[];
    await for (final entity in backupDir.list()) {
      if (entity is! File) continue;
      if (!entity.path.toLowerCase().endsWith('.vault')) continue;
      final stat = await entity.stat();
      infos.add(
        BackupFileInfo(
          path: entity.path,
          fileName: p.basename(entity.path),
          createdAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
    }

    infos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return infos;
  }

  /// Deletes one backup file.
  Future<void> deleteBackup(String backupPath) async {
    final file = File(backupPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _getBackupDirectory() async {
    final provided = backupDirectoryProvider;
    if (provided != null) {
      final dir = await provided();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Adds attachment and voice-note files to [archive] as **plain bytes**.
  ///
  /// A file that cannot be read or decrypted is counted and skipped: one
  /// unreadable attachment must not cost the user the whole backup.
  Future<_PayloadFileReport> _addPayloadFiles(
    Archive archive,
    Map<String, dynamic> dbExport,
  ) async {
    final fileCipher = cipher;
    if (fileCipher == null) {
      return const _PayloadFileReport(included: 0, failed: 0);
    }

    var included = 0;
    var failed = 0;

    Future<void> addOne({
      required Map<String, dynamic> row,
      required String folder,
    }) async {
      final encryptedPath = row['encryptedPath'] as String?;
      final nonce = row['nonceBase64'] as String?;
      final keyReference = row['keyReference'] as String?;
      if (encryptedPath == null || nonce == null || keyReference == null) {
        failed++;
        return;
      }
      try {
        final bytes = await fileCipher.decryptToBytes(
          encryptedPath: encryptedPath,
          nonceBase64: nonce,
          keyReference: keyReference,
          fileName: (row['fileName'] as String?) ?? 'file',
        );
        archive.addFile(
          ArchiveFile('$folder/${row['id']}', bytes.length, bytes),
        );
        included++;
      } catch (_) {
        // Never log the file name or its contents.
        AppLogger.warning('Backup skipped one unreadable payload file');
        failed++;
      }
    }

    for (final row in (dbExport['attachments'] as List<dynamic>)) {
      await addOne(
        row: row as Map<String, dynamic>,
        folder: backupAttachmentsFolder,
      );
    }
    for (final row in (dbExport['voiceNotes'] as List<dynamic>)) {
      await addOne(
        row: row as Map<String, dynamic>,
        folder: backupVoiceNotesFolder,
      );
    }

    return _PayloadFileReport(included: included, failed: failed);
  }

  Future<Map<String, dynamic>> _exportDatabase() async {
    final journals = await _db.journalsDao.getAllJournals();
    final entries = await _db.select(_db.entries).get();
    final tags = await _db.tagsDao.getAllTags();
    final journalTags = await _db.select(_db.journalTags).get();
    final entryTags = await _db.select(_db.entryTags).get();
    final attachments = await _db.select(_db.attachments).get();
    final backlinks = await _db.select(_db.backlinks).get();
    final revisions = await _db.select(_db.entryRevisions).get();
    final voiceNotes = await _db.select(_db.voiceNotes).get();
    final syncMetadata = await _db.select(_db.syncMetadata).get();
    // Added in format version 2. Both are user data that cannot be recreated,
    // and version 1 archives silently lost them.
    final entryMoods = await _db.select(_db.entryMoods).get();
    final searchPresets = await _db.select(_db.searchPresets).get();
    final timeCapsules = await _db.select(_db.timeCapsules).get();

    return {
      'journals': journals
          .map(
            (j) => {
              'id': j.id,
              'title': j.title,
              'description': j.description,
              'isLocked': j.isLocked,
              'credentialReference': j.credentialReference,
              'passwordSaltBase64': j.passwordSaltBase64,
              'passwordVerifierBase64': j.passwordVerifierBase64,
              'passwordIterations': j.passwordIterations,
              'createdAt': j.createdAt.toIso8601String(),
              'updatedAt': j.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'entries': entries
          .map(
            (e) => {
              'id': e.id,
              'journalId': e.journalId,
              'title': e.title,
              'contentJson': e.contentJson,
              'plainText': e.plainText,
              'entryDate': e.entryDate?.toIso8601String(),
              'createdAt': e.createdAt.toIso8601String(),
              'updatedAt': e.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'tags': tags
          .map(
            (t) => {
              'id': t.id,
              'name': t.name,
              'colorArgb': t.colorArgb,
              'createdAt': t.createdAt.toIso8601String(),
              'updatedAt': t.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'journalTags': journalTags
          .map(
            (jt) => {'id': jt.id, 'journalId': jt.journalId, 'tagId': jt.tagId},
          )
          .toList(),
      'entryTags': entryTags
          .map((et) => {'id': et.id, 'entryId': et.entryId, 'tagId': et.tagId})
          .toList(),
      'attachments': attachments
          .map(
            (a) => {
              'id': a.id,
              'entryId': a.entryId,
              'fileName': a.fileName,
              'mimeType': a.mimeType,
              'encryptedPath': a.encryptedPath,
              'nonceBase64': a.nonceBase64,
              'keyReference': a.keyReference,
              'sizeBytes': a.sizeBytes,
              'createdAt': a.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'backlinks': backlinks
          .map(
            (b) => {
              'id': b.id,
              'sourceEntryId': b.sourceEntryId,
              'targetType': b.targetType,
              'targetId': b.targetId,
            },
          )
          .toList(),
      'revisions': revisions
          .map(
            (r) => {
              'id': r.id,
              'entryId': r.entryId,
              'title': r.title,
              'contentJson': r.contentJson,
              'plainText': r.plainText,
              'createdAt': r.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'voiceNotes': voiceNotes
          .map(
            (v) => {
              'id': v.id,
              'entryId': v.entryId,
              'fileName': v.fileName,
              'encryptedPath': v.encryptedPath,
              'nonceBase64': v.nonceBase64,
              'keyReference': v.keyReference,
              'durationMs': v.durationMs,
              'transcript': v.transcript,
              'createdAt': v.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'syncMetadata': syncMetadata
          .map(
            (s) => {
              'id': s.id,
              'recordTable': s.recordTable,
              'localId': s.localId,
              'syncId': s.syncId,
              'version': s.version,
              'deviceId': s.deviceId,
              'isDeleted': s.isDeleted,
              'lastSyncedAt': s.lastSyncedAt?.toIso8601String(),
              'lastModifiedAt': s.lastModifiedAt.toIso8601String(),
            },
          )
          .toList(),
      'entryMoods': entryMoods
          .map(
            (m) => {
              'id': m.id,
              'entryId': m.entryId,
              'mood': m.mood,
              'note': m.note,
              'createdAt': m.createdAt.toIso8601String(),
              'updatedAt': m.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'searchPresets': searchPresets
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'query': s.query,
              'resultType': s.resultType,
              'createdAt': s.createdAt.toIso8601String(),
              'updatedAt': s.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'timeCapsules': timeCapsules
          .map(
            (tc) => {
              'id': tc.id,
              'entryId': tc.entryId,
              'unlockDate': tc.unlockDate.toIso8601String(),
              'sealedAt': tc.sealedAt.toIso8601String(),
              'isOpened': tc.isOpened,
              'openedAt': tc.openedAt?.toIso8601String(),
              'sealedCiphertext': tc.sealedCiphertext,
              'ivBase64': tc.ivBase64,
              'macBase64': tc.macBase64,
              'sealedKeyCiphertext': tc.sealedKeyCiphertext,
              'teaserMessage': tc.teaserMessage,
              'createdAt': tc.createdAt.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  ArchiveFile _archiveFileFromString(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }
}
