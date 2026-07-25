import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Manages creation and verification of encrypted backup archives.
///
/// Backups are ZIP archives encrypted with AES-256-GCM. The archive contains:
/// - `manifest.json` — metadata (version, timestamp, entry/attachment counts)
/// - `database.json` — full export of all journals, entries, tags, and relations
/// - `attachments/` — encrypted attachment files (copied as-is since they are
///   already encrypted at rest)
class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  /// Creates an encrypted backup archive.
  ///
  /// [password] is used to derive an AES-256-GCM key via Argon2id.
  /// Returns the path to the created backup file.
  Future<BackupResult> createBackup({
    required String password,
    String triggerType = 'manual',
  }) async {
    // Create backup log entry
    final logId = await _db.backupLogsDao.createLog(
      BackupLogsCompanion.insert(
        status: 'in_progress',
        trigger: Value(triggerType),
      ),
    );

    try {
      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFileName = 'journal_backup_$timestamp.vault';
      final backupPath = p.join(backupDir.path, backupFileName);

      // Export database content
      final dbExport = await _exportDatabase();
      final entryCount = dbExport['entries']?.length ?? 0;
      final attachmentCount = dbExport['attachments']?.length ?? 0;

      // Build manifest
      final manifest = {
        'version': 1,
        'appVersion': '1.0.0',
        'createdAt': DateTime.now().toIso8601String(),
        'entryCount': entryCount,
        'attachmentCount': attachmentCount,
        'journalCount': dbExport['journals']?.length ?? 0,
      };

      // Create ZIP archive
      final archive = Archive();
      archive.addFile(_archiveFileFromString(
          'manifest.json', jsonEncode(manifest)));
      archive.addFile(_archiveFileFromString(
          'database.json', jsonEncode(dbExport)));

      // Add encrypted attachment files
      await _addAttachmentFiles(archive, dbExport['attachments'] ?? []);

      final zipBytes = ZipEncoder().encode(archive);

      // Encrypt the archive
      final encryptedBytes = await _encrypt(
        Uint8List.fromList(zipBytes),
        password,
      );

      // Write to file
      final file = File(backupPath);
      await file.writeAsBytes(encryptedBytes);

      final sizeBytes = await file.length();

      // Update log
      await _db.backupLogsDao.updateLog(logId, BackupLogsCompanion(
        status: const Value('success'),
        backupPath: Value(backupPath),
        sizeBytes: Value(sizeBytes),
        entryCount: Value(entryCount),
        attachmentCount: Value(attachmentCount),
        completedAt: Value(DateTime.now()),
      ));

      // Prune old logs
      await _db.backupLogsDao.deleteOldLogs();

      return BackupResult(
        path: backupPath,
        sizeBytes: sizeBytes,
        entryCount: entryCount,
        attachmentCount: attachmentCount,
      );
    } catch (e) {
      await _db.backupLogsDao.updateLog(logId, BackupLogsCompanion(
        status: const Value('failed'),
        errorMessage: Value(e.toString()),
        completedAt: Value(DateTime.now()),
      ));
      rethrow;
    }
  }

  /// Verifies that a backup file can be decrypted and has a valid manifest.
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

      final encryptedBytes = await file.readAsBytes();
      final decryptedBytes = await _decrypt(encryptedBytes, password);

      final archive = ZipDecoder().decodeBytes(decryptedBytes);
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        return const BackupVerification(
          isValid: false,
          error: 'Invalid backup: missing manifest',
        );
      }

      final manifest = jsonDecode(
        utf8.decode(manifestFile.content as List<int>),
      ) as Map<String, dynamic>;

      return BackupVerification(
        isValid: true,
        entryCount: manifest['entryCount'] as int?,
        attachmentCount: manifest['attachmentCount'] as int?,
        journalCount: manifest['journalCount'] as int?,
        createdAt: manifest['createdAt'] != null
            ? DateTime.tryParse(manifest['createdAt'] as String)
            : null,
      );
    } catch (e) {
      return BackupVerification(
        isValid: false,
        error: 'Verification failed: $e',
      );
    }
  }

  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
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

    return {
      'journals': journals.map((j) => {
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
      }).toList(),
      'entries': entries.map((e) => {
        'id': e.id,
        'journalId': e.journalId,
        'title': e.title,
        'contentJson': e.contentJson,
        'plainText': e.plainText,
        'entryDate': e.entryDate?.toIso8601String(),
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList(),
      'tags': tags.map((t) => {
        'id': t.id,
        'name': t.name,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
      }).toList(),
      'journalTags': journalTags.map((jt) => {
        'id': jt.id,
        'journalId': jt.journalId,
        'tagId': jt.tagId,
      }).toList(),
      'entryTags': entryTags.map((et) => {
        'id': et.id,
        'entryId': et.entryId,
        'tagId': et.tagId,
      }).toList(),
      'attachments': attachments.map((a) => {
        'id': a.id,
        'entryId': a.entryId,
        'fileName': a.fileName,
        'mimeType': a.mimeType,
        'encryptedPath': a.encryptedPath,
        'nonceBase64': a.nonceBase64,
        'keyReference': a.keyReference,
        'sizeBytes': a.sizeBytes,
        'createdAt': a.createdAt.toIso8601String(),
      }).toList(),
      'backlinks': backlinks.map((b) => {
        'id': b.id,
        'sourceEntryId': b.sourceEntryId,
        'targetType': b.targetType,
        'targetId': b.targetId,
      }).toList(),
      'revisions': revisions.map((r) => {
        'id': r.id,
        'entryId': r.entryId,
        'title': r.title,
        'contentJson': r.contentJson,
        'plainText': r.plainText,
        'createdAt': r.createdAt.toIso8601String(),
      }).toList(),
      'voiceNotes': voiceNotes.map((v) => {
        'id': v.id,
        'entryId': v.entryId,
        'fileName': v.fileName,
        'encryptedPath': v.encryptedPath,
        'nonceBase64': v.nonceBase64,
        'keyReference': v.keyReference,
        'durationMs': v.durationMs,
        'transcript': v.transcript,
        'createdAt': v.createdAt.toIso8601String(),
      }).toList(),
      'syncMetadata': syncMetadata.map((s) => {
        'id': s.id,
        'recordTable': s.recordTable,
        'localId': s.localId,
        'syncId': s.syncId,
        'version': s.version,
        'deviceId': s.deviceId,
        'isDeleted': s.isDeleted,
        'lastSyncedAt': s.lastSyncedAt?.toIso8601String(),
        'lastModifiedAt': s.lastModifiedAt.toIso8601String(),
      }).toList(),
    };
  }

  Future<void> _addAttachmentFiles(
    Archive archive,
    List<dynamic> attachments,
  ) async {
    for (final att in attachments) {
      final path = att['encryptedPath'] as String?;
      if (path == null) continue;
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final archivePath = 'attachments/${att['id']}_${att['fileName']}';
        archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
      }
    }
  }

  Future<Uint8List> _encrypt(Uint8List data, String password) async {
    final algorithm = AesGcm.with256bits();
    final keyDerivation = Argon2id(
      parallelism: 1,
      memory: 65536,
      iterations: 3,
      hashLength: 32,
    );

    final secretKey = await keyDerivation.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: List.generate(16, (i) => i), // Fixed salt for backup key derivation
    );

    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      data,
      secretKey: secretKey,
      nonce: nonce,
    );

    // Format: [nonce_length(1)][nonce][mac(16)][ciphertext]
    final output = BytesBuilder();
    output.addByte(nonce.length);
    output.add(nonce);
    output.add(secretBox.mac.bytes);
    output.add(secretBox.cipherText);
    return output.toBytes();
  }

  Future<Uint8List> _decrypt(Uint8List data, String password) async {
    final algorithm = AesGcm.with256bits();
    final keyDerivation = Argon2id(
      parallelism: 1,
      memory: 65536,
      iterations: 3,
      hashLength: 32,
    );

    final secretKey = await keyDerivation.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: List.generate(16, (i) => i),
    );

    final nonceLength = data[0];
    final nonce = data.sublist(1, 1 + nonceLength);
    final mac = Mac(data.sublist(1 + nonceLength, 1 + nonceLength + 16));
    final cipherText = data.sublist(1 + nonceLength + 16);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: mac,
    );

    final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);
    return Uint8List.fromList(decrypted);
  }

  ArchiveFile _archiveFileFromString(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }
}

class BackupResult {
  final String path;
  final int sizeBytes;
  final int entryCount;
  final int attachmentCount;

  const BackupResult({
    required this.path,
    required this.sizeBytes,
    required this.entryCount,
    required this.attachmentCount,
  });
}

class BackupVerification {
  final bool isValid;
  final String? error;
  final int? entryCount;
  final int? attachmentCount;
  final int? journalCount;
  final DateTime? createdAt;

  const BackupVerification({
    required this.isValid,
    this.error,
    this.entryCount,
    this.attachmentCount,
    this.journalCount,
    this.createdAt,
  });
}
