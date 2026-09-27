import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';
import 'package:sreerajp_journal_vault/features/entries/services/html_to_delta.dart';

/// Covers turning pasted HTML into entry content.
///
/// The samples are shaped like real clipboard HTML: Chrome wraps the copy in
/// `<html><body>` with fragment comments, Google Docs wraps everything in a
/// `<b id="docs-internal-guid-…">` and uses numeric font weights, and Word
/// adds `<o:p>` tags and mso- styles.

const _converter = HtmlToJournalDelta();

List<Map<String, dynamic>> _convert(String html, {bool inlineOnly = false}) =>
    _converter.convert(html, inlineOnly: inlineOnly)!;

String _text(List<Map<String, dynamic>> ops) =>
    ops.map((op) => op['insert']).whereType<String>().join();

/// The ops whose text contains [text].
Map<String, dynamic> _opWith(List<Map<String, dynamic>> ops, String text) =>
    ops.firstWhere(
      (op) => op['insert'] is String && (op['insert'] as String).contains(text),
    );

/// The attributes on the newline that ends the line holding [text].
Map<String, dynamic>? _lineAttributes(
  List<Map<String, dynamic>> ops,
  String text,
) {
  var found = false;
  for (final op in ops) {
    final insert = op['insert'];
    if (insert is! String) continue;
    if (insert.contains(text)) found = true;
    if (found && insert.contains('\n')) {
      return op['attributes'] as Map<String, dynamic>?;
    }
  }
  return null;
}

List<TableData> _tables(List<Map<String, dynamic>> ops) => [
  for (final op in ops)
    if (op['insert'] is Map)
      TableData.tryParse((op['insert'] as Map)[TableData.tableEmbedType])!,
];

