import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';

/// The plain text of an entry's Quill delta [ops], for search, word count and
/// smart tags.
///
/// Same as Quill's `Document.toPlainText()`, except that a table gives its
/// words (cells separated by spaces, rows by new lines) instead of one
/// placeholder character, so words inside a table can be found by search.
/// Other embeds stay one placeholder character, as before.
///
/// Do not use it for caret or selection offsets: a table's text is longer
/// than the one position the table takes in the document. Use
/// `Document.toPlainText()` for those.
///
/// Pure Dart; never logs.
String entryPlainText(List<dynamic> ops) {
  // Quill's Embed.kObjectReplacementCharacter.
  const objectReplacement = '\u{FFFC}';
  final buffer = StringBuffer();
  for (final op in ops) {
    if (op is! Map) continue;
    final insert = op['insert'];
    if (insert is String) {
      buffer.write(insert);
    } else if (insert is Map) {
      final table = insert.length == 1
          ? TableData.tryParse(insert[TableData.tableEmbedType])
          : null;
      if (table == null) {
        buffer.write(objectReplacement);
        continue;
      }
      // The table's own line ends with the newline that follows the embed.
      var text = table.searchText;
      if (text.endsWith('\n')) text = text.substring(0, text.length - 1);
      buffer.write(text);
    }
  }
  return buffer.toString();
}
