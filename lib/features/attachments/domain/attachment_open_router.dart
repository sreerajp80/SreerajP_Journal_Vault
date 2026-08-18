import 'package:open_filex/open_filex.dart';

import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';

/// Signature of the platform call that hands a decrypted file to another app.
/// Defaults to [OpenFilex.open]; injectable so tests can drive every
/// [ResultType] without a real platform channel.
typedef AttachmentFileOpener =
    Future<OpenResult> Function(String filePath, {String? type});

/// Routes an [AttachmentOpenPrepared] result to the platform file opener.
class AttachmentOpenRouter {
  AttachmentOpenRouter({AttachmentFileOpener? opener})
    : _opener = opener ?? _defaultOpener;

  final AttachmentFileOpener _opener;

  static Future<OpenResult> _defaultOpener(String filePath, {String? type}) =>
      OpenFilex.open(filePath, type: type);

  /// Determines how the attachment should be opened based on [fileName] and [mimeType].
  AttachmentOpenDecision resolve({
    required String fileName,
    required String? mimeType,
  }) {
    final mime = (mimeType ?? '').toLowerCase();
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';

    if (mime == 'application/pdf' || ext == 'pdf') {
      return const AttachmentOpenDecision(kind: AttachmentOpenKind.inAppPdf);
    }
    if (mime.startsWith('audio/')) {
      return const AttachmentOpenDecision(kind: AttachmentOpenKind.inAppAudio);
    }
    if (mime == 'application/zip' || ext == 'zip') {
      return const AttachmentOpenDecision(
        kind: AttachmentOpenKind.inAppArchive,
      );
    }
    if (mime == 'application/x-7z-compressed' || ext == '7z') {
      return const AttachmentOpenDecision(
        kind: AttachmentOpenKind.externalOnly,
      );
    }
    return const AttachmentOpenDecision(kind: AttachmentOpenKind.unsupported);
  }

  /// Launches the platform intent/activity to open the prepared file.
  ///
  /// Throws [AttachmentOpenException] on every non-success result so the caller
  /// can show the matching failure dialog. The decrypted temp file is left in
  /// place — the receiving app still needs it, and
  /// `AttachmentTempFileManager` owns its cleanup.
  Future<void> open(AttachmentOpenPrepared prepared) async {
    final OpenResult result;
    try {
      result = await _opener(prepared.tempFilePath, type: prepared.mimeType);
    } catch (_) {
      // A platform-channel failure is indistinguishable from "nothing can
      // handle this file" from the user's side.
      throw AttachmentOpenException(AttachmentOpenFailure.noCompatibleApp);
    }

    switch (result.type) {
      case ResultType.done:
        return;
      case ResultType.fileNotFound:
        throw AttachmentOpenException(AttachmentOpenFailure.fileNotFound);
      case ResultType.permissionDenied:
        throw AttachmentOpenException(AttachmentOpenFailure.permissionDenied);
      case ResultType.noAppToOpen:
      case ResultType.error:
        throw AttachmentOpenException(AttachmentOpenFailure.noCompatibleApp);
    }
  }
}
