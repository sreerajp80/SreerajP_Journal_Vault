/// Parses a Quill delta into a flat list of blocks the export renderers can
/// walk.
///
/// Entry bodies are stored as Quill delta JSON in `Entries.contentJson`. A
/// delta is a list of ops, and its shape is awkward to render directly: block
/// styling (heading, list, quote) does not sit on the text it applies to, but
/// on the newline that *ends* the line. Every renderer would otherwise have to
/// re-implement that rule.
///
/// This file does it once. [parseDelta] turns ops into [ExportBlock]s, and
/// `delta_to_markdown.dart`, `delta_to_html.dart` and `delta_to_plain_text.dart`
/// each walk that list.
///
/// Pure Dart — no Flutter, no plugins, no database — so it is cheap to test.
///
/// It never throws. Malformed JSON, an op of the wrong type, an unknown embed
/// or an attribute with a surprising value all degrade to something readable.
/// A ten-year journal must not become unexportable because one entry holds an
/// op this code has never seen. (`SreerajP_PDFApp` rule 5 — never crash on bad
/// input.)
library;

import 'dart:convert';

/// How a whole line is styled.
enum BlockStyle {
  paragraph,
  heading1,
  heading2,
  heading3,
  bulletList,
  orderedList,
  checkedList,
  uncheckedList,
  blockquote,
  codeBlock,
}

