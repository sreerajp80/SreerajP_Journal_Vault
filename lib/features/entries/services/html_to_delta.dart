import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';

/// Converts HTML — what a browser, Google Docs, Word or Gmail puts on the
/// clipboard — into Quill delta operations (the JSON form) for a journal entry.
///
/// Used by the entry editor's paste. Pure Dart: no Flutter, no I/O, and it
/// never logs what it is given.
///
/// Kept: headings, bold / italic / underline / strike, sub/superscript, inline
/// code, code blocks, quotes, bullet / numbered / check lists with nesting,
/// alignment, safe links, real colours, and tables — as the editor's table
/// block, with formatting and links kept inside the cells.
///
/// Dropped, on purpose:
/// - images, video and audio (an image's `alt` text is kept). Nothing is ever
///   fetched from the internet.
/// - links that are not `http`, `https`, `mailto` or `tel` (`javascript:`,
///   `file:`, `intent:`, `data:`, in-page `#anchors`); their text is kept.
/// - black, white and grey text or highlight colours — a web page's default
///   colours, which would be unreadable in the other theme.
/// - font families and sizes, line heights and anything else the editor does
///   not know, so the app's own fonts (and its Malayalam and Devanagari
///   fonts) are used.
class HtmlToJournalDelta {
  const HtmlToJournalDelta();

  /// Line (block) attributes a pasted line may keep.
  static const Set<String> _lineAttributes = {
    'header',
    'list',
    'indent',
    'blockquote',
    'code-block',
    'align',
    'direction',
  };

  static const Set<String> _blockTags = {
    'address', 'article', 'aside', 'blockquote', 'br', 'dd', 'div', 'dl', //
    'dt', 'figcaption', 'figure', 'footer', 'h1', 'h2', 'h3', 'h4', 'h5',
    'h6', 'header', 'hr', 'li', 'main', 'nav', 'ol', 'p', 'pre', 'section',
    'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'ul',
  };

  /// Tags removed together with everything inside them.
  static const Set<String> _droppedTags = {
    'audio', 'button', 'canvas', 'embed', 'head', 'iframe', 'input', //
    'link', 'meta', 'noscript', 'object', 'script', 'select', 'source',
    'style', 'svg', 'template', 'textarea', 'title', 'video',
  };

  /// Converts [html] into delta operations that always end with a newline,
  /// or returns null when there is nothing usable in it (so the caller can
  /// paste the plain text instead).
  ///
  /// With [inlineOnly], the result is for a table cell: only inline
  /// formatting, no tables, lists, headings or other line styles. A pasted
  /// table then becomes lines of text.
  List<Map<String, dynamic>>? convert(String html, {bool inlineOnly = false}) {
    try {
      final document = html_parser.parse(html);
      final root = document.body ?? document.documentElement;
      if (root == null) return null;

      _clean(root);
      final tables = inlineOnly ? <TableData>[] : _extractTables(root);
      _normaliseWhitespace(root);

      final ops = <Map<String, dynamic>>[];
      for (final op in _convertElement(root, inlineOnly: inlineOnly)) {
        _addSanitised(ops, op, tables, inlineOnly: inlineOnly);
      }

      final hasContent = ops.any((op) {
        final insert = op['insert'];
        return insert is Map || (insert is String && insert.trim().isNotEmpty);
      });
      if (!hasContent) return null;
      if (!(ops.last['insert'] is String &&
          (ops.last['insert'] as String).endsWith('\n'))) {
        _push(ops, '\n', null);
      }
      return ops;
    } on Object {
      // Broken HTML is pasted as plain text rather than failing the paste.
      return null;
    }
  }

  // --- DOM clean-up ------------------------------------------------------

  /// Removes what must never be pasted, and rewrites the markup the HTML
  /// converter does not understand into markup it does.
  static void _clean(dom.Element root) {
    for (final node in _descendants(root).toList()) {
      if (node.parent == null && !identical(node, root)) continue;
      if (node is dom.Comment) {
        node.remove();
        continue;
      }
      if (node is! dom.Element) continue;
      final tag = node.localName ?? '';

      if (_droppedTags.contains(tag) || tag.startsWith('o:')) {
        node.remove();
        continue;
      }
      if (tag == 'img') {
        final alt = node.attributes['alt']?.trim() ?? '';
        if (alt.isEmpty) {
          node.remove();
        } else {
          node.replaceWith(dom.Text(alt));
        }
        continue;
      }
      // Google Docs wraps the whole copy in <b style="font-weight:normal"
      // id="docs-internal-guid-…">. It is not bold.
      if (tag == 'b' &&
          ((node.id).startsWith('docs-internal-guid') ||
              _style(node, 'font-weight') == 'normal')) {
        _unwrap(node);
        continue;
      }
    }
  }

