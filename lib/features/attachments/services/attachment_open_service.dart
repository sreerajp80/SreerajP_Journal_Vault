import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_router.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';

/// Encrypts and imports a picked attachment into the database for a given entry.
class AttachmentImportService {
  AttachmentImportService(this._storage);

  final AttachmentCryptoStorage _storage;

  /// Encrypts [picked] and persists the metadata to [database] for [entryId].
  ///
  /// Deletes the encrypted file if the database write fails.
  Future<void> importToEntry({
    required AppDatabase database,
    required int entryId,
    required PickedAttachmentData picked,
  }) async {
    final payload = await _storage.encryptAndStore(
      sourceBytes: picked.bytes,
      sourceFileName: picked.fileName,
    );
    try {
      await database.attachmentsDao.createAttachment(
        AttachmentsCompanion.insert(
          entryId: entryId,
          fileName: picked.fileName,
          mimeType: Value(picked.mimeType),
          encryptedPath: payload.encryptedPath,
          nonceBase64: payload.nonceBase64,
          keyReference: payload.keyReference,
          sizeBytes: payload.sizeBytes,
        ),
      );
    } catch (_) {
      await _storage.deleteStoredFile(payload.encryptedPath);
      rethrow;
    }
  }
}

/// Service that decrypts an attachment to a temp file and opens it.
class AttachmentOpenService {
  AttachmentOpenService({
    required AttachmentCryptoStorage storage,
    required AttachmentOpenRouter router,
  })  : _storage = storage,
        _router = router;

  final AttachmentCryptoStorage _storage;
  final AttachmentOpenRouter _router;

  /// Decrypts the attachment and prepares it for opening.
  Future<AttachmentOpenPrepared> prepareOpen(Attachment attachment) async {
    final handle = await _storage.decryptToTempFile(
      encryptedPath: attachment.encryptedPath,
      nonceBase64: attachment.nonceBase64,
      keyReference: attachment.keyReference,
      fileName: attachment.fileName,
    );

    final prepared = AttachmentOpenPrepared(
      tempFilePath: handle.file.path,
      mimeType: attachment.mimeType,
    );

    await _router.open(prepared);

    return prepared;
  }
}
