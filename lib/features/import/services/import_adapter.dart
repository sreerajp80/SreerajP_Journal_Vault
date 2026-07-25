import 'dart:convert';

/// Result of importing a file into a journal entry.
class ImportResult {
  final String? title;
  final String contentJson;
  final String plainText;

  const ImportResult({
    this.title,
    required this.contentJson,
    required this.plainText,
  });
}

/// Base class for all import adapters.
///
/// Each adapter converts a specific file format into a Quill delta JSON
/// structure suitable for storing in the entries table.
abstract class ImportAdapter {
  /// Human-readable name shown in the import picker.
  String get formatName;

  /// File extensions this adapter handles (e.g., ['.md', '.markdown']).
  List<String> get supportedExtensions;

  /// MIME types this adapter handles.
  List<String> get supportedMimeTypes;

  /// Converts raw file bytes into an [ImportResult].
  Future<ImportResult> import(List<int> bytes, String fileName);

  /// Helper to build a Quill delta JSON string from plain text paragraphs.
  static String plainTextToQuillJson(String text) {
    final lines = text.split('\n');
    final ops = <Map<String, dynamic>>[];
    for (final line in lines) {
      ops.add({'insert': '$line\n'});
    }
    if (ops.isEmpty) {
      ops.add({'insert': '\n'});
    }
    return jsonEncode(ops);
  }

  /// Extracts a title from a file name by removing the extension.
  static String titleFromFileName(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot > 0) return fileName.substring(0, lastDot);
    return fileName;
  }
}