  /// The value of CSS property [name] in [element]'s inline style, lowercased.
  static String? _style(dom.Element element, String name) {
    final style = element.attributes['style'];
    if (style == null) return null;
    for (final declaration in style.split(';')) {
      final colon = declaration.indexOf(':');
      if (colon < 0) continue;
      if (declaration.substring(0, colon).trim().toLowerCase() == name) {
        return declaration.substring(colon + 1).trim().toLowerCase();
      }
    }
    return null;
  }

  static void _unwrap(dom.Element element) {
    final parent = element.parentNode;
    if (parent == null) return;
    for (final child in element.nodes.toList()) {
      parent.insertBefore(child, element);
    }
    element.remove();
  }

  static Iterable<dom.Node> _descendants(dom.Node node) sync* {
    for (final child in node.nodes.toList()) {
      yield child;
      yield* _descendants(child);
    }
  }

  /// Collapses whitespace the way a browser shows it. The source's own line
  /// breaks are not line breaks on screen, and the whitespace between block
  /// tags is not text. Inside `<pre>` every character is kept, with line
  /// breaks turned into `<br>` so they survive the conversion.
  static void _normaliseWhitespace(dom.Element root) {
    for (final node in _descendants(root).toList()) {
      if (node is! dom.Text) continue;
      if (_insidePre(node)) {
        final lines = node.data.split('\n');
        if (lines.length == 1) continue;
        final parent = node.parentNode!;
        for (var i = 0; i < lines.length; i++) {
          if (i > 0) parent.insertBefore(dom.Element.tag('br'), node);
          if (lines[i].isNotEmpty) {
            parent.insertBefore(dom.Text(lines[i]), node);
          }
        }
        node.remove();
        continue;
      }
      final collapsed = node.data.replaceAll(RegExp(r'\s+'), ' ');
      if (collapsed == ' ' && _besideBlock(node)) {
        node.remove();
      } else {
        node.data = collapsed;
      }
    }
  }

  static bool _insidePre(dom.Node node) {
    for (var parent = node.parent; parent != null; parent = parent.parent) {
      if (parent.localName == 'pre') return true;
    }
    return false;
  }

  /// True when [node] sits between block tags (or at the edge of one), where
  /// whitespace is only source formatting.
  static bool _besideBlock(dom.Node node) {
    final parent = node.parentNode;
    if (parent == null) return true;
    final siblings = parent.nodes;
    final index = siblings.indexOf(node);
    bool isBlock(dom.Node? other) =>
        other is dom.Element && _blockTags.contains(other.localName);
    final before = index > 0 ? siblings[index - 1] : null;
    final after = index + 1 < siblings.length ? siblings[index + 1] : null;
    final parentIsBlock =
        parent is! dom.Element || _blockTags.contains(parent.localName);
    return isBlock(before) ||
        isBlock(after) ||
        (parentIsBlock && (before == null || after == null));
  }

  // --- Tables ------------------------------------------------------------

  /// Marks where table number N was; see [_placeholder].
  /// The private-use character around it cannot come from real pasted text.
  static final RegExp _placeholderPattern = RegExp(
    '\u{E000}jvtable([0-9]+)\u{E000}',
  );

  static String _placeholder(int index) => '\u{E000}jvtable$index\u{E000}';

  /// Replaces every outermost `<table>` with a placeholder paragraph and
  /// returns the tables, read as rich cells, in order.
  List<TableData> _extractTables(dom.Element root) {
    final tables = <TableData>[];
    final outermost = root
        .querySelectorAll('table')
        .where((table) => !_hasAncestor(table, 'table', stopAt: root))
        .toList();
    for (final table in outermost) {
      final data = _readTable(table);
      if (data == null) {
        table.remove();
        continue;
      }
      final placeholder = dom.Element.tag('p')
        ..append(dom.Text(_placeholder(tables.length)));
      tables.add(data);
      table.replaceWith(placeholder);
    }
    return tables;
  }

  static bool _hasAncestor(
    dom.Element element,
    String tag, {
    required dom.Element stopAt,
  }) {
    for (var parent = element.parent; parent != null; parent = parent.parent) {
      if (identical(parent, stopAt)) return false;
      if (parent.localName == tag) return true;
    }
    return false;
  }

