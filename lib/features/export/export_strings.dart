/// Every user-visible string the export feature adds.
///
/// **Status after the 2026-08-18 localisation pass.** The rest of the app now
/// reads its text from `lib/l10n/app_en.arb` through `AppLocalizations`. This
/// file was left in place, because every string in it is produced somewhere a
/// `BuildContext` does not reach:
///
/// - **Exported document content** — the entry headers, the mood value, the
///   voice-note duration and the README written into a bundle. These are part
///   of the exported file's format, not app UI, and they are built by the
///   renderers in `services/`.
/// - **Service-produced messages** — the `ExportOmission` reasons and the PDF
///   failure messages. They are worded in `export_service.dart` and
///   `html_pdf_service.dart` and only later shown on screen.
///
/// **To finish the job** the export feature needs an error model rather than a
/// string: `ExportOmission` should carry a reason enum plus a file name, the
/// PDF failures should be typed exceptions, and `export_screen.dart` should map
/// each one to an ARB key. That is a real refactor of this feature, not a
/// find-and-replace, so it was left out of the localisation pass and recorded
/// in `docs/architecture.md` section 21.
///
/// Rules for anything added here:
///
/// - Every string the user can see lives here — labels, buttons, snackbars,
///   error messages.
/// - The constant name is the future `.arb` key, so nothing gets renamed later.
/// - A string with a value in it is a **function**, not a constant, because
///   that is what `intl` needs. Never build one by joining fragments: word
///   order changes between languages.
///
/// What does **not** belong here: log messages and `SecurityEvents`
/// descriptions. They are never shown to the user and must never be translated,
/// because a support reader needs them in one fixed language.
library;

/// Strings for the export feature. Not instantiable — a namespace only.
class ExportStrings {
  const ExportStrings._();

  // ── Screen and section titles ──────────────────────────────────────────
  static const String screenTitle = 'Export';
  static const String sectionWhat = 'What to export';
  static const String sectionFormat = 'Format';
  static const String sectionOptions = 'Options';

  // ── Scope ──────────────────────────────────────────────────────────────
  static const String scopeThisEntry = 'This entry';
  static const String scopeWholeJournal = 'The whole journal';
  static const String scopeDateRange = 'A date range';
  static const String pickDateRange = 'Choose dates';
  static const String dateRangeNotSet = 'No dates chosen yet';

  /// The journal an export is being taken from.
  static String fromJournal(String journalTitle) => 'From "$journalTitle"';

  /// How many entries the current choice covers.
  static String entriesSelected(int count) =>
      count == 1 ? '1 entry' : '$count entries';

  static String dateRangeLabel(String from, String to) => '$from to $to';

  // ── Formats ────────────────────────────────────────────────────────────
  static const String formatMarkdown = 'Markdown';
  static const String formatHtml = 'Web page (HTML)';
  static const String formatPlainText = 'Plain text';
  static const String formatPdf = 'PDF';

  static const String formatMarkdownHint =
      'Keeps headings, lists and styling. '
      'Opens in any text editor.';
  static const String formatHtmlHint =
      'One page that opens in any browser. '
      'Nothing is loaded from the internet.';
  static const String formatPlainTextHint = 'Just the words, no styling.';
  static const String formatPdfHint = 'Fixed pages, ready to print or share.';

  /// Shown in place of the PDF option when the device cannot render one.
  static const String pdfUnavailable =
      'PDF export is not available on this device. '
      'The other formats still work.';

  // ── Options ────────────────────────────────────────────────────────────
  static const String includeAttachments = 'Include attachments';
  static const String includeAttachmentsHint =
      'Adds a copy of each file and voice note to the export.';
  static const String includeMetadata = 'Include date, tags and mood';
  static const String includeMetadataHint =
      'Adds a short header above each entry.';

  // ── The plain warning about what an export is ──────────────────────────
  //
  // This one is not optional. An export takes content out of an encrypted
  // vault and writes it somewhere the vault does not protect. The user has to
  // be told in one sentence, in the screen itself — not only in a document.
  static const String notEncryptedWarning =
      'The exported file is not encrypted. Anyone who can open the file can '
      'read it. Keep it somewhere safe.';

