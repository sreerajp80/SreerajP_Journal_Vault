import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';

/// Routes an [AttachmentOpenPrepared] result to the platform file opener.
class AttachmentOpenRouter {
  AttachmentOpenRouter();

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
      return const AttachmentOpenDecision(kind: AttachmentOpenKind.inAppArchive);
    }
    if (mime == 'application/x-7z-compressed' || ext == '7z') {
      return const AttachmentOpenDecision(kind: AttachmentOpenKind.externalOnly);
    }
    return const AttachmentOpenDecision(kind: AttachmentOpenKind.unsupported);
  }

  /// Launches the platform intent/activity to open the prepared file.
  Future<void> open(AttachmentOpenPrepared prepared) async {
    // Platform-specific implementation will go here.
    throw UnimplementedError('AttachmentOpenRouter.open not yet implemented');
  }
}
