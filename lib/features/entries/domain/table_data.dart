import 'dart:convert';

/// The contents of a table block: its cells and, optionally, column widths.
///
/// A table lives inside an entry's Quill delta as an embed whose data is a
/// JSON string. Three formats exist, and all three are read:
///
/// - **Legacy:** a plain 2D list of strings `[["a","b"],["c","d"]]`.
/// - **Envelope:** `{"rows":[["a","b"],…],"colWidths":[120.0,200.0]}`,
///   written once a column has been resized.
/// - **Rich (v2):** `{"v":2,"rows":[…],"cells":[…],"colWidths":[…]}`. Each
///   cell in `cells` is a list of Quill text ops holding inline formatting
///   only. `rows` repeats the cells as plain text so an older app version
///   (a second device on Wi-Fi Sync, an older backup reader) still shows the
///   words; it simply ignores `cells`.
///
/// A table with no formatting anywhere is still written in the legacy or
/// envelope format, so existing entries do not change for no reason.
///
/// Pure Dart — no Flutter — so the editor, export, paste and Markdown code all
/// read tables the same way.
class TableData {
  TableData({
    required List<List<List<Map<String, dynamic>>>> cells,
    List<double>? colWidths,
  }) : cells = [
         for (final row in cells) [for (final cell in row) normalizeCell(cell)],
       ],
       colWidths = colWidths == null ? null : List<double>.of(colWidths);

  /// A table whose cells hold plain text only.
  factory TableData.fromPlainRows(
    List<List<String>> rows, {
    List<double>? colWidths,
  }) {
    return TableData(
      cells: [
        for (final row in rows) [for (final text in row) plainCell(text)],
      ],
      colWidths: colWidths,
    );
  }

  /// The Quill embed type of a table block.
  static const String tableEmbedType = 'table';

  /// Format version written when any cell has formatting.
  static const int richVersion = 2;

  /// Inline attributes a cell may carry. Block attributes (headings, lists,
  /// alignment) have no meaning inside a cell and are dropped.
  static const Set<String> inlineAttributes = {
    'bold',
    'italic',
    'underline',
    'strike',
    'code',
    'link',
    'color',
    'background',
    'script',
  };

  /// Each cell's text ops. A cell's ops never end with the newline Quill
  /// keeps at the end of a document.
  final List<List<List<Map<String, dynamic>>>> cells;

  /// Per-column widths, or `null` when every column uses equal width.
  final List<double>? colWidths;

  int get rowCount => cells.length;

  /// The number of columns in the widest row.
  int get columnCount => cells.fold<int>(
    0,
    (widest, row) => row.length > widest ? row.length : widest,
  );

  /// The cells as plain text.
  List<List<String>> get plainRows => [
    for (final row in cells) [for (final cell in row) cellPlainText(cell)],
  ];

  /// True when at least one cell carries inline formatting.
  bool get hasFormatting => cells.any(
    (row) => row.any((cell) => cell.any((op) => op['attributes'] != null)),
  );

  /// The words of the table: cells separated by spaces, rows by new lines.
  /// Used for search text and word count.
  String get searchText {
    final buffer = StringBuffer();
    for (final row in plainRows) {
      final line = row
          .map((cell) => cell.replaceAll('\n', ' ').trim())
          .where((cell) => cell.isNotEmpty)
          .join(' ');
      if (line.isNotEmpty) buffer.writeln(line);
    }
    return buffer.toString();
  }

  /// Serialises to the embed's JSON string, in the oldest format that can
  /// hold this table.
  String toJsonString() {
    final rows = plainRows;
    if (!hasFormatting) {
      if (colWidths == null) return jsonEncode(rows);
      return jsonEncode({'rows': rows, 'colWidths': colWidths});
    }
    return jsonEncode({
      'v': richVersion,
      'rows': rows,
      'cells': cells,
      'colWidths': ?colWidths,
    });
  }

  /// Reads a table embed's data, or returns null when it is unusable.
  ///
  /// Never throws: an entry holding a damaged table must still open and
  /// export.
  static TableData? tryParse(Object? data) {
    if (data is! String) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(data);
    } on FormatException {
      return null;
    }