  // ── The unencrypted-export confirmation ────────────────────────────────
  //
  // Required by `docs/security.md` section 14, which says no plaintext export
  // may be added "without an explicit user confirmation step". The warning
  // card above is passive; this is the deliberate act.
  static const String confirmTitle = 'Export without encryption?';

  static String confirmBody(int entryCount, String formatName) =>
      'This will write ${entryCount == 1 ? '1 entry' : '$entryCount entries'} '
      'to an unencrypted $formatName file. Anyone who can open that file can '
      'read your journal. Keep it somewhere safe, and delete it when you are '
      'done with it.';

  static const String confirmAction = 'Export anyway';

  // ── Actions ────────────────────────────────────────────────────────────
  static const String exportAction = 'Export';
  static const String exporting = 'Exporting…';
  static const String cancel = 'Cancel';
  static const String saveDialogTitle = 'Save export';

  // ── Outcomes ───────────────────────────────────────────────────────────
  static String exportedEntries(int count) =>
      count == 1 ? 'Exported 1 entry.' : 'Exported $count entries.';

  static const String exportCancelled = 'Export cancelled.';
  static const String nothingToExport =
      'There are no entries to export for that choice.';

  static const String exportFailed =
      'Could not finish the export. Nothing was saved.';
  static const String pdfTimedOut =
      'The PDF took too long to build and was stopped. '
      'Try a smaller date range.';
  static const String pdfFailed = 'Could not build the PDF.';

  // ── Things that were left out, and why ─────────────────────────────────
  //
  // An export that quietly omitted something would be worse than one that
  // failed, so every skipped item is named in the outcome list.
  static const String skippedHeading = 'Left out of this export';

  static String skippedLockedAttachment(String fileName) =>
      '$fileName — locked. Unlock it first to include it.';

  static String skippedUnreadableAttachment(String fileName) =>
      '$fileName — the file could not be read.';

  static String skippedUnreadableVoiceNote(String fileName) =>
      '$fileName — the recording could not be read.';

  /// An image inside the writing whose attachment is locked.
  ///
  /// Worded differently from [skippedLockedAttachment] because the reader will
  /// see a gap in the middle of the entry, not a missing file in a folder.
  static String skippedLockedInlineImage(String fileName) =>
      '$fileName — a locked image in the entry body was left out of the page.';

  static String skippedUnreadableInlineImage(String fileName) =>
      '$fileName — an image in the entry body could not be read.';

  // ── Entry headers inside the exported file ─────────────────────────────
  static const String untitledEntry = 'Untitled entry';
  static const String labelDate = 'Date';
  static const String labelTags = 'Tags';
  static const String labelMood = 'Mood';
  static const String labelAttachments = 'Attachments';
  static const String labelVoiceNotes = 'Voice notes';
  static const String labelTranscript = 'Transcript';

  static String moodValue(int mood) => '$mood of 5';

  static String voiceNoteDuration(String duration) => 'Recording ($duration)';

  // ── The README written into a bundle ───────────────────────────────────
  static const String readmeFileName = 'README.txt';

  static String readmeBody({
    required String journalTitle,
    required String exportedAt,
    required int entryCount,
    required String formatName,
  }) =>
      '''
Export from SreerajP Journal Vault

Journal:  $journalTitle
Exported: $exportedAt
Entries:  $entryCount
Format:   $formatName

The "entries" folder holds one file per entry.
The "attachments" folder, if present, holds a copy of the files and voice
notes belonging to those entries.

This export is NOT encrypted. Anyone who can open these files can read them.
''';

  // ── Entry points elsewhere in the app ──────────────────────────────────
  static const String exportDataTile = 'Export Data';
  static const String exportEntryTooltip = 'Export this entry';
  static const String exportJournalTooltip = 'Export this journal';
  static const String chooseJournalToExport = 'Export from journal';
  static const String noJournalsToExport =
      'Create a journal first, then you can export it.';

  /// Shown when every journal the user has is locked.
  static const String allJournalsLocked =
      'Open a locked journal first to export from it.';
}
