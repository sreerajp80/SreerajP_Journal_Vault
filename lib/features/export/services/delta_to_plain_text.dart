/// Renders parsed entry blocks as plain text.
///
/// The rule here is that nothing is silently dropped. Plain text cannot show
/// styling, so styling is simply lost — but every piece of *content* survives,
/// including tables, callouts and the fact that an unknown embed was present.
/// A `.txt` export is the format someone falls back to when everything else has
/// failed them, so it must be complete even when it is plain.
///
/// Pure Dart — no Flutter, no plugins — so it is cheap to test.
library;

import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';

/// Turns [blocks] into a plain-text document.
String renderPlainText(List<ExportBlock> blocks) {
  final buffer = StringBuffer();
  final counters = <int, int>{};
  BlockStyle? previousStyle;

  for (final block in blocks) {
    switch (block) {
      case TextBlock():
        if (!_isList(block.style) || block.style != previousStyle) {
          counters.clear();
        }
        buffer.writeln(_renderTextBlock(block, counters));
        previousStyle = block.style;

      case TableBlock():
        buffer
          ..writeln()
          ..write(_renderTable(block.rows));
        previousStyle = null;

      case CalloutBlock():
        buffer
          ..writeln()
          ..writeln(_renderCallout(block));
        previousStyle = null;

      case ImageBlock():
        // Plain text cannot hold a picture, but it can say there was one and
        // name the file, which is in the `attachments/` folder of the same
        // export whenever attachments were included.
        buffer
          ..writeln()
          ..writeln(
            block.fileName.isEmpty ? '[Image]' : '[Image: ${block.fileName}]',
          );
        previousStyle = null;

      case DrawingBlock():
        buffer
          ..writeln()
          ..writeln(
            block.fileName.isEmpty
                ? '[Drawing]'
                : '[Drawing: ${block.fileName}]',
          );
        previousStyle = null;

      case UnknownEmbedBlock():
        buffer
          ..writeln()
          ..writeln('[${block.type} block — not exportable as text]');
        previousStyle = null;
    }
  }

  return buffer.toString().trimRight();
}

bool _isList(BlockStyle style) =>
    style == BlockStyle.bulletList ||
    style == BlockStyle.orderedList ||
    style == BlockStyle.checkedList ||
    style == BlockStyle.uncheckedList;

String _renderTextBlock(TextBlock block, Map<int, int> counters) {
  final indent = '    ' * block.indent;
  final text = block.plainText;

  switch (block.style) {
    case BlockStyle.heading1:
    case BlockStyle.heading2:
    case BlockStyle.heading3:
      // Underlining the heading is the one bit of structure plain text can
      // carry without inventing syntax. The rule length follows the text so it
      // stays right for Malayalam as well as English.
      final rule =
          (block.style == BlockStyle.heading1 ? '=' : '-') *
          _displayWidth(text);
      return '$text\n$rule';
    case BlockStyle.bulletList:
      return '$indent* $text';
    case BlockStyle.orderedList:
      final n = (counters[block.indent] ?? 0) + 1;
      counters[block.indent] = n;
      return '$indent$n. $text';
    case BlockStyle.checkedList:
      return '$indent[x] $text';
    case BlockStyle.uncheckedList:
      return '$indent[ ] $text';
    case BlockStyle.blockquote:
      return '$indent> $text';
    case BlockStyle.codeBlock:
      return '$indent    $text';
    case BlockStyle.paragraph:
      return '$indent$text';
  }
}

/// How many characters wide [text] is, for drawing a heading rule.
///
/// Counts runes rather than code units so an emoji or a character outside the
/// basic plane does not draw a rule twice as long as the text.
int _displayWidth(String text) {
  final width = text.runes.length;
  // A very long heading would otherwise draw a rule off the edge of any reader.
  return width > 80 ? 80 : width;
}

/// Renders a table as fixed-width columns, padded so they line up.
String _renderTable(List<List<String>> rows) {
  if (rows.isEmpty) return '';

  final width = rows.fold<int>(0, (m, row) => row.length > m ? row.length : m);
  if (width == 0) return '';

  String cellAt(List<String> row, int i) => i < row.length
      ? row[i].replaceAll('\n', ' ').replaceAll('\r', ' ').trim()
      : '';

  // Column widths come from the widest cell, measured in runes so Malayalam
  // lines up the same way Latin does.
  final columnWidths = List.generate(width, (i) {
    var widest = 0;
    for (final row in rows) {
      final length = cellAt(row, i).runes.length;
      if (length > widest) widest = length;
    }
    // A very wide cell would push the table past any sensible line length.
    return widest > 40 ? 40 : widest;
  });

  String renderRow(List<String> row) {
    final cells = List.generate(width, (i) {
      final cell = cellAt(row, i);
      final padding = columnWidths[i] - cell.runes.length;
      return padding > 0 ? '$cell${' ' * padding}' : cell;
    });
    return cells.join('  ').trimRight();
  }

  final buffer = StringBuffer()..writeln(renderRow(rows.first));
  // A rule under the first row, matching the total width of the columns.
  final ruleWidth =
      columnWidths.fold<int>(0, (a, b) => a + b) + (width - 1) * 2;
  buffer.writeln('-' * (ruleWidth > 0 ? ruleWidth : 1));
  for (final row in rows.skip(1)) {
    buffer.writeln(renderRow(row));
  }
  return buffer.toString();
}

String _renderCallout(CalloutBlock block) {
  final label = _calloutLabel(block.style);
  final lines = block.text.split('\n');
  final buffer = StringBuffer('[$label]');
  for (final line in lines) {
    buffer.write('\n  $line');
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
      return style.isEmpty ? 'Note' : style;
  }
}
