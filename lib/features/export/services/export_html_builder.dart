/// Builds the complete, self-contained HTML page for an export.
///
/// The same page serves two jobs: it *is* the `.html` export, and it is what
/// the native WebView prints to produce the `.pdf` export. One builder for both
/// means what a user sees in a browser is what they get on paper.
///
/// **Self-contained is the hard rule.** The fonts are embedded as base64
/// `@font-face` data URIs, so the page contains no URL of any kind and loads
/// nothing. That is what keeps the export offline and keeps the app's
/// no-network promise (`docs/enhancement_ideas.md` A5.3) intact. The WebView
/// blocks network loads as well, so this is belt and braces — but the page must
/// be correct on its own, because the `.html` export is opened in the user's own
/// browser, where this app's WebView settings do not apply.
///
/// Ported from `SreerajP_lyricchord/lib/services/pdf_export_service.dart`, minus
/// its song-sheet width fitting: journal pages are plain A4.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_html.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_document.dart';

/// Loads a bundled asset's bytes. Swapped out in tests so the builder can be
/// exercised without a Flutter asset bundle.
typedef AssetLoader = Future<List<int>> Function(String assetPath);

class ExportHtmlBuilder {
  const ExportHtmlBuilder({this._assetLoader});

  /// Null in the app, where the real Flutter asset bundle is used.
  final AssetLoader? _assetLoader;

  /// CSS family name for the embedded Malayalam font.
  static const String _fontFamily = 'JvMalayalam';

  static const String _regularFontAsset =
      'assets/fonts/NotoSansMalayalam-Regular.ttf';
  static const String _boldFontAsset =
      'assets/fonts/NotoSansMalayalam-Bold.ttf';

  /// Builds the page for [bundle].
  ///
  /// [includeMetadata] adds the date/tags/mood header above each entry.
  /// [exportedAt] is stamped in the page footer.
  /// [imageSources] maps an attachment id to the `data:` URI of an inline
  /// image; anything missing from it is named in the page rather than drawn.
  Future<String> build(
    ExportBundle bundle, {
    bool includeMetadata = true,
    DateTime? exportedAt,
    Map<int, String> imageSources = const {},
  }) async {
    final css = await _buildCss();
    final body = StringBuffer();

    for (final document in bundle.documents) {
      body.write(
        _renderDocument(
          document,
          includeMetadata: includeMetadata,
          imageSources: imageSources,
        ),
      );
    }

    return '<!DOCTYPE html>'
        '<html><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        '<title>${escapeHtml(bundle.journalTitle)}</title>'
        '<style>$css</style></head>'
        '<body>$body</body></html>';
  }

  /// Renders one entry, including its header and its attachment list.
  String _renderDocument(
    ExportDocument document, {
    required bool includeMetadata,
    Map<int, String> imageSources = const {},
  }) {
    final buffer = StringBuffer('<div class="entry">');

    final title = document.title?.trim();
    buffer.write(
      '<h1 class="entry-title">'
      '${escapeHtml(title == null || title.isEmpty ? ExportStrings.untitledEntry : title)}'
      '</h1>',
    );

    if (includeMetadata) {
      final meta = _renderMetadata(document);
      if (meta.isNotEmpty) buffer.write(meta);
    }

    buffer.write(
      '<div class="entry-body">'
      '${renderHtml(document.blocks, imageSources: imageSources)}'
      '</div>',
    );

    // Voice notes are rows on the entry, not embeds in the document, so they
    // are listed after the body. The transcript is written out whether or not
    // the audio came along — it is the part a reader can actually use.
    if (document.voiceNotes.isNotEmpty) {
      buffer.write(_renderVoiceNotes(document));
    }

    if (document.attachments.isNotEmpty) {
      buffer.write(_renderAttachments(document));
    }

    buffer.write('</div>');
    return buffer.toString();
  }

