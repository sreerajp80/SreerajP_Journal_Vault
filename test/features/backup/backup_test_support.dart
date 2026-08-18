import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';

/// Argon2id at its real settings takes seconds per call in pure Dart. Tests
/// use the smallest legal settings; the format is identical either way,
/// because a version 2 archive records the settings it was written with.
VaultEnvelope testEnvelope() => VaultEnvelope(
  kdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
  legacyKdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
);

/// A password long enough to pass validation.
const String testBackupPassword = 'correct-horse-battery';

/// In-memory stand-in for attachment storage.
///
/// "Encryption" here is a byte flip: enough to prove that restore decrypts
/// what backup encrypted, and that a file re-encrypted on restore is not the
/// same bytes that sat in the archive.
class FakeBackupAttachmentCipher implements BackupAttachmentCipher {
  FakeBackupAttachmentCipher({this.failOnFileName});

  /// Files currently "stored", keyed by path.
  final Map<String, Uint8List> files = {};

  /// Makes [encryptFromBytes] throw for one file name, to exercise the
  /// partial-failure path.
  final String? failOnFileName;

  int _counter = 0;
  static const int _keyByte = 0x5a;

  static Uint8List _flip(List<int> bytes) =>
      Uint8List.fromList(bytes.map((b) => b ^ _keyByte).toList());

  /// Seeds a stored file as if the app had written it, and returns its path.
  String seedStoredFile(List<int> plainBytes, {String name = 'seed'}) {
    final path = 'stored/${_counter++}_$name';
    files[path] = _flip(plainBytes);
    return path;
  }

  @override
  Future<Uint8List> decryptToBytes({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) async {
    final stored = files[encryptedPath];
    if (stored == null) {
      throw StateError('no such stored file');
    }
    return _flip(stored);
  }

  @override
  Future<BackupStoredFile> encryptFromBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    if (failOnFileName != null && fileName == failOnFileName) {
      throw StateError('storage full');
    }
    final path = 'stored/${_counter++}_$fileName';
    files[path] = _flip(bytes);
    return BackupStoredFile(
      encryptedPath: path,
      nonceBase64: 'nonce-$path',
      keyReference: 'attachment_key_v1',
      sizeBytes: bytes.length,
    );
  }

  @override
  Future<String> storeRawEncryptedBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    final path = 'stored/${_counter++}_$fileName';
    files[path] = Uint8List.fromList(bytes);
    return path;
  }

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {
    files.remove(encryptedPath);
  }
}

/// Ids of the rows [seedJournalData] created, so tests can assert on them.
class SeededData {
  const SeededData({
    required this.journalId,
    required this.entryId,
    required this.tagId,
    required this.attachmentId,
    required this.attachmentBytes,
  });

  final int journalId;
  final int entryId;
  final int tagId;
  final int attachmentId;
  final List<int> attachmentBytes;
}

/// Fills [db] with one of everything the backup carries.
Future<SeededData> seedJournalData(
  AppDatabase db,
  FakeBackupAttachmentCipher cipher, {
  String journalTitle = 'Travel',
  String entryTitle = 'First day',
}) async {
  final createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);

  final journalId = await db
      .into(db.journals)
      .insert(
        JournalsCompanion.insert(
          title: journalTitle,
          description: const Value('A trip'),
          createdAt: Value(createdAt),
          updatedAt: Value(createdAt),
        ),
      );

  final entryId = await db
      .into(db.entries)
      .insert(
        EntriesCompanion.insert(
          journalId: journalId,
          title: Value(entryTitle),
          contentJson: const Value('[{"insert":"hello\\n"}]'),
          plainText: const Value('hello'),
          entryDate: Value(createdAt),
          createdAt: Value(createdAt),
          updatedAt: Value(createdAt),
        ),
      );

  final tagId = await db
      .into(db.tags)
      .insert(
        TagsCompanion.insert(
          name: 'holiday',
          colorArgb: const Value(0xff112233),
          createdAt: Value(createdAt),
          updatedAt: Value(createdAt),
        ),
      );

  await db
      .into(db.entryTags)
      .insert(EntryTagsCompanion.insert(entryId: entryId, tagId: tagId));
  await db
      .into(db.journalTags)
      .insert(JournalTagsCompanion.insert(journalId: journalId, tagId: tagId));

  final attachmentBytes = List<int>.generate(64, (i) => i);
  final storedPath = cipher.seedStoredFile(attachmentBytes, name: 'photo.jpg');
  final attachmentId = await db
      .into(db.attachments)
      .insert(
        AttachmentsCompanion.insert(
          entryId: entryId,
          fileName: 'photo.jpg',
          mimeType: const Value('image/jpeg'),
          encryptedPath: storedPath,
          nonceBase64: 'nonce',
          keyReference: 'attachment_key_v1',
          sizeBytes: attachmentBytes.length,
          createdAt: Value(createdAt),
        ),
      );

  await db
      .into(db.entryRevisions)
      .insert(
        EntryRevisionsCompanion.insert(
          entryId: entryId,
          title: const Value('First day'),
          plainText: const Value('hello'),
          createdAt: Value(createdAt),
        ),
      );

  await db
      .into(db.entryMoods)
      .insert(
        EntryMoodsCompanion.insert(
          entryId: entryId,
          mood: 4,
          note: const Value('good day'),
          createdAt: Value(createdAt),
          updatedAt: Value(createdAt),
        ),
      );

  await db
      .into(db.searchPresets)
      .insert(
        SearchPresetsCompanion.insert(
          name: 'Holidays',
          query: 'tag:holiday',
          createdAt: Value(createdAt),
          updatedAt: Value(createdAt),
        ),
      );

  await db
      .into(db.backlinks)
      .insert(
        BacklinksCompanion.insert(
          sourceEntryId: entryId,
          targetType: 'journal',
          targetId: journalId,
        ),
      );

  return SeededData(
    journalId: journalId,
    entryId: entryId,
    tagId: tagId,
    attachmentId: attachmentId,
    attachmentBytes: attachmentBytes,
  );
}

/// Creates a throwaway directory for backup files.
Future<Directory> createTempBackupDir() =>
    Directory.systemTemp.createTemp('journal_vault_backup_test_');
