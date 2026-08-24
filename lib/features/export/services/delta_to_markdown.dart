/// Renders parsed entry blocks as Markdown.
///
/// The mirror of `markdown_import_adapter.dart`: what that file reads, this
/// file writes. Round-tripping an entry through export then import should give
/// back the same document for everything the importer understands.
///
/// Pure Dart — no Flutter, no plugins — so it is cheap to test.
library;

import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_document.dart';

/// Turns [blocks] into a Markdown document.
///
/// [linkableImageIds] are the attachments whose files are travelling with the
/// Markdown, in the `attachments/` folder beside it. An inline image in that
/// set becomes a real Markdown image and shows in any reader; one that is not
/// (attachments were not included, or the file was locked or unreadable) is
/// named in italics instead, because a link to a file that is not there would
/// be worse than none.
String renderMarkdown(
  List<ExportBlock> blocks, {
  Set<int> linkableImageIds = const {},
}) {
  final buffer = StringBuffer();
  // Ordered lists restart at 1 for each run, and each indent level counts
  // separately, so "1. 2. 3." stays right when a nested list interrupts.
  final counters = <int, int>{};
  BlockStyle? previousStyle;
  var previousIndent = 0;

  for (final block in blocks) {
    switch (block) {
      case TextBlock():
        final isList = _isList(block.style);
        // A counter resets when the list ends or the nesting changes.
        if (!isList || block.style != previousStyle) {
          counters.clear();
        } else if (block.indent < previousIndent) {
          counters.removeWhere((level, _) => level > block.indent);
        }

        // Markdown needs a blank line between a paragraph and a list, or the
        // list is rendered as part of the paragraph.
        if (_needsBlankLineBetween(previousStyle, block.style)) {
          buffer.writeln();
        }

        buffer.writeln(_renderTextBlock(block, counters));
        previousStyle = block.style;
        previousIndent = block.indent;

      case TableBlock():
        buffer.writeln();
        buffer.write(_renderTable(block.rows));
        previousStyle = null;
        previousIndent = 0;

      case CalloutBlock():
        buffer.writeln();
        buffer.writeln(_renderCallout(block));
        previousStyle = null;
        previousIndent = 0;

      case ImageBlock():
        buffer.writeln();
        buffer.writeln(
          _renderImage(block, linkableImageIds.contains(block.attachmentId)),
        );
        previousStyle = null;
        previousIndent = 0;

      case DrawingBlock():
        buffer.writeln();
        buffer.writeln(
          _renderDrawing(block, linkableImageIds.contains(block.attachmentId)),
        );
        previousStyle = null;
        previousIndent = 0;

      case UnknownEmbedBlock():
        // Named rather than dropped, so the export is honest that something
        // was here that this build could not write out.
        buffer.writeln();
        buffer.writeln('> _[${block.type} block — not exportable as text]_');
        previousStyle = null;
        previousIndent = 0;
    }
  }

  return buffer.toString().trimRight();
}

bool _isList(BlockStyle style) =>
    style == BlockStyle.bulletList ||
    style == BlockStyle.orderedList ||
    style == BlockStyle.checkedList ||
    style == BlockStyle.uncheckedList;

bool _needsBlankLineBetween(BlockStyle? previous, BlockStyle next) {
  if (previous == null) return false;
  if (previous == next) return false;
  // Entering or leaving a list, quote or code block needs the separation.
  return _isList(previous) ||
      _isList(next) ||
      previous == BlockStyle.blockquote ||
      next == BlockStyle.blockquote ||
      previous == BlockStyle.codeBlock ||
      next == BlockStyle.codeBlock;
}

String _renderTextBlock(TextBlock block, Map<int, int> counters) {
  final indent = '  ' * block.indent;

  // A code block is verbatim: inline styling inside it is not real, and
  // escaping would corrupt the code.
  if (block.style == BlockStyle.codeBlock) {
    return '$indent    ${block.plainText}';
  }

  final text = _renderSpans(block.spans);

  switch (block.style) {
    case BlockStyle.heading1:
      return '# $text';
    case BlockStyle.heading2:
      return '## $text';
    case BlockStyle.heading3:
      return '### $text';
    case BlockStyle.bulletList:
      return '$indent- $text';
    case BlockStyle.orderedList:
      final n = (counters[block.indent] ?? 0) + 1;
      counters[block.indent] = n;
      return '$indent$n. $text';
    case BlockStyle.checkedList:
      return '$indent- [x] $text';
    case BlockStyle.uncheckedList:
      return '$indent- [ ] $text';
    case BlockStyle.blockquote:
      return '> $text';
    case BlockStyle.codeBlock:
    case BlockStyle.paragraph:
      return text;
  }
}

