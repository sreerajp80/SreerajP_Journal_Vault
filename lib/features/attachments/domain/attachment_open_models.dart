/// How the app should open a particular attachment type.
enum AttachmentOpenKind {
  inAppPdf,
  inAppAudio,
  inAppArchive,
  externalOnly,
  unsupported,
}

/// The routing decision for an attachment based on file name and MIME type.
class AttachmentOpenDecision {
  const AttachmentOpenDecision({required this.kind});

  final AttachmentOpenKind kind;
}

/// Failure reasons when attempting to open an attachment.
enum AttachmentOpenFailure {
  noCompatibleApp,
  decryptFailed,
  fileNotFound,
  permissionDenied,
}

/// Exception thrown when an attachment cannot be opened.
class AttachmentOpenException implements Exception {
  AttachmentOpenException(this.failure);

  final AttachmentOpenFailure failure;

  @override
  String toString() => 'AttachmentOpenException($failure)';
}

/// Result of successfully preparing an attachment for opening.
class AttachmentOpenPrepared {
  const AttachmentOpenPrepared({
    required this.tempFilePath,
    required this.mimeType,
  });

  final String tempFilePath;
  final String? mimeType;
}