    if (decoded is List) {
      return TableData.fromPlainRows(_readPlainRows(decoded));
    }
    if (decoded is! Map) return null;

    final colWidths = _readColWidths(decoded['colWidths']);
    final rawCells = decoded['cells'];
    if (rawCells is List) {
      final cells = _readRichCells(rawCells);
      if (cells != null) return TableData(cells: cells, colWidths: colWidths);
    }
    final rawRows = decoded['rows'];
    if (rawRows is! List) return null;
    return TableData.fromPlainRows(
      _readPlainRows(rawRows),
      colWidths: colWidths,
    );
  }

  /// A cell holding [text] with no formatting.
  static List<Map<String, dynamic>> plainCell(String text) => text.isEmpty
      ? <Map<String, dynamic>>[]
      : [
          {'insert': text},
        ];

  /// The plain text of one cell.
  static String cellPlainText(List<Map<String, dynamic>> cell) =>
      cell.map((op) => op['insert'] as String).join();

  /// Cleans one cell's ops: keeps text inserts only, keeps only
  /// [inlineAttributes], drops trailing newlines and merges neighbouring ops
  /// that share formatting.
  static List<Map<String, dynamic>> normalizeCell(List<Object?> ops) {
    final result = <Map<String, dynamic>>[];
    for (final op in ops) {
      if (op is! Map) continue;
      final insert = op['insert'];
      if (insert is! String || insert.isEmpty) continue;
      final attributes = _cleanAttributes(op['attributes']);
      if (result.isNotEmpty &&
          _sameAttributes(
            result.last['attributes'] as Map<String, dynamic>?,
            attributes,
          )) {
        result[result.length - 1] = {
          'insert': (result.last['insert'] as String) + insert,
          'attributes': ?attributes,
        };
        continue;
      }
      result.add({'insert': insert, 'attributes': ?attributes});
    }

    // Quill documents end with a newline; a cell does not need it.
    while (result.isNotEmpty) {
      final last = result.last;
      final text = last['insert'] as String;
      if (!text.endsWith('\n')) break;
      final trimmed = text.replaceFirst(RegExp(r'\n+$'), '');
      if (trimmed.isEmpty) {
        result.removeLast();
      } else {
        result[result.length - 1] = {...last, 'insert': trimmed};
        break;
      }
    }
    return result;
  }

  static Map<String, dynamic>? _cleanAttributes(Object? raw) {
    if (raw is! Map) return null;
    final cleaned = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      if (!inlineAttributes.contains(key)) continue;
      final value = entry.value;
      switch (key) {
        case 'link':
        case 'color':
        case 'background':
        case 'script':
          if (value is String && value.isNotEmpty) cleaned[key] = value;
        default:
          if (value == true) cleaned[key] = true;
      }
    }
    return cleaned.isEmpty ? null : cleaned;
  }

  static bool _sameAttributes(
    Map<String, dynamic>? a,
    Map<String, dynamic>? b,
  ) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  static List<List<String>> _readPlainRows(List<dynamic> rows) => [
    for (final row in rows.whereType<List>())
      [for (final cell in row) cell?.toString() ?? ''],
  ];

  /// Reads the v2 `cells` list, or null when its shape is unusable.
  static List<List<List<Map<String, dynamic>>>>? _readRichCells(
    List<dynamic> raw,
  ) {
    final rows = <List<List<Map<String, dynamic>>>>[];
    for (final row in raw) {
      if (row is! List) return null;
      final cells = <List<Map<String, dynamic>>>[];
      for (final cell in row) {
        if (cell is String) {
          cells.add(plainCell(cell));
        } else if (cell is List) {
          cells.add(normalizeCell(cell));
        } else {
          return null;
        }
      }
      rows.add(cells);
    }
    return rows;
  }

  static List<double>? _readColWidths(Object? raw) {
    if (raw is! List) return null;
    final widths = <double>[];
    for (final width in raw) {
      if (width is! num) return null;
      widths.add(width.toDouble());
    }
    return widths;
  }
}