/// Renders inline styling. Order matters: the link wraps everything else, and
/// inline code is verbatim inside its backticks.
String _renderSpans(List<InlineSpan> spans) {
  final buffer = StringBuffer();
  for (final span in spans) {
    if (span.text.isEmpty) continue;

    if (span.code) {
      // Text inside backticks is literal, so it is not escaped. A backtick in
      // the text is handled by widening the fence around it.
      buffer.write(_inlineCode(span.text));
      continue;
    }

    // Markdown only applies emphasis when the marker touches a non-space
    // character, so leading and trailing spaces move outside the markers.
    final leading = _leadingSpace(span.text);
    final trailing = _trailingSpace(span.text);
    final core = span.text.substring(
      leading.length,
      span.text.length - trailing.length,
    );

    if (core.isEmpty) {
      buffer.write(span.text);
      continue;
    }

    var rendered = _escapeMarkdown(core);
    if (span.bold) rendered = '**$rendered**';
    if (span.italic) rendered = '_${rendered}_';
    if (span.strikethrough) rendered = '~~$rendered~~';
    // Markdown has no underline. HTML is valid inside Markdown and every
    // renderer supports it, which is better than silently losing the styling.
    if (span.underline) rendered = '<u>$rendered</u>';
    if (span.link != null) rendered = '[$rendered](${span.link})';

    buffer
      ..write(leading)
      ..write(rendered)
      ..write(trailing);
  }
  return buffer.toString();
}

String _leadingSpace(String text) {
  final match = RegExp(r'^\s+').firstMatch(text);
  return match?.group(0) ?? '';
}

String _trailingSpace(String text) {
  final match = RegExp(r'\s+$').firstMatch(text);
  return match?.group(0) ?? '';
}

/// Wraps [text] in enough backticks that any backticks inside it stay literal.
String _inlineCode(String text) {
  var longestRun = 0;
  var run = 0;
  for (final unit in text.codeUnits) {
    run = unit == 0x60 ? run + 1 : 0;
    if (run > longestRun) longestRun = run;
  }
  final fence = '`' * (longestRun + 1);
  // A space is needed when the text itself starts or ends with a backtick.
  final pad = text.startsWith('`') || text.endsWith('`') ? ' ' : '';
  return '$fence$pad$text$pad$fence';
}

/// Escapes the characters that would otherwise be read as Markdown syntax.
///
/// Only the ones that actually matter mid-line. Over-escaping makes the file
/// unpleasant to read, and the file being readable is half the point of
/// choosing Markdown.
String _escapeMarkdown(String text) => text
    .replaceAll(r'\', r'\\')
    .replaceAll('*', r'\*')
    .replaceAll('_', r'\_')
    .replaceAll('`', r'\`')
    .replaceAll('[', r'\[')
    .replaceAll(']', r'\]');

/// Renders a table as a Markdown pipe table.
///
/// The first row becomes the header, because a pipe table has no way to say
/// "no header" and most renderers will not draw the table without one.
String _renderTable(List<List<String>> rows) {
  if (rows.isEmpty) return '';

  final width = rows.fold<int>(0, (m, row) => row.length > m ? row.length : m);
  if (width == 0) return '';

  String renderRow(List<String> row) {
    final cells = List.generate(width, (i) {
      final cell = i < row.length ? row[i] : '';
      // A pipe inside a cell would end it early; a newline would end the row.
      return cell
          .replaceAll('|', r'\|')
          .replaceAll('\n', ' ')
          .replaceAll('\r', ' ')
          .trim();
    });
    return '| ${cells.join(' | ')} |';
  }

  final buffer = StringBuffer()
    ..writeln(renderRow(rows.first))
    ..writeln('| ${List.filled(width, '---').join(' | ')} |');
  for (final row in rows.skip(1)) {
    buffer.writeln(renderRow(row));
  }
  return buffer.toString();
}

/// Renders an inline image, as a real Markdown image when its file came along.
String _renderImage(ImageBlock block, bool linkToAttachments) {
  final label = block.fileName.isEmpty ? 'Image' : block.fileName;
  if (!linkToAttachments) return '_[Image: ${_escapeMarkdown(label)}]_';

  final path =
      'attachments/${exportAttachmentFileName(block.attachmentId, block.fileName)}';
  // The alt text is escaped; the path is not — it went through safeFileName,
  // which has already removed everything that could break the link.
  return '![${_escapeMarkdown(label)}]($path)';
}

/// Renders an inline drawing, as a real Markdown image when its file came along.
String _renderDrawing(DrawingBlock block, bool linkToAttachments) {
  final label = block.fileName.isEmpty ? 'Drawing' : block.fileName;
  if (!linkToAttachments) return '_[Drawing: ${_escapeMarkdown(label)}]_';

  final path =
      'attachments/${exportAttachmentFileName(block.attachmentId, block.fileName)}';
  return '![${_escapeMarkdown(label)}]($path)';
}

/// Renders a callout as a blockquote with its style named in bold.
///
/// This is the closest thing plain Markdown has to an admonition, and it
/// survives every renderer. GitHub's `> [!NOTE]` syntax was not used because it
/// renders as literal text everywhere else.
String _renderCallout(CalloutBlock block) {
  final label = _calloutLabel(block.style);
  final lines = block.text.split('\n');
  final buffer = StringBuffer('> **$label**');
  for (final line in lines) {
    buffer.write('\n> ${_escapeMarkdown(line)}');
  }
  return buffer.toString();
}

String _calloutLabel(String style) {
  switch (style) {
    case 'warning':
      return 'Warning';
    case 'tip':
      return 'Tip';
    case 'important':
      return 'Important';
    case 'info':
      return 'Note';
    default:
      // An unknown style keeps its own name rather than being forced to 'Note'.
      return style.isEmpty ? 'Note' : style;
  }
}
