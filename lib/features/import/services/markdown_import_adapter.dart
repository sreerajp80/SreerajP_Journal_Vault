import 'dart:convert';

import 'package:sreerajp_journal_vault/features/entries/services/markdown_to_delta.dart';
import 'package:sreerajp_journal_vault/features/import/services/import_adapter.dart';

/// Imports Markdown (.md) files into journal entries.
///
/// The conversion itself is [MarkdownToDelta], shared with the editor's
/// "Paste as Markdown".
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
    final ops = const MarkdownToDelta().convert(text);
    final plainText = MarkdownToDelta.plainTextOf(ops).trim();

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
        return MarkdownToDelta.stripInline(trimmed.substring(2).trim());
      }
    }
    return null;
  }
}