  /// Reads a `<table>` into rich cells, or null when it has no cells.
  TableData? _readTable(dom.Element table) {
    final rows = <List<List<Map<String, dynamic>>>>[];
    // Rows that belong to this table, not to a table nested in a cell.
    final rowElements = table
        .querySelectorAll('tr')
        .where((row) => _nearestTable(row) == table);
    for (final row in rowElements) {
      final cells = <List<Map<String, dynamic>>>[];
      for (final cell in row.children) {
        if (cell.localName != 'td' && cell.localName != 'th') continue;
        cells.add(_readCell(cell, header: cell.localName == 'th'));
        final span = int.tryParse(cell.attributes['colspan'] ?? '') ?? 1;
        // Blank cells keep the row as wide as the table (a joined cell has
        // no equivalent in the table block). Capped against absurd values.
        for (var i = 1; i < span && i < 20; i++) {
          cells.add(<Map<String, dynamic>>[]);
        }
      }
      if (cells.isNotEmpty) rows.add(cells);
    }
    if (rows.isEmpty) return null;
    final width = rows.fold<int>(
      0,
      (m, row) => row.length > m ? row.length : m,
    );
    for (final row in rows) {
      while (row.length < width) {
        row.add(<Map<String, dynamic>>[]);
      }
    }
    return TableData(cells: rows);
  }

  static dom.Element? _nearestTable(dom.Element element) {
    for (var parent = element.parent; parent != null; parent = parent.parent) {
      if (parent.localName == 'table') return parent;
    }
    return null;
  }

  /// Reads one cell's contents as inline-formatted text. A header cell's
  /// text is made bold, as a browser shows it.
  List<Map<String, dynamic>> _readCell(
    dom.Element cell, {
    required bool header,
  }) {
    final fragment = html_parser.parse('<body></body>');
    final body = fragment.body!;
    cell.reparentChildren(body);
    _normaliseWhitespace(body);
    final ops = <Map<String, dynamic>>[];
    final converted = _convertElement(
      body,
      inlineOnly: true,
      inline: header ? const {'bold': true} : const {},
    );
    for (final op in converted) {
      _addSanitised(ops, op, const [], inlineOnly: true);
    }
    return TableData.normalizeCell(ops);
  }

  // --- Conversion and sanitising -----------------------------------------

  static List<Map<String, dynamic>> _convertElement(
    dom.Element root, {
    required bool inlineOnly,
    Map<String, dynamic> inline = const {},
  }) {
    final walker = _DomToOps(inlineOnly: inlineOnly);
    for (final child in root.nodes) {
      walker.walk(child, inline, const {}, null);
    }
    walker.endLine(const {});
    return walker.ops;
  }

  /// Adds [op] to [ops] with unsafe or unknown formatting removed, embeds
  /// dropped, and table placeholders swapped for table blocks.
  void _addSanitised(
    List<Map<String, dynamic>> ops,
    Map<String, dynamic> op,
    List<TableData> tables, {
    required bool inlineOnly,
  }) {
    final insert = op['insert'];
    // Images, video and any other embed from the page are not pasted.
    if (insert is! String || insert.isEmpty) return;
    final attributes = op['attributes'] is Map
        ? Map<String, dynamic>.from(op['attributes'] as Map)
        : const <String, dynamic>{};

    final isLineEnd = !inlineOnly && insert == '\n';
    final cleaned = isLineEnd
        ? _cleanLineAttributes(attributes)
        : _cleanInlineAttributes(attributes);

    var start = 0;
    for (final match in _placeholderPattern.allMatches(insert)) {
      _push(ops, insert.substring(start, match.start), cleaned);
      final index = int.parse(match.group(1)!);
      if (index < tables.length) {
        ops.add({
          'insert': {TableData.tableEmbedType: tables[index].toJsonString()},
        });
      }
      start = match.end;
    }
    _push(ops, insert.substring(start), cleaned);
  }

  static Map<String, dynamic>? _cleanLineAttributes(
    Map<String, dynamic> attributes,
  ) {
    final cleaned = <String, dynamic>{};
    for (final entry in attributes.entries) {
      if (!_lineAttributes.contains(entry.key)) continue;
      final value = entry.value;
      switch (entry.key) {
        case 'header':
          if (value is int && value >= 1 && value <= 6) {
            cleaned['header'] = value;
          }
        case 'list':
          if (const {
            'bullet',
            'ordered',
            'checked',
            'unchecked',
          }.contains(value)) {
            cleaned['list'] = value;
          }
        case 'indent':
          if (value is int && value > 0) {
            cleaned['indent'] = value > 8 ? 8 : value;
          }
        case 'align':
          // Left is the default; only a real change of alignment is kept.
          if (const {'center', 'right', 'justify'}.contains(value)) {
            cleaned['align'] = value;
          }
        case 'direction':
          if (value == 'rtl') cleaned['direction'] = value;
        default:
          if (value == true) cleaned[entry.key] = true;
      }
    }
    return cleaned.isEmpty ? null : cleaned;
  }