  String _renderMetadata(ExportDocument document) {
    final rows = <String>[];

    final date = document.effectiveDate;
    if (date != null) {
      rows.add(_metaRow(ExportStrings.labelDate, formatDate(date)));
    }
    if (document.tags.isNotEmpty) {
      rows.add(_metaRow(ExportStrings.labelTags, document.tags.join(', ')));
    }
    if (document.mood != null) {
      final note = document.moodNote?.trim();
      final value = note == null || note.isEmpty
          ? ExportStrings.moodValue(document.mood!)
          : '${ExportStrings.moodValue(document.mood!)} — $note';
      rows.add(_metaRow(ExportStrings.labelMood, value));
    }

    if (rows.isEmpty) return '';
    return '<div class="entry-meta">${rows.join()}</div>';
  }

  String _metaRow(String label, String value) =>
      '<div class="meta-row"><span class="meta-label">${escapeHtml(label)}:'
      '</span> <span class="meta-value">${escapeHtml(value)}</span></div>';

  String _renderVoiceNotes(ExportDocument document) {
    final buffer = StringBuffer('<div class="voice-notes">')
      ..write(
        '<h2 class="section-heading">'
        '${escapeHtml(ExportStrings.labelVoiceNotes)}</h2>',
      );

    for (final note in document.voiceNotes) {
      buffer.write('<div class="voice-note">');
      buffer.write(
        '<p class="voice-note-name">'
        '${escapeHtml(ExportStrings.voiceNoteDuration(note.formattedDuration))}'
        ' — ${escapeHtml(note.fileName)}</p>',
      );
      final transcript = note.transcript?.trim();
      if (transcript != null && transcript.isNotEmpty) {
        buffer.write(
          '<p class="transcript-label">'
          '${escapeHtml(ExportStrings.labelTranscript)}</p>'
          '<blockquote class="transcript">${escapeHtml(transcript)}'
          '</blockquote>',
        );
      }
      buffer.write('</div>');
    }

    buffer.write('</div>');
    return buffer.toString();
  }

  String _renderAttachments(ExportDocument document) {
    final buffer = StringBuffer('<div class="attachments">')
      ..write(
        '<h2 class="section-heading">'
        '${escapeHtml(ExportStrings.labelAttachments)}</h2><ul>',
      );

    for (final attachment in document.attachments) {
      // Deliberately not a link. In a PDF or a page opened from a different
      // folder a relative link would simply be broken, and a broken link reads
      // as a bug. The file name is what the reader needs to find it in the
      // attachments folder.
      final suffix = attachment.isLocked ? ' (locked — not included)' : '';
      buffer.write(
        '<li>${escapeHtml(attachment.fileName)}'
        '${escapeHtml(suffix)}</li>',
      );
    }

    buffer.write('</ul></div>');
    return buffer.toString();
  }

  // --- Fonts and CSS --------------------------------------------------------