void main() {
  group('text formatting', () {
    test('keeps headings, bold, italic, underline, strike and code', () {
      final ops = _convert(
        '<html><body><!--StartFragment-->'
        '<h2>Trip</h2>'
        '<p><b>bold</b> <i>italic</i> <u>under</u> <s>gone</s> '
        '<code>x()</code></p>'
        '<!--EndFragment--></body></html>',
      );
      expect(_lineAttributes(ops, 'Trip'), {'header': 2});
      expect(_opWith(ops, 'bold')['attributes'], {'bold': true});
      expect(_opWith(ops, 'italic')['attributes'], {'italic': true});
      expect(_opWith(ops, 'under')['attributes'], {'underline': true});
      expect(_opWith(ops, 'gone')['attributes'], {'strike': true});
      expect(_opWith(ops, 'x()')['attributes'], {'code': true});
      expect(ops.last['insert'], endsWith('\n'));
    });

    test('keeps nested bullet, numbered and check lists', () {
      final ops = _convert(
        '<ul><li>one<ul><li>inner</li></ul></li></ul>'
        '<ol><li>first</li></ol>',
      );
      expect(_lineAttributes(ops, 'one'), {'list': 'bullet'});
      expect(_lineAttributes(ops, 'inner'), {'list': 'bullet', 'indent': 1});
      expect(_lineAttributes(ops, 'first'), {'list': 'ordered'});
    });

    test('keeps quotes and code blocks with their line breaks', () {
      final ops = _convert(
        '<blockquote>wise words</blockquote><pre>line 1\nline 2</pre>',
      );
      expect(_lineAttributes(ops, 'wise words'), {'blockquote': true});
      expect(_text(ops), contains('line 1\nline 2'));
      expect(_lineAttributes(ops, 'line 1'), {'code-block': true});
    });

    test('collapses source line breaks into spaces, as a browser does', () {
      final ops = _convert('<p>Hello\n   world</p>');
      expect(_text(ops), 'Hello world\n');
    });

    test('keeps Malayalam and Devanagari text unchanged', () {
      final ops = _convert('<p>മലയാളം <b>संस्कृतम्</b></p>');
      expect(_text(ops), 'മലയാളം संस्कृतम्\n');
    });
  });

  group('links', () {
    test('keeps web, mail and phone links', () {
      final ops = _convert(
        '<p><a href="https://example.com">web</a> '
        '<a href="mailto:a@example.com">mail</a> '
        '<a href="tel:+911234">phone</a></p>',
      );
      expect(_opWith(ops, 'web')['attributes'], {
        'link': 'https://example.com',
      });
      expect(_opWith(ops, 'mail')['attributes'], {
        'link': 'mailto:a@example.com',
      });
      expect(_opWith(ops, 'phone')['attributes'], {'link': 'tel:+911234'});
    });

    test('drops unsafe and in-page links but keeps their text', () {
      final ops = _convert(
        '<p><a href="javascript:alert(1)">bad</a> '
        '<a href="#contents">anchor</a> '
        '<a href="file:///etc/passwd">file</a> '
        '<a href="/relative">rel</a></p>',
      );
      expect(_text(ops), 'bad anchor file rel\n');
      for (final op in ops) {
        final attributes = op['attributes'] as Map<String, dynamic>?;
        expect(attributes?['link'], isNull);
      }
    });
  });

  group('tables', () {
    test('turns a simple table into a table block', () {
      final ops = _convert(
        '<p>Before</p>'
        '<table><tr><td>a</td><td>b</td></tr>'
        '<tr><td>c</td><td>d</td></tr></table>'
        '<p>After</p>',
      );
      final table = _tables(ops).single;
      expect(table.plainRows, [
        ['a', 'b'],
        ['c', 'd'],
      ]);
      expect(_text(ops), 'Before\n\nAfter\n');
      // The table sits on its own line, between the paragraphs.
      final index = ops.indexWhere((op) => op['insert'] is Map);
      expect((ops[index - 1]['insert'] as String).endsWith('\n'), isTrue);
      expect((ops[index + 1]['insert'] as String).startsWith('\n'), isTrue);
    });

    test('reads <thead>/<th> as bold header cells', () {
      final table = _tables(
        _convert(
          '<table><thead><tr><th>Name</th><th>City</th></tr></thead>'
          '<tbody><tr><td>Anu</td><td>Kochi</td></tr></tbody></table>',
        ),
      ).single;
      expect(table.plainRows, [
        ['Name', 'City'],
        ['Anu', 'Kochi'],
      ]);
      expect(table.cells[0][0].single['attributes'], {'bold': true});
      expect(table.cells[1][0].single['attributes'], isNull);
    });

    test('finds a table nested inside a <div>, as Chrome copies it', () {
      final ops = _convert(
        '<html><body><!--StartFragment--><div class="wrap"><div>'
        '<table class="wikitable"><tbody>\n'
        '  <tr>\n    <th>Year</th>\n    <th>Event</th>\n  </tr>\n'
        '  <tr>\n    <td>1956</td>\n    <td>Kerala formed</td>\n  </tr>\n'
        '</tbody></table></div></div><!--EndFragment--></body></html>',
      );
      expect(_tables(ops).single.plainRows, [
        ['Year', 'Event'],
        ['1956', 'Kerala formed'],
      ]);
    });

    test('keeps bold and links inside cells', () {
      final table = _tables(
        _convert(
          '<table><tr><td><b>Anu</b> said</td>'
          '<td><a href="https://example.com">site</a></td></tr></table>',
        ),
      ).single;
      expect(table.cells[0][0], [
        {
          'insert': 'Anu',
          'attributes': {'bold': true},
        },
        {'insert': ' said'},
      ]);
      expect(table.cells[0][1].single['attributes'], {
        'link': 'https://example.com',
      });
    });

    test('keeps line breaks inside a cell and drops block styles', () {
      final table = _tables(
        _convert(
          '<table><tr><td><p>one</p><p>two</p></td>'
          '<td><h1>big</h1></td></tr></table>',
        ),
      ).single;
      expect(table.plainRows, [
        ['one\ntwo', 'big'],
      ]);
    });

    test('fills colspan and short rows with blank cells', () {
      final table = _tables(
        _convert(
          '<table><tr><td colspan="2">wide</td><td>x</td></tr>'
          '<tr><td>a</td></tr></table>',
        ),
      ).single;
      expect(table.plainRows, [
        ['wide', '', 'x'],
        ['a', '', ''],
      ]);
    });

    test('reads a table inside a cell as that cell\'s text', () {
      final table = _tables(
        _convert(
          '<table><tr><td>outer</td><td>'
          '<table><tr><td>in1</td><td>in2</td></tr></table>'
          '</td></tr></table>',
        ),
      ).single;
      expect(table.rowCount, 1);
      expect(table.plainRows[0][0], 'outer');
      expect(table.plainRows[0][1], contains('in1'));
      expect(table.plainRows[0][1], contains('in2'));
    });

    test('keeps two tables apart', () {
      final tables = _tables(
        _convert(
          '<table><tr><td>first</td></tr></table><p>mid</p>'
          '<table><tr><td>second</td></tr></table>',
        ),
      );
      expect(tables.map((t) => t.plainRows), [
        [
          ['first'],
        ],
        [
          ['second'],
        ],
      ]);
    });
  });

  group('office and Docs clipboard HTML', () {
    test('the Google Docs wrapper does not make everything bold', () {
      final ops = _convert(
        '<meta charset="utf-8"><b style="font-weight:normal;" '
        'id="docs-internal-guid-1234"><p dir="ltr"><span '
        'style="font-size:11pt;font-family:Arial;color:#000000;'
        'font-weight:400;">plain</span><span style="font-size:11pt;'
        'font-family:Arial;color:#000000;font-weight:700;">strong</span>'
        '</p></b>',
      );
      expect(_opWith(ops, 'plain')['attributes'], isNull);
      expect(_opWith(ops, 'strong')['attributes'], {'bold': true});
    });

    test('drops Word <o:p> tags and mso- styles', () {
      final ops = _convert(
        '<p class="MsoNormal" style="mso-margin-top-alt:auto">'
        'Dear diary<o:p></o:p></p>',
      );
      expect(_text(ops), 'Dear diary\n');
    });
  });

  group('colours and fonts', () {
    test('drops black, white and grey; keeps a real colour', () {
      final ops = _convert(
        '<p><span style="color:#000000">black</span> '
        '<span style="color:rgb(68,68,68)">grey</span> '
        '<span style="background-color:#ffffff">white</span> '
        '<span style="color:#cc0000">red</span> '
        '<span style="background-color:yellow">marked</span></p>',
      );
      expect(_opWith(ops, 'black')['attributes'], isNull);
      expect(_opWith(ops, 'grey')['attributes'], isNull);
      expect(_opWith(ops, 'white')['attributes'], isNull);
      expect(_opWith(ops, 'red')['attributes'], {'color': '#cc0000'});
      expect(_opWith(ops, 'marked')['attributes'], {'background': '#ffff00'});
    });

    test('drops font family and size', () {
      final ops = _convert(
        '<p><span style="font-family:Georgia;font-size:24px">big</span></p>',
      );
      expect(_opWith(ops, 'big')['attributes'], isNull);
    });
  });

  group('never pasted', () {
    test('images are removed; their alt text is kept', () {
      final ops = _convert(
        '<p>Look <img src="https://tracker.example.com/pixel.gif">'
        '<img src="https://example.com/cat.jpg" alt="a cat"></p>',
      );
      expect(ops.where((op) => op['insert'] is Map), isEmpty);
      expect(_text(ops), 'Look a cat\n');
    });

    test('scripts, styles and video are removed', () {
      final ops = _convert(
        '<style>p{color:red}</style><script>alert(1)</script>'
        '<p>safe</p><video src="v.mp4"></video>',
      );
      expect(_text(ops), 'safe\n');
    });
  });

  group('edge cases', () {
    test('empty or whitespace-only HTML gives null', () {
      expect(_converter.convert(''), isNull);
      expect(_converter.convert('<p>  </p>'), isNull);
      expect(_converter.convert('<img src="x.png">'), isNull);
    });

    test('broken HTML does not throw', () {
      expect(
        () => _converter.convert('<table><tr><td>open <b>bold <p>and'),
        returnsNormally,
      );
      final ops = _converter.convert('<table><tr><td>open <b>bold <p>and');
      expect(ops, isNotNull);
    });

    test('inlineOnly keeps marks but no line styles or tables', () {
      final ops = _convert(
        '<h1>Head</h1><ul><li><i>item</i></li></ul>'
        '<table><tr><td>a</td><td>b</td></tr></table>',
        inlineOnly: true,
      );
      expect(ops.where((op) => op['insert'] is Map), isEmpty);
      for (final op in ops) {
        final attributes = op['attributes'] as Map<String, dynamic>?;
        expect(attributes?.keys ?? const <String>[], isNot(contains('header')));
        expect(attributes?.keys ?? const <String>[], isNot(contains('list')));
      }
      expect(_opWith(ops, 'item')['attributes'], {'italic': true});
      expect(_text(ops), contains('a'));
      expect(_text(ops), contains('b'));
    });
  });
}
