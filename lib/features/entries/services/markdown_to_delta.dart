import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';

/// Converts Markdown text into Quill delta operations (the JSON form).
///
/// Used by the Markdown file import and by "Paste as Markdown" in the entry
/// editor. Pure Dart: no Flutter, no I/O.
///
/// Supported:
/// - headings `#` to `######`
/// - bullet, numbered and task lists (`- [ ]`, `- [x]`), nested by indent
/// - `>` quotes, fenced code blocks, `---` divider lines
/// - pipe tables with a `|---|` line, as the editor's table block
/// - inline `**bold**`, `*italic*`, `~~strike~~`, `` `code` ``, links
///
/// Web links (`http`, `https`, `mailto`) keep their link. Other targets, such
/// as in-page anchors (`#contents`), mean nothing inside a journal, so only
/// the link text is kept.
class MarkdownToDelta {
  const MarkdownToDelta();

  /// The text inserted for a `---` divider line; the editor has no divider
  /// block.
  static const String dividerText = '———';

  static final RegExp _heading = RegExp(r'^(#{1,6})\s+(.*?)(?:\s+#+)?\s*$');
  static final RegExp _fence = RegExp(r'^(```|~~~)');
  static final RegExp _divider = RegExp(
    r'^(?:(?:\*\s*){3,}|(?:-\s*){3,}|(?:_\s*){3,})$',
  );
  static final RegExp _task = RegExp(r'^[-*+]\s+\[([ xX])\]\s*(.*)$');
  static final RegExp _bullet = RegExp(r'^[-*+]\s+(.*)$');
  static final RegExp _ordered = RegExp(r'^\d+[.)]\s+(.*)$');
  static final RegExp _tableSeparator = RegExp(
    r'^\|?\s*:?-+:?\s*(?:\|\s*:?-+:?\s*)*\|?$',
  );

  /// Converts [markdown] into delta operations. Always ends with a newline.
  List<Map<String, dynamic>> convert(String markdown) {
    final ops = <Map<String, dynamic>>[];
    final lines = markdown
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');
    // Leading-space widths of the open list levels, outermost first.
    final listIndents = <int>[];
    String? fence;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].replaceAll('\t', '    ');
      final trimmed = line.trim();

      if (fence != null) {
        if (trimmed.startsWith(fence)) {
          fence = null;
        } else {
          if (line.isNotEmpty) ops.add({'insert': line});
          _addLineEnd(ops, {'code-block': true});
        }
        continue;
      }
      final fenceMatch = _fence.firstMatch(trimmed);
      if (fenceMatch != null) {
        fence = fenceMatch.group(1);
        listIndents.clear();
        continue;
      }

      // A pipe table needs a header row followed by a `|---|` line.
      if (trimmed.contains('|') &&
          i + 1 < lines.length &&
          lines[i + 1].contains('|') &&
          _tableSeparator.hasMatch(lines[i + 1].trim())) {
        final rows = <List<List<Map<String, dynamic>>>>[_tableCells(trimmed)];
        i += 2;
        while (i < lines.length && lines[i].trim().contains('|')) {
          rows.add(_tableCells(lines[i].trim()));
          i++;
        }
        i--;
        _addTable(ops, rows);
        listIndents.clear();
        continue;
      }

      final heading = _heading.firstMatch(trimmed);
      if (heading != null) {
        _addInline(ops, heading.group(2)!);
        _addLineEnd(ops, {'header': heading.group(1)!.length});
        listIndents.clear();
        continue;
      }

      if (_divider.hasMatch(trimmed)) {
        ops.add({'insert': dividerText});
        _addLineEnd(ops, null);
        listIndents.clear();
        continue;
      }

      if (trimmed.startsWith('>')) {
        _addInline(ops, trimmed.replaceFirst(RegExp(r'^>+\s?'), ''));
        _addLineEnd(ops, {'blockquote': true});
        listIndents.clear();
        continue;
      }

