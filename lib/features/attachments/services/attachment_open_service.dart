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
  /// Returns the id of the new attachment row, which is what an inline image
  /// embed stores. Deletes the encrypted file if the database write fails.
  Future<int> importToEntry({
    required AppDatabase database,
    required int entryId,
    required PickedAttachmentData picked,
  }) async {
    final payload = await _storage.encryptAndStore(
      sourceBytes: picked.bytes,
      sourceFileName: picked.fileName,
    );
    try {
      return await database.attachmentsDao.createAttachment(
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

/// An attachment decrypted to a temp file and ready to be shown or handed off.
///
/// The plaintext lives only in the app cache. Whoever holds the session owns
/// its lifetime and must call [close] — the in-app viewer does so on dispose.
/// For an external hand-off the file is deliberately left in place, because the
/// receiving app still needs it; `AttachmentTempFileManager` sweeps it later.
class AttachmentOpenSession {
  const AttachmentOpenSession({
    required this.handle,
    required this.decision,
    required this.fileName,
    required this.mimeType,
  });

  final AttachmentTempFileHandle handle;
  final AttachmentOpenDecision decision;
  final String fileName;
  final String? mimeType;

  /// Path of the decrypted plaintext file in the app cache.
  String get filePath => handle.file.path;

  /// True when this attachment is rendered by one of the in-app viewers.
  bool get opensInApp => switch (decision.kind) {
    AttachmentOpenKind.inAppPdf ||
    AttachmentOpenKind.inAppAudio ||
    AttachmentOpenKind.inAppArchive => true,
    AttachmentOpenKind.externalOnly || AttachmentOpenKind.unsupported => false,
  };

  /// Deletes the decrypted temp file.
  Future<void> close() => handle.release();
}

/// Service that decrypts an attachment to a temp file and opens it.
class AttachmentOpenService {
  AttachmentOpenService({required this._storage, required this._router});

  final AttachmentCryptoStorage _storage;
  final AttachmentOpenRouter _router;

  /// Decrypts the attachment and decides how it should be shown.
  ///
  /// Nothing is launched here — the caller inspects
  /// [AttachmentOpenSession.opensInApp] and either pushes the in-app viewer or
  /// calls [openExternally].
  Future<AttachmentOpenSession> prepare(Attachment attachment) async {
    final handle = await _storage.decryptToTempFile(
      encryptedPath: attachment.encryptedPath,
      nonceBase64: attachment.nonceBase64,
      keyReference: attachment.keyReference,
      fileName: attachment.fileName,
    );

    return AttachmentOpenSession(
      handle: handle,
      decision: _router.resolve(
        fileName: attachment.fileName,
        mimeType: attachment.mimeType,
      ),
      fileName: attachment.fileName,
      mimeType: attachment.mimeType,
    );
  }

  /// Hands a prepared session to another app via the platform file opener.
  Future<AttachmentOpenPrepared> openExternally(
    AttachmentOpenSession session,
  ) async {
    final prepared = AttachmentOpenPrepared(
      tempFilePath: session.filePath,
      mimeType: session.mimeType,
    );
    await _router.open(prepared);
    return prepared;
  }

  /// Decrypts the attachment and hands it straight to another app.
  ///
  /// Kept for callers that always want the external hand-off regardless of
  /// type. In-app rendering goes through [prepare] instead.
  Future<AttachmentOpenPrepared> prepareOpen(Attachment attachment) async {
    final session = await prepare(attachment);
    return openExternally(session);
  }
}
