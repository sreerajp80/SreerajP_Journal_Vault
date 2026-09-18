/// The formats an export can be written in.
///
/// The visible name and hint of each format are localized in
/// `presentation/export_text.dart`.
library;

/// A format the user can export to.
enum ExportFormat {
  markdown,
  html,
  plainText,
  pdf;

  /// File extension, without the dot.
  String get extension {
    switch (this) {
      case ExportFormat.markdown:
        return 'md';
      case ExportFormat.html:
        return 'html';
      case ExportFormat.plainText:
        return 'txt';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  /// MIME type, used when handing the file to the system save dialog.
  String get mimeType {
    switch (this) {
      case ExportFormat.markdown:
        return 'text/markdown';
      case ExportFormat.html:
        return 'text/html';
      case ExportFormat.plainText:
        return 'text/plain';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }

  /// Whether this format needs the native renderer, and so can be unavailable.
  ///
  /// Only PDF does. The other three are produced in pure Dart and work
  /// everywhere, which is why an unavailable renderer never blocks an export
  /// outright.
  bool get needsNativeRenderer => this == ExportFormat.pdf;

  /// Whether a multi-entry export of this format is one file or many.
  ///
  /// HTML and PDF put every entry in a single document, with a page break
  /// between them. Markdown and plain text produce one file per entry, because
  /// a single huge text file is worse to work with than a folder of them —
  /// and because one file per entry is what re-importing expects.
  bool get combinesEntriesIntoOneFile =>
      this == ExportFormat.html || this == ExportFormat.pdf;
}
