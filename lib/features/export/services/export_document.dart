/// The prepared form of what is being exported.
///
/// [ExportCollector] builds these out of the database; the renderers and
/// [ExportService] read them. Nothing here touches the database, Flutter or the
/// file system, so the whole shape is easy to build by hand in a test.
library;

import 'package:sreerajp_journal_vault/core/utils/safe_file_name.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';

/// The name an attachment is written under inside an export's `attachments/`
/// folder.
///
/// One rule in one place: `ExportService` names the file with it, and the
/// Markdown renderer links to it with it. If the two ever disagreed, every
/// inline image in a Markdown export would be a broken link.
///
/// Prefixed with the row id so two entries attaching "photo.jpg" do not
/// collide, and so the file can be traced back to its row.
String exportAttachmentFileName(int attachmentId, String fileName) =>
    '${attachmentId}_${safeFileName(fileName, fallback: 'attachment')}';

/// One entry, ready to be written out.
class ExportDocument {
  const ExportDocument({
    required this.entryId,
    required this.title,
    required this.blocks,
    this.entryDate,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.mood,
    this.moodNote,
    this.attachments = const [],
    this.inlineImages = const [],
    this.voiceNotes = const [],
  });

  final int entryId;

  /// The entry's title, or null when it never had one.
  final String? title;

  /// The body, already parsed out of the Quill delta.
  final List<ExportBlock> blocks;

  /// The date the entry is *about*. Falls back to [createdAt] when not set.
  final DateTime? entryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<String> tags;

  /// 1–5, or null when the user never picked one.
  final int? mood;
  final String? moodNote;

  final List<ExportAttachmentRef> attachments;

  /// The attachments referenced by [ImageBlock]s in [blocks].
  ///
  /// Separate from [attachments] on purpose. These are always collected, even
  /// when the user asked for no attachment files, because an inline image is
  /// part of the page rather than an extra file travelling beside it — an HTML
  /// or PDF export has to be able to draw it. It is not a way past a lock: a
  /// locked image is still refused, by `ExportService`.
  final List<ExportAttachmentRef> inlineImages;

  final List<ExportVoiceNoteRef> voiceNotes;

  /// The date to show and to sort by.
  DateTime? get effectiveDate => entryDate ?? createdAt;

  @override
  String toString() => 'ExportDocument($entryId, "$title")';
}

/// An attachment belonging to an exported entry.
///
/// Holds what is needed to decrypt the file, but never the bytes — those are
/// read one at a time so a journal full of photos does not have to fit in
/// memory all at once.
class ExportAttachmentRef {
  const ExportAttachmentRef({
    required this.attachmentId,
    required this.fileName,
    required this.sizeBytes,
    required this.encryptedPath,
    required this.nonceBase64,
    required this.keyReference,
    this.mimeType,
    this.isLocked = false,
  });

  final int attachmentId;
  final String fileName;
  final int sizeBytes;
  final String encryptedPath;
  final String nonceBase64;
  final String keyReference;
  final String? mimeType;

  /// True when this attachment has a lock on it.
  ///
  /// A locked attachment is named in the export but its bytes are never
  /// written out — see `ExportService`. Locking it was a deliberate act, and an
  /// export must not be a way around it.
  final bool isLocked;
}

/// A voice note belonging to an exported entry.
///
/// Voice notes are rows in the `VoiceNotes` table, not embeds inside the
/// document, so they are collected separately and listed at the end of the
/// entry. The transcript is the part a reader can use, so it is written out as
/// text whenever there is one — even when the audio itself is not included.
class ExportVoiceNoteRef {
  const ExportVoiceNoteRef({
    required this.voiceNoteId,
    required this.fileName,
    required this.durationMs,
    required this.encryptedPath,
    required this.nonceBase64,
    required this.keyReference,
    this.transcript,
  });

  final int voiceNoteId;
  final String fileName;
  final int durationMs;
  final String encryptedPath;
  final String nonceBase64;
  final String keyReference;
  final String? transcript;

  /// The duration as `m:ss`, for the line written above the recording.
  String get formattedDuration {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Everything one export run covers.
class ExportBundle {
  const ExportBundle({
    required this.journalId,
    required this.journalTitle,
    required this.documents,
  });

  final int journalId;
  final String journalTitle;

  /// The entries, in the order they should appear — oldest first, so a journal
  /// reads forward in time the way it was written.
  final List<ExportDocument> documents;

  bool get isEmpty => documents.isEmpty;

  int get entryCount => documents.length;

  /// Every attachment across every entry.
  Iterable<ExportAttachmentRef> get allAttachments =>
      documents.expand((d) => d.attachments);

  /// Every inline image across every entry.
  Iterable<ExportAttachmentRef> get allInlineImages =>
      documents.expand((d) => d.inlineImages);

  /// Every voice note across every entry.
  Iterable<ExportVoiceNoteRef> get allVoiceNotes =>
      documents.expand((d) => d.voiceNotes);
}