      final task = _task.firstMatch(trimmed);
      final bullet = task == null ? _bullet.firstMatch(trimmed) : null;
      final ordered = task == null && bullet == null
          ? _ordered.firstMatch(trimmed)
          : null;
      final String listType;
      final String listText;
      if (task != null) {
        listType = task.group(1) == ' ' ? 'unchecked' : 'checked';
        listText = task.group(2)!;
      } else if (bullet != null) {
        listType = 'bullet';
        listText = bullet.group(1)!;
      } else if (ordered != null) {
        listType = 'ordered';
        listText = ordered.group(1)!;
      } else {
        // A plain paragraph line, or a blank line.
        if (trimmed.isNotEmpty) listIndents.clear();
        _addInline(ops, trimmed);
        _addLineEnd(ops, null);
        continue;
      }

      final indent = line.length - line.trimLeft().length;
      while (listIndents.isNotEmpty && listIndents.last > indent) {
        listIndents.removeLast();
      }
      if (listIndents.isEmpty || listIndents.last < indent) {
        listIndents.add(indent);
      }
      final level = listIndents.length - 1;
      _addInline(ops, listText);
      _addLineEnd(ops, {'list': listType, if (level > 0) 'indent': level});
    }

    if (ops.isEmpty) ops.add({'insert': '\n'});
    return ops;
  }

  /// The plain text of [ops], as produced by [convert]. Table rows become
  /// lines of space-separated cells.
  static String plainTextOf(List<Map<String, dynamic>> ops) {
    final buffer = StringBuffer();
    for (final op in ops) {
      final insert = op['insert'];
      if (insert is String) {
        buffer.write(insert);
      } else if (insert is Map) {
        final table = TableData.tryParse(insert[TableData.tableEmbedType]);
        if (table == null) continue;
        for (final row in table.plainRows) {
          buffer.writeln(row.join(' '));
        }
      }
    }
    return buffer.toString();
  }

  /// Removes inline Markdown from [text], keeping only what a reader sees.
  static String stripInline(String text) {
    final ops = <Map<String, dynamic>>[];
    _addInline(ops, text);
    return ops.map((op) => op['insert'] as String).join();
  }

  static void _addLineEnd(
    List<Map<String, dynamic>> ops,
    Map<String, dynamic>? attributes,
  ) {
    ops.add({'insert': '\n', 'attributes': ?attributes});
  }

  /// Reads one table row into cells that keep their inline formatting
  /// (bold, italic, strike, code, web links).
  static List<List<Map<String, dynamic>>> _tableCells(String row) {
    var body = row;
    if (body.startsWith('|')) body = body.substring(1);
    if (body.endsWith('|') && !body.endsWith(r'\|')) {
      body = body.substring(0, body.length - 1);
    }
    return body.split(RegExp(r'(?<!\\)\|')).map((cell) {
      final ops = <Map<String, dynamic>>[];
      _addInline(ops, cell.trim().replaceAll(r'\|', '|'));
      return ops;
    }).toList();
  }

  static void _addTable(
    List<Map<String, dynamic>> ops,
    List<List<List<Map<String, dynamic>>>> rows,
  ) {
    final columns = rows.fold<int>(
      0,
      (widest, row) => row.length > widest ? row.length : widest,
    );
    final padded = [
      for (final row in rows)
        [
          ...row,
          for (var c = row.length; c < columns; c++) <Map<String, dynamic>>[],
        ],
    ];
    ops.add({
      'insert': {
        TableData.tableEmbedType: TableData(cells: padded).toJsonString(),
      },
    });
    ops.add({'insert': '\n'});
  }

  // --- Inline parsing ---------------------------------------------------

  static final RegExp _escape = RegExp(r'\\([!-/:-@\[-`{-~])');
  static final RegExp _code = RegExp(r'(`+)(.+?)\1');
  static final RegExp _link = RegExp(
    r'!?\[((?:[^\[\]]|\[[^\]]*\])*)\]\(\s*<?([^)\s>]*)>?(?:\s+"[^"]*")?\s*\)',
  );
  static final RegExp _autolink = RegExp(r'<((?:https?://|mailto:)[^>\s]+)>');
  static final RegExp _webUrl = RegExp(
    r'^(?:https?://|mailto:)',
    caseSensitive: false,
  );

  /// Delimiters for emphasis, longest first, with the attributes they add.
  static const List<(String, Map<String, dynamic>)> _emphasis = [
    ('***', {'bold': true, 'italic': true}),
    ('___', {'bold': true, 'italic': true}),
    ('**', {'bold': true}),
    ('__', {'bold': true}),
    ('~~', {'strike': true}),
    ('*', {'italic': true}),
    ('_', {'italic': true}),
  ];

  static void _addInline(
    List<Map<String, dynamic>> ops,
    String text, [
    Map<String, dynamic> attributes = const {},
  ]) {
    final plain = StringBuffer();

    void flush() {
      if (plain.isEmpty) return;
      _push(ops, plain.toString(), attributes);
      plain.clear();
    }

    var i = 0;
    while (i < text.length) {
      final escape = _escape.matchAsPrefix(text, i);
      if (escape != null) {
        plain.write(escape.group(1));
        i = escape.end;
        continue;
      }

      final code = text[i] == '`' ? _code.matchAsPrefix(text, i) : null;
      if (code != null) {
        flush();
        _push(ops, code.group(2)!.trim(), {...attributes, 'code': true});
        i = code.end;
        continue;
      }

      final link = (text[i] == '[' || text[i] == '!')
          ? _link.matchAsPrefix(text, i)
          : null;
      if (link != null) {
        flush();
        final url = link.group(2)!;
        final label = link.group(1)!.isEmpty ? url : link.group(1)!;
        _addInline(ops, label, {
          ...attributes,
          if (_webUrl.hasMatch(url)) 'link': url,
        });
        i = link.end;
        continue;
      }

      final autolink = text[i] == '<' ? _autolink.matchAsPrefix(text, i) : null;
      if (autolink != null) {
        flush();
        final url = autolink.group(1)!;
        _push(ops, url, {...attributes, 'link': url});
        i = autolink.end;
        continue;
      }

      final emphasis = _matchEmphasis(text, i);
      if (emphasis != null) {
        flush();
        final (inner, end, added) = emphasis;
        _addInline(ops, inner, {...attributes, ...added});
        i = end;
        continue;
      }

      plain.write(text[i]);
      i++;
    }
    flush();
  }

  /// Tries to read an emphasis span starting at [start]. Returns the inner
  /// text, the index after the closing delimiter, and the attributes to add.
  static (String, int, Map<String, dynamic>)? _matchEmphasis(
    String text,
    int start,
  ) {
    for (final (delimiter, added) in _emphasis) {
      if (!text.startsWith(delimiter, start)) continue;
      final open = start + delimiter.length;
      // An opener must be followed by a non-space character.
      if (open >= text.length || text[open].trim().isEmpty) continue;
      final underscore = delimiter.startsWith('_');
      // `snake_case_words` are not emphasis.
      if (underscore && start > 0 && _isWordChar(text[start - 1])) continue;

      var search = open + 1;
      while (true) {
        final close = text.indexOf(delimiter, search);
        if (close < 0) break;
        final after = close + delimiter.length;
        final spaceBefore = text[close - 1].trim().isEmpty;
        final wordAfter =
            underscore && after < text.length && _isWordChar(text[after]);
        // For a single `*`, skip a `**` that belongs to a nested bold span.
        final partOfLonger =
            delimiter.length == 1 &&
            after < text.length &&
            text[after] == delimiter;
        if (!spaceBefore && !wordAfter && !partOfLonger) {
          return (text.substring(open, close), after, added);
        }
        search = partOfLonger ? after + 1 : close + 1;
      }
    }
    return null;
  }

  static bool _isWordChar(String char) => RegExp(r'[A-Za-z0-9]').hasMatch(char);

  /// Adds a text op, merging it into the previous op when the attributes
  /// match.
  static void _push(
    List<Map<String, dynamic>> ops,
    String text,
    Map<String, dynamic> attributes,
  ) {
    if (text.isEmpty) return;
    if (ops.isNotEmpty) {
      final last = ops.last;
      final lastInsert = last['insert'];
      final lastAttributes =
          (last['attributes'] as Map<String, dynamic>?) ?? const {};
      if (lastInsert is String &&
          !lastInsert.endsWith('\n') &&
          _sameAttributes(lastAttributes, attributes)) {
        ops[ops.length - 1] = {
          'insert': lastInsert + text,
          if (attributes.isNotEmpty) 'attributes': attributes,
        };
        return;
      }
    }
    ops.add({
      'insert': text,
      if (attributes.isNotEmpty)
        'attributes': Map<String, dynamic>.of(attributes),
    });
  }

  static bool _sameAttributes(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
