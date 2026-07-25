import 'dart:convert';

import 'package:sreerajp_journal_vault/features/import/services/import_adapter.dart';

/// Imports plain text (.txt) files into journal entries.
class PlainTextImportAdapter extends ImportAdapter {
  @override
  String get formatName => 'Plain Text';

  @override
  List<String> get supportedExtensions => ['.txt'];

  @override
  List<String> get supportedMimeTypes => ['text/plain'];

  @override
  Future<ImportResult> import(List<int> bytes, String fileName) async {
    final text = utf8.decode(bytes, allowMalformed: true);
    return ImportResult(
      title: ImportAdapter.titleFromFileName(fileName),
      contentJson: ImportAdapter.plainTextToQuillJson(text),
      plainText: text,
    );
  }
}
