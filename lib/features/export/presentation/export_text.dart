import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_labels.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_service.dart';
import 'package:sreerajp_journal_vault/features/export/services/html_pdf_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

// Layer: presentation.
//
// Turns the export feature's typed results into text in the active language,
// and builds the ExportLabels the services write into exported files.

/// The words for an exported file, in the language of [l10n].
ExportLabels exportLabelsFor(AppLocalizations l10n) {
  return ExportLabels(
    untitledEntry: l10n.descExportFileUntitledEntry,
    date: l10n.descExportFileDate,
    tags: l10n.descExportFileTags,
    mood: l10n.descExportFileMood,
    attachments: l10n.descExportFileAttachments,
    voiceNotes: l10n.descExportFileVoiceNotes,
    transcript: l10n.descExportFileTranscript,
    lockedNotIncluded: l10n.descExportFileLockedNotIncluded,
    image: l10n.descExportFileImage,
    drawing: l10n.descExportFileDrawing,
    imageNotIncluded: l10n.descExportFileImageNotIncluded,
    drawingNotIncluded: l10n.descExportFileDrawingNotIncluded,
    unexportableBlock: l10n.descExportFileUnexportableBlock,
    calloutNote: l10n.descExportFileCalloutNote,
    calloutTip: l10n.descExportFileCalloutTip,
    calloutWarning: l10n.descExportFileCalloutWarning,
    calloutImportant: l10n.descExportFileCalloutImportant,
    moodValue: l10n.descExportFileMoodValue,
    recording: l10n.descExportFileRecording,
    readme:
        ({
          required String journalTitle,
          required String exportedAt,
          required int entryCount,
          required String formatName,
        }) => l10n.bodyExportFileReadme(
          journalTitle,
          exportedAt,
          entryCount,
          formatName,
        ),
    formatName: (format) => format.labelIn(l10n),
  );
}

extension ExportFormatText on ExportFormat {
  /// The name shown to the user.
  String labelIn(AppLocalizations l10n) => switch (this) {
    ExportFormat.markdown => l10n.labelExportFormatMarkdown,
    ExportFormat.html => l10n.labelExportFormatHtml,
    ExportFormat.plainText => l10n.labelExportFormatPlainText,
    ExportFormat.pdf => l10n.labelExportFormatPdf,
  };

  /// One line telling the user what they get.
  String hintIn(AppLocalizations l10n) => switch (this) {
    ExportFormat.markdown => l10n.descExportFormatMarkdown,
    ExportFormat.html => l10n.descExportFormatHtml,
    ExportFormat.plainText => l10n.descExportFormatPlainText,
    ExportFormat.pdf => l10n.descExportFormatPdf,
  };
}

extension ExportOmissionText on ExportOmission {
  String textIn(AppLocalizations l10n) => switch (reason) {
    ExportOmissionReason.lockedAttachment =>
      l10n.bodyExportSkippedLockedAttachment(fileName),
    ExportOmissionReason.unreadableAttachment =>
      l10n.bodyExportSkippedUnreadableAttachment(fileName),
    ExportOmissionReason.unreadableVoiceNote =>
      l10n.bodyExportSkippedUnreadableVoiceNote(fileName),
    ExportOmissionReason.lockedInlineImage =>
      l10n.bodyExportSkippedLockedInlineImage(fileName),
    ExportOmissionReason.unreadableInlineImage =>
      l10n.bodyExportSkippedUnreadableInlineImage(fileName),
  };
}

extension ExportExceptionText on ExportException {
  String textIn(AppLocalizations l10n) => switch (reason) {
    ExportFailureReason.nothingToExport => l10n.errorExportNothing,
  };
}

extension HtmlPdfExceptionText on HtmlPdfException {
  String textIn(AppLocalizations l10n) => switch (failure) {
    HtmlPdfFailure.timedOut => l10n.errorExportPdfTimedOut,
    HtmlPdfFailure.failed => l10n.errorExportPdfFailed,
    HtmlPdfFailure.unavailable => l10n.bodyExportPdfUnavailable,
  };
}
