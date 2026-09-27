import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_html.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_markdown.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_plain_text.dart';

import '../../helpers/export_labels.dart';

/// Covers exporting tables in every stored format, including the rich format
/// whose cells carry formatting and links.

String _tableDelta(Object tableData) => jsonEncode([
  {
    'insert': {'table': jsonEncode(tableData)},
  },
  {'insert': '\n'},
]);

/// A rich (v2) table: header row plus one row with bold text and a link.
final Map<String, dynamic> _richTable = {
  'v': 2,
  'rows': [
    ['Name', 'Site'],
    ['Anu', 'Home'],
  ],
  'cells': [
    [
      [
        {'insert': 'Name'},
      ],
      [
        {'insert': 'Site'},
      ],
    ],
    [
      [
        {
          'insert': 'Anu',
          'attributes': {'bold': true},
        },
      ],
      [
        {
          'insert': 'Home',
          'attributes': {'link': 'https://example.com/a|b'},
        },
      ],
    ],
  ],
};

void main() {
  group('parseDelta — table formats', () {
    test('reads a table whose columns were resized (envelope format)', () {
      final blocks = parseDelta(
        _tableDelta({
          'rows': [
            ['a', 'b'],
          ],
          'colWidths': [100, 200],
        }),
      );
      // Before this fix a resized table exported as "[unexportable block]".
      expect(blocks.whereType<UnknownEmbedBlock>(), isEmpty);
      expect(blocks.whereType<TableBlock>().single.rows, [
        ['a', 'b'],
      ]);
    });

    test('reads a rich table with its cell styling', () {
      final table = parseDelta(
        _tableDelta(_richTable),
      ).whereType<TableBlock>().single;
      expect(table.rows[1], ['Anu', 'Home']);
      final anu = table.cells[1][0].single;
      expect(anu.text, 'Anu');
      expect(anu.bold, isTrue);
      expect(table.cells[1][1].single.link, 'https://example.com/a|b');
    });

    test('a plain table has unstyled cells', () {
      final table = parseDelta(
        _tableDelta([
          ['x', ''],
        ]),
      ).whereType<TableBlock>().single;
      expect(table.richCells, isNull);
      expect(table.cells[0][0].single.text, 'x');
      expect(table.cells[0][1], isEmpty);
    });
  });

  group('renderHtml — rich table cells', () {
    test('keeps bold and links inside cells', () {
      final html = renderHtml(
        labels: englishExportLabels,
        parseDelta(_tableDelta(_richTable)),
      );
      expect(html, contains('<td><strong>Anu</strong></td>'));
      expect(
        html,
        contains('<td><a href="https://example.com/a|b">Home</a></td>'),
      );
    });

    test('never emits an unsafe link or raw markup from a cell', () {
      final html = renderHtml(labels: englishExportLabels, [
        const TableBlock(
          [
            ['h'],
            ['x'],
          ],
          richCells: [
            [
              [InlineSpan(text: 'h')],
            ],
            [
              [InlineSpan(text: '<b>x</b>', link: 'javascript:alert(1)')],
            ],
          ],
        ),
      ]);
      expect(html, isNot(contains('javascript')));
      expect(html, contains('&lt;b&gt;x&lt;/b&gt;'));
    });

    test('writes a line break inside a cell as <br>', () {
      final html = renderHtml(labels: englishExportLabels, [
        const TableBlock([
          ['one\ntwo'],
        ]),
      ]);
      expect(html, contains('<th>one<br>two</th>'));
    });
  });

  group('renderMarkdown — rich table cells', () {
    test('keeps bold and links inside cells, escaping pipes', () {
      final md = renderMarkdown(
        labels: englishExportLabels,
        parseDelta(_tableDelta(_richTable)),
      );
      expect(md, contains(r'| **Anu** | [Home](https://example.com/a\|b) |'));
    });

    test('writes a line break inside a cell as <br>', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        const TableBlock([
          ['one\ntwo'],
        ]),
      ]);
      expect(md, contains('| one<br>two |'));
    });
  });

  test('renderPlainText writes a rich table as its words', () {
    final text = renderPlainText(
      labels: englishExportLabels,
      parseDelta(_tableDelta(_richTable)),
    );
    expect(text, contains('Anu'));
    expect(text, contains('Home'));
    expect(text, isNot(contains('**')));
    expect(text, isNot(contains('https://')));
  });
}
