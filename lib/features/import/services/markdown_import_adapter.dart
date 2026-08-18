import 'dart:convert';

import 'package:sreerajp_journal_vault/features/import/services/import_adapter.dart';

/// Imports Markdown (.md) files into journal entries.
///
/// Converts common Markdown syntax into Quill delta operations:
/// - Headings (#, ##, ###) become header blocks
/// - Bold (**text**) becomes bold inline format
/// - Italic (*text* or _text_) becomes italic inline format
/// - Code blocks (```) become code-block blocks
/// - Blockquotes (>) become blockquote blocks
/// - Lists (- or *) become list items
/// - Numbered lists (1.) become ordered list items
class MarkdownImportAdapter extends ImportAdapter {
  @override
  String get formatName => 'Markdown';

  @override
  List<String> get supportedExtensions => ['.md', '.markdown'];

  @override
  List<String> get supportedMimeTypes => ['text/markdown'];

  @override
  Future<ImportResult> import(List<int> bytes, String fileName) async {
    final text = utf8.decode(bytes, allowMalformed: true);
    final ops = _parseMarkdown(text);
    final plainText = _extractPlainText(text);

    return ImportResult(
      title: _extractTitle(text) ?? ImportAdapter.titleFromFileName(fileName),
      contentJson: jsonEncode(ops),
      plainText: plainText,
    );
  }

  /// Extracts the first H1 heading as the title, if present.
  String? _extractTitle(String text) {
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ') && !trimmed.startsWith('## ')) {
        return trimmed.substring(2).trim();
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _parseMarkdown(String text) {
    final ops = <Map<String, dynamic>>[];
    final lines = text.split('\n');
    var inCodeBlock = false;

    for (final line in lines) {
      final trimmed = line.trim();

      // Code block toggle
      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        if (inCodeBlock) continue;
        // End of code block — just skip the closing fence
        continue;
      }

      if (inCodeBlock) {
        ops.add({'insert': '$line\n'});
        ops.add({
          'insert': '\n',
          'attributes': {'code-block': true},
        });
        continue;
      }

      // Headings
      final headingMatch = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(trimmed);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final content = headingMatch.group(2)!;
        _addInlineFormatted(ops, content);
        ops.add({
          'insert': '\n',
          'attributes': {'header': level},
        });
        continue;
      }

      // Blockquote
      if (trimmed.startsWith('> ')) {
        final content = trimmed.substring(2);
        _addInlineFormatted(ops, content);
        ops.add({
          'insert': '\n',
          'attributes': {'blockquote': true},
        });
        continue;
      }

      // Unordered list
      final ulMatch = RegExp(r'^[-*+]\s+(.+)$').firstMatch(trimmed);
      if (ulMatch != null) {
        _addInlineFormatted(ops, ulMatch.group(1)!);
        ops.add({
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        });
        continue;
      }

      // Ordered list
      final olMatch = RegExp(r'^\d+\.\s+(.+)$').firstMatch(trimmed);
      if (olMatch != null) {
        _addInlineFormatted(ops, olMatch.group(1)!);
        ops.add({
          'insert': '\n',
          'attributes': {'list': 'ordered'},
        });
        continue;
      }

      // Regular paragraph
      if (trimmed.isEmpty) {
        ops.add({'insert': '\n'});
      } else {
        _addInlineFormatted(ops, trimmed);
        ops.add({'insert': '\n'});
      }
    }

    if (ops.isEmpty) {
      ops.add({'insert': '\n'});
    }

    return ops;
  }

  /// Parses inline bold/italic/code formatting within a line.
  void _addInlineFormatted(List<Map<String, dynamic>> ops, String text) {
    final pattern = RegExp(
      r'(\*\*\*(.+?)\*\*\*' // bold+italic
      r'|\*\*(.+?)\*\*' // bold
      r'|__(.+?)__' // bold (underscore)
      r'|\*(.+?)\*' // italic
      r'|_(.+?)_' // italic (underscore)
      r'|`(.+?)`)', // inline code
    );

    var lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // Add text before this match
      if (match.start > lastEnd) {
        ops.add({'insert': text.substring(lastEnd, match.start)});
      }

      if (match.group(2) != null) {
        // Bold + italic
        ops.add({
          'insert': match.group(2),
          'attributes': {'bold': true, 'italic': true},
        });
      } else if (match.group(3) != null) {
        // Bold (**)
        ops.add({
          'insert': match.group(3),
          'attributes': {'bold': true},
        });
      } else if (match.group(4) != null) {
        // Bold (__)
        ops.add({
          'insert': match.group(4),
          'attributes': {'bold': true},
        });
      } else if (match.group(5) != null) {
        // Italic (*)
        ops.add({
          'insert': match.group(5),
          'attributes': {'italic': true},
        });
      } else if (match.group(6) != null) {
        // Italic (_)
        ops.add({
          'insert': match.group(6),
          'attributes': {'italic': true},
        });
      } else if (match.group(7) != null) {
        // Inline code
        ops.add({
          'insert': match.group(7),
          'attributes': {'code': true},
        });
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      ops.add({'insert': text.substring(lastEnd)});
    }
  }

  /// Strips Markdown syntax to produce plain text.
  String _extractPlainText(String text) {
    final lines = text.split('\n');
    final buffer = StringBuffer();
    var inCodeBlock = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        buffer.writeln(line);
        continue;
      }

      var cleaned = trimmed;
      // Remove heading markers
      cleaned = cleaned.replaceFirst(RegExp(r'^#{1,3}\s+'), '');
      // Remove blockquote markers
      cleaned = cleaned.replaceFirst(RegExp(r'^>\s+'), '');
      // Remove list markers
      cleaned = cleaned.replaceFirst(RegExp(r'^[-*+]\s+'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s+'), '');
      // Remove inline formatting (replaceAll doesn't interpret $1, so use
      // replaceAllMapped to substitute the captured group).
      String stripGroup1(String input, RegExp pattern) =>
          input.replaceAllMapped(pattern, (m) => m.group(1) ?? '');
      cleaned = stripGroup1(cleaned, RegExp(r'\*\*\*(.+?)\*\*\*'));
      cleaned = stripGroup1(cleaned, RegExp(r'\*\*(.+?)\*\*'));
      cleaned = stripGroup1(cleaned, RegExp(r'__(.+?)__'));
      cleaned = stripGroup1(cleaned, RegExp(r'\*(.+?)\*'));
      cleaned = stripGroup1(cleaned, RegExp(r'_(.+?)_'));
      cleaned = stripGroup1(cleaned, RegExp(r'`(.+?)`'));

      buffer.writeln(cleaned);
    }

    return buffer.toString().trim();
  }
}