  static Map<String, dynamic>? _cleanInlineAttributes(
    Map<String, dynamic> attributes,
  ) {
    final cleaned = <String, dynamic>{};
    for (final entry in attributes.entries) {
      final value = entry.value;
      switch (entry.key) {
        case 'bold':
        case 'italic':
        case 'underline':
        case 'strike':
        case 'code':
          if (value == true) cleaned[entry.key] = true;
        case 'link':
          final link = safeLink(value);
          if (link != null) cleaned['link'] = link;
        case 'color':
        case 'background':
          final colour = visibleColour(value);
          if (colour != null) cleaned[entry.key] = colour;
        case 'script':
          if (value == 'sub' || value == 'super') cleaned['script'] = value;
      }
    }
    return cleaned.isEmpty ? null : cleaned;
  }

  /// [value] when it is a link a journal may keep: `http`, `https`, `mailto`
  /// or `tel`. Anything else — including relative links and `#anchors`,
  /// which mean nothing outside the page they came from — gives null.
  static String? safeLink(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    const allowed = {'http', 'https', 'mailto', 'tel'};
    if (!allowed.contains(uri.scheme.toLowerCase())) return null;
    return trimmed;
  }

  /// [value] as `#rrggbb` when it is a real colour, or null for black, white,
  /// greys, transparent and anything unreadable.
  ///
  /// A page's default text is black or dark grey; shown as-is it would
  /// vanish in the dark theme, and a white highlight would vanish in the
  /// light one. A colour someone chose on purpose — red, blue, a yellow
  /// highlight — has a clear hue, and is kept.
  static String? visibleColour(Object? value) {
    if (value is! String) return null;
    var hex = value.trim().toLowerCase();
    if (!hex.startsWith('#')) return null;
    hex = hex.substring(1);
    if (hex.length == 3 || hex.length == 4) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 8) {
      // CSS order is RRGGBBAA; a fully transparent colour is no colour.
      if (hex.substring(6) == '00') return null;
      hex = hex.substring(0, 6);
    }
    if (hex.length != 6) return null;
    final rgb = int.tryParse(hex, radix: 16);
    if (rgb == null) return null;
    final r = (rgb >> 16) & 0xff;
    final g = (rgb >> 8) & 0xff;
    final b = rgb & 0xff;
    final high = [r, g, b].reduce((a, c) => a > c ? a : c);
    final low = [r, g, b].reduce((a, c) => a < c ? a : c);
    // Little difference between the channels means black, white or grey.
    if (high - low < 40) return null;
    return '#$hex';
  }

  /// Adds a text op, merged into the previous one when the formatting
  /// matches. A text op is never merged into a line end that carries line
  /// formatting, or the line formatting would spread.
  static void _push(
    List<Map<String, dynamic>> ops,
    String text,
    Map<String, dynamic>? attributes,
  ) {
    if (text.isEmpty) return;
    if (ops.isNotEmpty) {
      final last = ops.last;
      final lastInsert = last['insert'];
      if (lastInsert is String &&
          _sameAttributes(
            last['attributes'] as Map<String, dynamic>?,
            attributes,
          )) {
        ops[ops.length - 1] = {
          'insert': lastInsert + text,
          'attributes': ?attributes,
        };
        return;
      }
    }
    ops.add({'insert': text, 'attributes': ?attributes});
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
}

/// A list being walked: its kind and how deeply it is nested (0 = outermost).
typedef _ListLevel = ({String kind, int depth});

/// Walks a cleaned HTML tree and writes Quill delta operations.
///
/// Inline tags and inline styles become inline attributes (bold, link,
/// colour, …). Block tags start and end lines, and give the line its line
/// attributes (heading, list, quote, code block, alignment) on the newline
/// that ends it, as Quill expects. Values are written as found; the caller
/// sanitises them.
class _DomToOps {
  _DomToOps({required this.inlineOnly});

  /// For a table cell: blocks still start new lines, but carry no line
  /// attributes.
  final bool inlineOnly;

