import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';

void main() {
  group('TableData.tryParse', () {
    test('reads the legacy list format', () {
      final table = TableData.tryParse(
        jsonEncode([
          ['a', 'b'],
          ['c', 'd'],
        ]),
      )!;
      expect(table.plainRows, [
        ['a', 'b'],
        ['c', 'd'],
      ]);
      expect(table.colWidths, isNull);
      expect(table.hasFormatting, isFalse);
    });

    test('reads the envelope format with column widths', () {
      final table = TableData.tryParse(
        jsonEncode({
          'rows': [
            ['a', 'b'],
          ],
          'colWidths': [120, 200.5],
        }),
      )!;
      expect(table.plainRows, [
        ['a', 'b'],
      ]);
      expect(table.colWidths, [120.0, 200.5]);
    });

    test('reads the rich format and prefers its cells over rows', () {
      final table = TableData.tryParse(
        jsonEncode({
          'v': 2,
          'rows': [
            ['stale'],
          ],
          'cells': [
            [
              [
                {
                  'insert': 'bold',
                  'attributes': {'bold': true},
                },
                {'insert': ' plain'},
              ],
            ],
          ],
        }),
      )!;
      expect(table.plainRows, [
        ['bold plain'],
      ]);
      expect(table.hasFormatting, isTrue);
      expect(table.cells[0][0][0]['attributes'], {'bold': true});
    });

    test('falls back to rows when the rich cells are unusable', () {
      final table = TableData.tryParse(
        jsonEncode({
          'v': 2,
          'rows': [
            ['words'],
          ],
          'cells': [
            [42],
          ],
        }),
      )!;
      expect(table.plainRows, [
        ['words'],
      ]);
    });

    test('returns null for unusable data without throwing', () {
      expect(TableData.tryParse('not json'), isNull);
      expect(TableData.tryParse(null), isNull);
      expect(TableData.tryParse(42), isNull);
      expect(TableData.tryParse(jsonEncode({'nothing': true})), isNull);
    });

    test('reads a cell that is null or a number as text', () {
      final table = TableData.tryParse(
        jsonEncode([
          [null, 7],
        ]),
      )!;
      expect(table.plainRows, [
        ['', '7'],
      ]);
    });
  });

  group('TableData.toJsonString', () {
    test('writes a plain table in the legacy format', () {
      final json = TableData.fromPlainRows([
        ['a', 'b'],
      ]).toJsonString();
      expect(jsonDecode(json), [
        ['a', 'b'],
      ]);
    });

    test('writes a plain table with widths in the envelope format', () {
      final json = TableData.fromPlainRows(
        [
          ['a'],
        ],
        colWidths: [100],
      ).toJsonString();
      expect(jsonDecode(json), {
        'rows': [
          ['a'],
        ],
        'colWidths': [100.0],
      });
    });

    test('writes a formatted table in the rich format, with plain rows', () {
      final table = TableData(
        cells: [
          [
            [
              {
                'insert': 'Hi',
                'attributes': {'italic': true},
              },
            ],
            [
              {'insert': 'there'},
            ],
          ],
        ],
      );
      final decoded = jsonDecode(table.toJsonString()) as Map;
      expect(decoded['v'], TableData.richVersion);
      // Older app versions read only `rows`, so it must hold the words.
      expect(decoded['rows'], [
        ['Hi', 'there'],
      ]);
      expect(decoded.containsKey('colWidths'), isFalse);
      expect(TableData.tryParse(table.toJsonString())!.cells, table.cells);
    });
  });

  group('TableData.normalizeCell', () {
    test('drops the trailing newline, embeds and unknown attributes', () {
      final cell = TableData.normalizeCell([
        {
          'insert': 'Title',
          'attributes': {'bold': true, 'header': 1, 'font': 'serif'},
        },
        {
          'insert': {'image': 'x.png'},
        },
        {
          'insert': '\n',
          'attributes': {'header': 1},
        },
      ]);
      expect(cell, [
        {
          'insert': 'Title',
          'attributes': {'bold': true},
        },
      ]);
    });

    test('keeps a line break inside the cell', () {
      final cell = TableData.normalizeCell([
        {'insert': 'one\ntwo\n'},
      ]);
      expect(TableData.cellPlainText(cell), 'one\ntwo');
    });

    test('merges neighbouring runs with the same formatting', () {
      final cell = TableData.normalizeCell([
        {
          'insert': 'a',
          'attributes': {'bold': true},
        },
        {
          'insert': 'b',
          'attributes': {'bold': true},
        },
        {'insert': 'c'},
      ]);
      expect(cell, [
        {
          'insert': 'ab',
          'attributes': {'bold': true},
        },
        {'insert': 'c'},
      ]);
    });

    test('keeps links, colours and scripts as strings only', () {
      final cell = TableData.normalizeCell([
        {
          'insert': 'x',
          'attributes': {
            'link': 'https://example.com',
            'color': '#FF0000',
            'script': 'super',
            'bold': 'yes',
          },
        },
      ]);
      expect(cell.single['attributes'], {
        'link': 'https://example.com',
        'color': '#FF0000',
        'script': 'super',
      });
    });
  });

  test('searchText joins cells with spaces and rows with new lines', () {
    final table = TableData.fromPlainRows([
      ['Name', 'Place'],
      ['Anu', ''],
      ['', ''],
      ['two\nlines', 'Kochi'],
    ]);
    expect(table.searchText, 'Name Place\nAnu\ntwo lines Kochi\n');
  });

  test('keeps Malayalam and Devanagari text unchanged', () {
    const ml = 'മലയാളം';
    const sa = 'संस्कृतम्';
    final table = TableData.tryParse(
      TableData.fromPlainRows([
        [ml, sa],
      ]).toJsonString(),
    )!;
    expect(table.plainRows, [
      [ml, sa],
    ]);
  });
}
