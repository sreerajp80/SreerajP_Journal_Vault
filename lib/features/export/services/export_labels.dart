/// The words an export writes into its files.
///
/// Layer: services, data only. An export is read later, outside the app, so
/// its headings are in the language the user had chosen when exporting. The
/// screen builds this from `AppLocalizations` (see
/// `presentation/export_text.dart`) and hands it to the services, which never
/// look text up themselves.
library;

import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';

/// Builds the README placed in a zip export.
typedef ExportReadmeBuilder =
    String Function({
      required String journalTitle,
      required String exportedAt,
      required int entryCount,
      required String formatName,
    });

class ExportLabels {
  const ExportLabels({
    required this.untitledEntry,
    required this.date,
    required this.tags,
    required this.mood,
    required this.attachments,
    required this.voiceNotes,
    required this.transcript,
    required this.lockedNotIncluded,
    required this.image,
    required this.drawing,
    required this.imageNotIncluded,
    required this.drawingNotIncluded,
    required this.unexportableBlock,
    required this.calloutNote,
    required this.calloutTip,
    required this.calloutWarning,
    required this.calloutImportant,
    required this.moodValue,
    required this.recording,
    required this.readme,
    required this.formatName,
  });

  final String untitledEntry;
  final String date;
  final String tags;
  final String mood;
  final String attachments;
  final String voiceNotes;
  final String transcript;

  /// Shown in brackets after the name of a locked attachment.
  final String lockedNotIncluded;

  /// Placeholder words for an inline image or drawing that is not embedded.
  final String image;
  final String drawing;

  /// Written after the name of an inline image or drawing a web page could
  /// not embed.
  final String imageNotIncluded;
  final String drawingNotIncluded;

  /// Names an editor block this build cannot write out, so the export is
  /// honest that something was there.
  final String Function(String type) unexportableBlock;

  final String calloutNote;
  final String calloutTip;
  final String calloutWarning;
  final String calloutImportant;

  /// The mood score out of five, e.g. "4 of 5".
  final String Function(int mood) moodValue;

  /// A voice note line with its length, e.g. "Recording (1:05)".
  final String Function(String duration) recording;

  final ExportReadmeBuilder readme;

  /// The name of an export format, as written into the README.
  final String Function(ExportFormat format) formatName;

  /// The label for a callout block. An unknown style keeps its own name rather
  /// than being forced to "Note".
  String calloutLabel(String style) => switch (style) {
    'warning' => calloutWarning,
    'tip' => calloutTip,
    'important' => calloutImportant,
    'info' || '' => calloutNote,
    _ => style,
  };
}