  Future<String> _buildCss() async {
    final faces = StringBuffer()
      ..write(await _fontFace(_regularFontAsset, bold: false))
      ..write(await _fontFace(_boldFontAsset, bold: true));

    return '''
$faces
/* A4 with a comfortable reading margin. The native renderer sets the page
   size too; this makes the .html export match what the .pdf looks like. */
@page { size: A4; margin: 20mm; }
html, body { margin: 0; padding: 0; }
body {
  font-family: '$_fontFamily', sans-serif;
  color: #1a1a1a;
  line-height: 1.5;
  font-size: 11pt;
}
/* One entry per page in print. The last one must not add a trailing blank
   page, which is why :last-child overrides it. */
.entry { page-break-after: always; }
.entry:last-child { page-break-after: avoid; }
.entry-title {
  font-size: 20pt; font-weight: 700; color: #1E1B4B;
  margin: 0 0 4pt 0; line-height: 1.25;
}
.entry-meta {
  border-left: 2pt solid #C7C4E0; padding-left: 8pt;
  margin: 0 0 12pt 0; color: #4a4a4a; font-size: 9.5pt;
}
.meta-row { margin: 1pt 0; }
.meta-label { font-weight: 700; }
.entry-body h1 { font-size: 16pt; margin: 14pt 0 4pt 0; }
.entry-body h2 { font-size: 13.5pt; margin: 12pt 0 4pt 0; }
.entry-body h3 { font-size: 12pt; margin: 10pt 0 4pt 0; }
.entry-body p { margin: 0 0 6pt 0; }
.entry-body ul, .entry-body ol { margin: 0 0 6pt 0; padding-left: 18pt; }
.entry-body li { margin: 0 0 2pt 0; }
.task-list { list-style: none; padding-left: 4pt; }
.task-mark { margin-right: 4pt; }
blockquote {
  margin: 0 0 6pt 0; padding: 2pt 0 2pt 10pt;
  border-left: 2pt solid #C7C4E0; color: #444;
}
pre.code {
  background: #f4f4f6; padding: 6pt 8pt; border-radius: 3pt;
  /* Long lines must wrap: a PDF page cannot be scrolled sideways. */
  white-space: pre-wrap; word-wrap: break-word;
  font-size: 9.5pt; margin: 0 0 6pt 0;
}
code { font-size: 0.95em; }
table {
  border-collapse: collapse; width: 100%; margin: 0 0 8pt 0;
  font-size: 10pt;
}
th, td {
  border: 0.5pt solid #bdbdbd; padding: 3pt 5pt;
  text-align: left; vertical-align: top;
}
th { background: #f0eff7; font-weight: 700; }
.callout {
  border-left: 3pt solid #6750A4; background: #f5f3fb;
  padding: 6pt 8pt; margin: 0 0 8pt 0; border-radius: 2pt;
}
.callout p { margin: 0 0 3pt 0; }
.callout p:last-child { margin-bottom: 0; }
.callout-label { font-weight: 700; color: #4a4458; }
.callout-warning { border-left-color: #B3261E; background: #fdf3f2; }
.callout-warning .callout-label { color: #8C1D18; }
.callout-tip { border-left-color: #146C2E; background: #f1f8f2; }
.callout-tip .callout-label { color: #0F5323; }
.callout-important { border-left-color: #7D5260; background: #fbf2f5; }
.callout-important .callout-label { color: #633B48; }
.section-heading {
  font-size: 11pt; font-weight: 700; color: #4a4458;
  margin: 12pt 0 4pt 0; text-transform: uppercase; letter-spacing: 0.04em;
}
.voice-note { margin: 0 0 6pt 0; }
.voice-note-name { margin: 0; font-size: 10pt; }
.transcript-label {
  margin: 3pt 0 1pt 0; font-size: 9pt; font-weight: 700; color: #666;
}
.transcript { font-size: 10pt; }
.attachments ul { margin: 0; padding-left: 16pt; font-size: 10pt; }
.unknown-embed { color: #777; font-style: italic; }
/* Inline images. Capped in height so one photo cannot take a whole printed
   page, and kept off a page boundary so it is never cut in half. */
figure.inline-image { margin: 6pt 0; page-break-inside: avoid; }
figure.inline-image img {
  max-width: 100%; max-height: 120mm; height: auto;
}
''';
  }

  /// Loads a bundled font and returns an `@font-face` rule embedding it as a
  /// base64 data URI.
  Future<String> _fontFace(String asset, {required bool bold}) async {
    final bytes = await _loadAsset(asset);
    final base64Font = base64Encode(bytes);
    final weight = bold ? 700 : 400;
    return "@font-face{font-family:'$_fontFamily';font-weight:$weight;"
        'font-style:normal;src:url(data:font/ttf;base64,$base64Font) '
        'format("truetype");}';
  }

  Future<List<int>> _loadAsset(String asset) async {
    final loader = _assetLoader;
    if (loader != null) return loader(asset);
    final data = await rootBundle.load(asset);
    return data.buffer.asUint8List();
  }
}

/// Formats a date for display inside an export.
///
/// ISO-like and unambiguous (`2026-08-16 14:30`), because an export is read
/// later, possibly in another country. A localised format would be friendlier
/// but would need `intl`, and would change meaning depending on who opens it —
/// `03/04` is two different days in two places.
String formatDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)} '
      '${two(date.hour)}:${two(date.minute)}';
}

/// Formats a date without the time, for file names and range labels.
String formatDateOnly(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}