  final List<Map<String, dynamic>> ops = [];

  /// True when text has been written since the last newline.
  bool _lineHasText = false;

  static const Set<String> _blockTags = {
    'address', 'article', 'aside', 'blockquote', 'dd', 'div', 'dl', 'dt', //
    'figcaption', 'figure', 'footer', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'header', 'li', 'main', 'nav', 'ol', 'p', 'pre', 'section', 'table',
    'tbody', 'tfoot', 'thead', 'tr', 'ul',
  };

  /// Basic CSS colour names; Chrome writes rgb() but hand-written HTML and
  /// some mail apps use names.
  static const Map<String, String> _namedColours = {
    'black': '#000000', 'white': '#ffffff', 'gray': '#808080', //
    'grey': '#808080', 'silver': '#c0c0c0', 'red': '#ff0000',
    'maroon': '#800000', 'yellow': '#ffff00', 'olive': '#808000',
    'lime': '#00ff00', 'green': '#008000', 'aqua': '#00ffff',
    'cyan': '#00ffff', 'teal': '#008080', 'blue': '#0000ff',
    'navy': '#000080', 'fuchsia': '#ff00ff', 'magenta': '#ff00ff',
    'purple': '#800080', 'orange': '#ffa500', 'pink': '#ffc0cb',
  };

  static final RegExp _rgb = RegExp(
    r'^rgba?\(\s*([\d.]+)[\s,]+([\d.]+)[\s,]+([\d.]+)(?:[\s,/]+([\d.]+%?))?\s*\)$',
  );

  void walk(
    dom.Node node,
    Map<String, dynamic> inline,
    Map<String, dynamic> line,
    _ListLevel? list,
  ) {
    if (node is dom.Text) {
      _text(node.data, inline, line);
      return;
    }
    if (node is! dom.Element) return;
    final tag = node.localName ?? '';

    final childInline = _inlineFor(node, tag, inline);

    switch (tag) {
      case 'br':
        endLine(line, force: true);
        return;
      case 'hr':
        endLine(line);
        _text('———', const {}, line);
        endLine(line);
        return;
      case 'ul':
      case 'ol':
        final level = (
          kind: tag == 'ol' ? 'ordered' : 'bullet',
          depth: list == null ? 0 : list.depth + 1,
        );
        endLine(line);
        for (final child in node.nodes) {
          walk(child, childInline, line, level);
        }
        endLine(line);
        return;
      case 'td':
      case 'th':
        // Only reached for a table read as text (inside a cell, or in a cell
        // paste): the cells of a row are separated by a space.
        for (final child in node.nodes) {
          walk(child, childInline, line, list);
        }
        if (_lineHasText) _text(' ', const {}, line);
        return;
    }

    if (!_blockTags.contains(tag)) {
      for (final child in node.nodes) {
        walk(child, childInline, line, list);
      }
      return;
    }

    // A block: whatever came before it is its own line.
    endLine(line);
    final blockLine = _lineFor(node, tag, line, list);
    for (final child in node.nodes) {
      walk(child, childInline, blockLine, list);
    }
    endLine(blockLine);
  }

  /// Ends the current line with [line] attributes. Does nothing when the line
  /// is empty, unless [force] (a `<br>`, which is a real blank line).
  void endLine(Map<String, dynamic> line, {bool force = false}) {
    if (!_lineHasText && !force) return;
    final attributes = inlineOnly || line.isEmpty ? null : line;
    ops.add({'insert': '\n', 'attributes': ?attributes});
    _lineHasText = false;
  }

  void _text(
    String text,
    Map<String, dynamic> inline,
    Map<String, dynamic> line,
  ) {
    var value = text;
    // Like a browser, spaces at the start of a line are not shown — except
    // in code, where indentation matters.
    if (!_lineHasText && line['code-block'] != true) {
      value = value.trimLeft();
    }
    if (value.isEmpty) return;
    ops.add({
      'insert': value,
      if (inline.isNotEmpty) 'attributes': Map<String, dynamic>.of(inline),
    });
    _lineHasText = true;
  }

