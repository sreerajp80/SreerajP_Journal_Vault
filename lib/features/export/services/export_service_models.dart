part of 'export_service.dart';

/// Why something was left out of an export.
enum ExportOmissionReason {
  lockedAttachment,
  unreadableAttachment,
  unreadableVoiceNote,

  /// An image inside the writing whose attachment is locked. Reported apart
  /// from [lockedAttachment] because the reader sees a gap in the middle of
  /// the entry, not a missing file in a folder.
  lockedInlineImage,
  unreadableInlineImage,
}

/// Something that was left out of an export, and why.
class ExportOmission {
  const ExportOmission(this.reason, this.fileName);

  final ExportOmissionReason reason;

  /// The file's own name. User content: shown on screen, never logged.
  final String fileName;

  @override
  String toString() => 'ExportOmission(${reason.name})';
}

/// The finished export, ready to be written to disk.
class ExportResult {
  const ExportResult({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.entryCount,
    this.skipped = const [],
    this.isEncrypted = false,
  });

  final Uint8List bytes;

  /// The suggested file name, including the extension.
  final String fileName;
  final String mimeType;
  final int entryCount;

  /// Everything that could not be included.
  final List<ExportOmission> skipped;

  /// True when [bytes] are sealed under a password rather than readable.
  final bool isEncrypted;

  /// True when the file is a zip bundle. False for a sealed export: what is
  /// inside is not visible from the outside, which is the point.
  bool get isZip => fileName.endsWith('.zip');
}

/// Why an export could not be produced at all.
enum ExportFailureReason { nothingToExport }

/// Thrown when an export cannot be produced at all.
class ExportException implements Exception {
  const ExportException(this.reason);

  final ExportFailureReason reason;

  @override
  String toString() => 'ExportException: ${reason.name}';
}