/// A run of text sharing one set of inline styles.
class InlineSpan {
  const InlineSpan({
    required this.text,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.code = false,
    this.link,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool code;

  /// Target of a link, or null when this run is not a link.
  final String? link;

  bool get hasStyle =>
      bold || italic || underline || strikethrough || code || link != null;

  @override
  String toString() => 'InlineSpan("$text")';
}

/// One block of an exported entry: either a line of text or an embed.
sealed class ExportBlock {
  const ExportBlock();
}

/// A line of text, with its block style and list indent level.
class TextBlock extends ExportBlock {
  const TextBlock({
    required this.spans,
    this.style = BlockStyle.paragraph,
    this.indent = 0,
  });

  final List<InlineSpan> spans;
  final BlockStyle style;

  /// Nesting level for list items. 0 is the outermost level.
  final int indent;

  /// The line's text with all styling dropped.
  String get plainText => spans.map((s) => s.text).join();

  bool get isEmpty => plainText.trim().isEmpty;

  @override
  String toString() => 'TextBlock($style, "$plainText")';
}

/// A table embed. See `table_embed.dart` — stored as a JSON 2D list of strings.
class TableBlock extends ExportBlock {
  const TableBlock(this.rows);

  final List<List<String>> rows;

  @override
  String toString() => 'TableBlock(${rows.length} rows)';
}

/// A callout embed. See `callout_embed.dart` — stored as `{style, text}`.
class CalloutBlock extends ExportBlock {
  const CalloutBlock({required this.style, required this.text});

  /// 'info', 'warning', 'tip' or 'important'. Any other value is kept as-is and
  /// rendered as a plain callout, rather than being rejected.
  final String style;
  final String text;

  @override
  String toString() => 'CalloutBlock($style)';
}

/// An image embedded in the flow of the entry.
///
/// See `image_embed.dart` — stored as `{attachmentId, fileName, widthFactor}`.
/// The picture itself is an encrypted attachment row, so a renderer that wants
/// to show it has to be handed the decrypted bytes; one that cannot names the
/// file instead.
class ImageBlock extends ExportBlock {
  const ImageBlock({required this.attachmentId, required this.fileName});

  final int attachmentId;
  final String fileName;

  @override
  String toString() => 'ImageBlock($attachmentId, "$fileName")';
}

/// A sketch / handwriting drawing embedded in the entry.
///
/// See `drawing_embed.dart` — stored as `{attachmentId, fileName, widthFactor, strokeJson}`.
class DrawingBlock extends ExportBlock {
  const DrawingBlock({
    required this.attachmentId,
    required this.fileName,
    this.strokeJson,
  });

  final int attachmentId;
  final String fileName;
  final String? strokeJson;

  @override
  String toString() => 'DrawingBlock($attachmentId, "$fileName")';
}

/// An embed this app does not know how to render.
///
/// Kept rather than dropped, so an export is honest about there having been
/// something here. A future embed type, or a document written by a newer build,
/// lands here instead of disappearing without trace.
class UnknownEmbedBlock extends ExportBlock {
  const UnknownEmbedBlock(this.type);

  final String type;

  @override
  String toString() => 'UnknownEmbedBlock($type)';
}

/// Parses [contentJson] (a Quill delta) into blocks.
///
/// [fallbackPlainText] is used when the JSON is missing or unusable — normally
/// the entry's own `plainText` column, so a damaged document still exports its
/// words. Returns an empty list when there is nothing at all.
List<ExportBlock> parseDelta(String? contentJson, {String? fallbackPlainText}) {
  final ops = _decodeOps(contentJson);
  if (ops == null) return _blocksFromPlainText(fallbackPlainText);

  final blocks = <ExportBlock>[];
  var pending = <InlineSpan>[];

  void closeLine(Map<String, dynamic> lineAttributes) {
    blocks.add(
      TextBlock(
        spans: _mergeAdjacent(pending),
        style: _styleFrom(lineAttributes),
        indent: _indentFrom(lineAttributes),
      ),
    );
    pending = <InlineSpan>[];
  }

  for (final op in ops) {
    if (op is! Map) continue;
    final insert = op['insert'];
    final attributes = _asAttributes(op['attributes']);

    if (insert is String) {
      // A text insert may hold several lines. Each newline closes the current
      // line, and the attributes on THIS op supply that line's block style —
      // that is the delta rule this whole file exists to centralise.
      final parts = insert.split('\n');
      for (var i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          pending.add(_spanFrom(parts[i], attributes));
        }
        // Every part except the last was followed by a newline.
        if (i < parts.length - 1) closeLine(attributes);
      }
      continue;
    }

    if (insert is Map) {
      // An embed. Quill wraps it as a single-key map: {'table': '<json>'}.
      final block = _embedBlock(insert);
      if (block == null) continue;
      // An embed is a block of its own, so anything buffered before it is its
      // own line first. Without this, text sharing a line with an embed would
      // be swallowed.
      if (pending.isNotEmpty) closeLine(const <String, dynamic>{});
      blocks.add(block);
      continue;
    }
  }

  // A delta normally ends with a newline, so there is usually nothing left. A
  // hand-written or truncated one may not, and that text still belongs in the
  // export.
  if (pending.isNotEmpty) closeLine(const <String, dynamic>{});

  // Quill always keeps a trailing empty paragraph. It is an artefact of the
  // format, not something the user typed, so it does not belong in a file.
  while (blocks.isNotEmpty &&
      blocks.last is TextBlock &&
      (blocks.last as TextBlock).isEmpty &&
      (blocks.last as TextBlock).style == BlockStyle.paragraph) {
    blocks.removeLast();
  }

  if (blocks.isEmpty) return _blocksFromPlainText(fallbackPlainText);
  return blocks;
}

/// Decodes the op list, or null when [contentJson] cannot be used.
List<dynamic>? _decodeOps(String? contentJson) {
  if (contentJson == null || contentJson.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(contentJson);
    if (decoded is List) return decoded;
    // Some Quill versions wrap the list as {'ops': [...]}.
    if (decoded is Map && decoded['ops'] is List) {
      return decoded['ops'] as List;
    }
    return null;
  } on FormatException {
    // Corrupt JSON falls back to the plain-text column rather than failing the
    // whole export.
    return null;
  }
}

/// Last resort: treat the stored plain text as one paragraph per line.
List<ExportBlock> _blocksFromPlainText(String? plainText) {
  final text = plainText?.trim();
  if (text == null || text.isEmpty) return const <ExportBlock>[];
  return text
      .split('\n')
      .map((line) => TextBlock(spans: [InlineSpan(text: line)]) as ExportBlock)
      .toList();
}

Map<String, dynamic> _asAttributes(Object? value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

InlineSpan _spanFrom(String text, Map<String, dynamic> attributes) {
  final link = attributes['link'];
  return InlineSpan(
    text: text,
    bold: attributes['bold'] == true,
    italic: attributes['italic'] == true,
    underline: attributes['underline'] == true,
    strikethrough: attributes['strike'] == true,
    code: attributes['code'] == true,
    link: link is String && link.isNotEmpty ? link : null,
  );
}

/// Joins neighbouring spans that share styling, so a renderer does not emit
/// `**a****b**` for text Quill happened to split into two ops.
List<InlineSpan> _mergeAdjacent(List<InlineSpan> spans) {
  final merged = <InlineSpan>[];
  for (final span in spans) {
    if (span.text.isEmpty) continue;
    final last = merged.isEmpty ? null : merged.last;
    if (last != null &&
        last.bold == span.bold &&
        last.italic == span.italic &&
        last.underline == span.underline &&
        last.strikethrough == span.strikethrough &&
        last.code == span.code &&
        last.link == span.link) {
      merged[merged.length - 1] = InlineSpan(
        text: last.text + span.text,
        bold: last.bold,
        italic: last.italic,
        underline: last.underline,
        strikethrough: last.strikethrough,
        code: last.code,
        link: last.link,
      );
      continue;
    }
    merged.add(span);
  }
  return merged;
}

BlockStyle _styleFrom(Map<String, dynamic> attributes) {
  if (attributes['code-block'] != null && attributes['code-block'] != false) {
    return BlockStyle.codeBlock;
  }
  if (attributes['blockquote'] == true) return BlockStyle.blockquote;

  final header = attributes['header'];
  if (header is int) {
    // The editor's toolbar offers three levels. Anything deeper from an
    // imported document is clamped rather than dropped.
    if (header == 1) return BlockStyle.heading1;
    if (header == 2) return BlockStyle.heading2;
    if (header >= 3) return BlockStyle.heading3;
  }

  final list = attributes['list'];
  if (list == 'bullet') return BlockStyle.bulletList;
  if (list == 'ordered') return BlockStyle.orderedList;
  if (list == 'checked') return BlockStyle.checkedList;
  if (list == 'unchecked') return BlockStyle.uncheckedList;

  return BlockStyle.paragraph;
}

int _indentFrom(Map<String, dynamic> attributes) {
  final indent = attributes['indent'];
  if (indent is int && indent > 0) {
    // Guard against a runaway value making a renderer build a huge string.
    return indent > 8 ? 8 : indent;
  }
  return 0;
}

/// Turns a Quill embed map into a block, or null when it holds nothing usable.
ExportBlock? _embedBlock(Map<dynamic, dynamic> insert) {
  if (insert.isEmpty) return null;
  final type = insert.keys.first.toString();
  final data = insert[insert.keys.first];

  switch (type) {
    case 'table':
      final rows = _tableRows(data);
      return rows == null ? const UnknownEmbedBlock('table') : TableBlock(rows);
    case 'callout':
      final callout = _callout(data);
      return callout ?? const UnknownEmbedBlock('callout');
    case 'vault_image':
      final image = _image(data);
      return image ?? const UnknownEmbedBlock('vault_image');
    case 'drawing':
    case 'vault_drawing':
      final drawing = _drawing(data);
      return drawing ?? UnknownEmbedBlock(type);
    default:
      return UnknownEmbedBlock(type);
  }
}

/// Reads a table embed's JSON 2D list of strings. Null when it is unusable.
List<List<String>>? _tableRows(Object? data) {
  if (data is! String) return null;
  try {
    final decoded = jsonDecode(data);
    if (decoded is! List) return null;
    return decoded
        .whereType<List>()
        .map((row) => row.map((cell) => cell?.toString() ?? '').toList())
        .toList();
  } on FormatException {
    return null;
  }
}

/// Reads an image embed's `{attachmentId, fileName}`. Null when it is unusable.
///
/// An embed with no usable attachment id points at nothing, so it is rejected
/// and named as an unknown embed instead of becoming an image the renderers
/// could never find.
ImageBlock? _image(Object? data) {
  if (data is! String) return null;
  try {
    final decoded = jsonDecode(data);
    if (decoded is! Map) return null;
    final rawId = decoded['attachmentId'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null || id <= 0) return null;
    return ImageBlock(
      attachmentId: id,
      fileName: decoded['fileName']?.toString() ?? '',
    );
  } on FormatException {
    return null;
  }
}

/// Reads a drawing embed's `{attachmentId, fileName, strokeJson}`. Null when unusable.
DrawingBlock? _drawing(Object? data) {
  if (data is! String) return null;
  try {
    final decoded = jsonDecode(data);
    if (decoded is! Map) return null;
    final rawId = decoded['attachmentId'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null || id <= 0) return null;
    return DrawingBlock(
      attachmentId: id,
      fileName: decoded['fileName']?.toString() ?? '',
      strokeJson: decoded['strokeJson']?.toString(),
    );
  } on FormatException {
    return null;
  }
}

/// Reads a callout embed's `{style, text}`. Null when it is unusable.
CalloutBlock? _callout(Object? data) {
  if (data is! String) return null;
  try {
    final decoded = jsonDecode(data);
    if (decoded is! Map) return null;
    return CalloutBlock(
      style: decoded['style']?.toString() ?? 'info',
      text: decoded['text']?.toString() ?? '',
    );
  } on FormatException {
    return null;
  }
}