  /// The line attributes for block [element] inside [line].
  Map<String, dynamic> _lineFor(
    dom.Element element,
    String tag,
    Map<String, dynamic> line,
    _ListLevel? list,
  ) {
    final result = Map<String, dynamic>.of(line);
    switch (tag) {
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        result['header'] = int.parse(tag.substring(1));
      case 'blockquote':
        result['blockquote'] = true;
      case 'pre':
        result['code-block'] = true;
      case 'li':
        if (list != null) {
          result['list'] = list.kind;
          if (list.depth > 0) {
            result['indent'] = list.depth;
          } else {
            result.remove('indent');
          }
        }
    }
    final align =
        HtmlToJournalDelta._style(element, 'text-align') ??
        element.attributes['align']?.toLowerCase();
    if (align != null) result['align'] = align;
    if (element.attributes['dir']?.toLowerCase() == 'rtl') {
      result['direction'] = 'rtl';
    }
    return result;
  }

  /// The inline attributes for the children of [element].
  Map<String, dynamic> _inlineFor(
    dom.Element element,
    String tag,
    Map<String, dynamic> inline,
  ) {
    final result = Map<String, dynamic>.of(inline);
    switch (tag) {
      case 'b' || 'strong':
        result['bold'] = true;
      case 'i' || 'em' || 'cite' || 'dfn' || 'var':
        result['italic'] = true;
      case 'u' || 'ins':
        result['underline'] = true;
      case 's' || 'strike' || 'del':
        result['strike'] = true;
      case 'code' || 'kbd' || 'samp' || 'tt':
        result['code'] = true;
      case 'sub':
        result['script'] = 'sub';
      case 'sup':
        result['script'] = 'super';
      case 'mark':
        result['background'] = '#ffff00';
      case 'a':
        final href = element.attributes['href'];
        if (href != null) result['link'] = href;
      case 'font':
        final colour = _cssColour(element.attributes['color']);
        if (colour != null) result['color'] = colour;
    }
    // Inside a code block the whole line is code already.
    if (tag == 'pre') result.remove('code');

    final style = element.attributes['style'];
    if (style == null) return result;
    for (final declaration in style.split(';')) {
      final colon = declaration.indexOf(':');
      if (colon < 0) continue;
      final name = declaration.substring(0, colon).trim().toLowerCase();
      final value = declaration.substring(colon + 1).trim().toLowerCase();
      switch (name) {
        case 'font-weight':
          final weight = int.tryParse(value);
          if (value == 'bold' ||
              value == 'bolder' ||
              (weight != null && weight >= 600)) {
            result['bold'] = true;
          } else if (value == 'normal' ||
              value == 'lighter' ||
              (weight != null && weight < 600)) {
            result.remove('bold');
          }
        case 'font-style':
          if (value == 'italic' || value == 'oblique') {
            result['italic'] = true;
          } else if (value == 'normal') {
            result.remove('italic');
          }
        case 'text-decoration' || 'text-decoration-line':
          if (value.contains('underline')) result['underline'] = true;
          if (value.contains('line-through')) result['strike'] = true;
        case 'vertical-align':
          if (value == 'sub') result['script'] = 'sub';
          if (value == 'super') result['script'] = 'super';
        case 'color':
          final colour = _cssColour(value);
          if (colour != null) {
            result['color'] = colour;
          } else {
            result.remove('color');
          }
        case 'background-color' || 'background':
          final colour = _cssColour(value);
          if (colour != null) {
            result['background'] = colour;
          } else if (name == 'background-color') {
            result.remove('background');
          }
      }
    }
    return result;
  }

  /// A CSS colour as `#rrggbb`, or null when it is transparent or not a
  /// colour this code reads (`#hex`, `rgb()`, `rgba()`, basic names).
  static String? _cssColour(String? value) {
    if (value == null) return null;
    final text = value.trim().toLowerCase();
    if (text.startsWith('#')) {
      var hex = text.substring(1);
      if (hex.length == 3 || hex.length == 4) {
        hex = hex.split('').map((c) => '$c$c').join();
      }
      if (hex.length == 8) {
        // CSS order is RRGGBBAA; fully transparent is no colour.
        if (hex.substring(6) == '00') return null;
        hex = hex.substring(0, 6);
      }
      if (hex.length != 6 || int.tryParse(hex, radix: 16) == null) return null;
      return '#$hex';
    }
    final rgb = _rgb.firstMatch(text);
    if (rgb != null) {
      final alpha = rgb.group(4);
      if (alpha != null &&
          (double.tryParse(alpha.replaceAll('%', '')) ?? 1) == 0) {
        return null;
      }
      final channels = [
        for (var i = 1; i <= 3; i++)
          (double.tryParse(rgb.group(i)!) ?? 0).round().clamp(0, 255),
      ];
      final hex = channels
          .map((c) => c.toRadixString(16).padLeft(2, '0'))
          .join();
      return '#$hex';
    }
    return _namedColours[text];
  }
}
