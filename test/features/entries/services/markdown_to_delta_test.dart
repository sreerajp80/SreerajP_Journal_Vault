import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';
import 'package:sreerajp_journal_vault/features/entries/services/markdown_to_delta.dart';

void main() {
  const converter = MarkdownToDelta();

  /// The line-end ops (`\n`) and their block attributes, in order.
  List<Map<String, dynamic>?> lineStyles(List<Map<String, dynamic>> ops) => [
    for (final op in ops)
      if (op['insert'] == '\n') op['attributes'] as Map<String, dynamic>?,
  ];

  Map<String, dynamic>? attributesOf(
    List<Map<String, dynamic>> ops,
    String text,
  ) =>
      ops.firstWhere((op) => op['insert'] == text)['attributes']
          as Map<String, dynamic>?;

  group('blocks', () {
    test('headings 1 to 6, trailing hashes removed', () {
      final ops = converter.convert('# One\n###### Six ##');
      expect(lineStyles(ops), [
        {'header': 1},
        {'header': 6},
      ]);
      expect(ops.first['insert'], 'One');
      expect(ops[2]['insert'], 'Six');
    });

    test('a hashtag without a space is not a heading', () {
      final ops = converter.convert('#journal today');
      expect(lineStyles(ops), [null]);
      expect(ops.first['insert'], '#journal today');
    });

    test('bullet, ordered and task lists', () {
      final ops = converter.convert(
        '- a\n* b\n1. c\n2) d\n- [ ] todo\n- [x] done',
      );
      expect(lineStyles(ops).map((a) => a?['list']), [
        'bullet',
        'bullet',
        'ordered',
        'ordered',
        'unchecked',
        'checked',
      ]);
      expect(attributesOf(ops, 'todo'), isNull);
    });

    test('nested lists get an indent level', () {
      final ops = converter.convert(
        '1. top\n   - child\n      - grandchild\n2. next',
      );
      expect(lineStyles(ops), [
        {'list': 'ordered'},
        {'list': 'bullet', 'indent': 1},
        {'list': 'bullet', 'indent': 2},
        {'list': 'ordered'},
      ]);
    });

    test('quotes, dividers and fenced code', () {
      final ops = converter.convert('> quoted\n---\n```bash\nless -N\n\n```');
      expect(lineStyles(ops), [
        {'blockquote': true},
        null,
        {'code-block': true},
        {'code-block': true},
      ]);
      expect(
        ops.any((op) => op['insert'] == MarkdownToDelta.dividerText),
        isTrue,
      );
      expect(ops.any((op) => op['insert'] == 'less -N'), isTrue);
      expect(ops.any((op) => op['insert'] == '```bash'), isFalse);
    });

    test('Markdown inside a code block stays literal', () {
      final ops = converter.convert('```\n# not a heading **x**\n```');
      expect(ops.first['insert'], '# not a heading **x**');
    });

    test('pipe table becomes a table block', () {
      final ops = converter.convert(
        '| Debian | Ships less |\n|---|---|\n| 11 (**bullseye**) | 551 |\n| 13 |',
      );
      final embed = ops.firstWhere((op) => op['insert'] is Map);
      final table = TableData.tryParse((embed['insert'] as Map)['table'])!;
      expect(table.plainRows, [
        ['Debian', 'Ships less'],
        ['11 (bullseye)', '551'],
        ['13', ''],
      ]);
      // Formatting inside a cell is kept.
      expect(table.cells[1][0], [
        {'insert': '11 ('},
        {
          'insert': 'bullseye',
          'attributes': {'bold': true},
        },
        {'insert': ')'},
      ]);
    });

    test('a link inside a table cell is kept', () {
      final ops = converter.convert(
        '| Site |\n|---|\n| [home](https://example.com) |',
      );
      final embed = ops.firstWhere((op) => op['insert'] is Map);
      final table = TableData.tryParse((embed['insert'] as Map)['table'])!;
      expect(table.cells[1][0].single, {
        'insert': 'home',
        'attributes': {'link': 'https://example.com'},
      });
    });

    test('a paragraph followed by --- is not a table', () {
      final ops = converter.convert('a | b\n---');
      expect(ops.any((op) => op['insert'] is Map), isFalse);
    });

    test('always ends with a newline', () {
      expect(converter.convert(''), [
        {'insert': '\n'},
      ]);
      expect(converter.convert('plain').last['insert'], '\n');
    });
  });

  group('inline', () {
    test('bold, italic, strike and code', () {
      final ops = converter.convert('**b** *i* _u_ ***bi*** ~~s~~ `c` __B__');
      expect(attributesOf(ops, 'b'), {'bold': true});
      expect(attributesOf(ops, 'i'), {'italic': true});
      expect(attributesOf(ops, 'u'), {'italic': true});
      expect(attributesOf(ops, 'bi'), {'bold': true, 'italic': true});
      expect(attributesOf(ops, 's'), {'strike': true});
      expect(attributesOf(ops, 'c'), {'code': true});
      expect(attributesOf(ops, 'B'), {'bold': true});
    });

    test('nested emphasis', () {
      final ops = converter.convert('*a **b** c*');
      expect(attributesOf(ops, 'a '), {'italic': true});
      expect(attributesOf(ops, 'b'), {'italic': true, 'bold': true});
    });

    test('snake_case words and lone stars are left alone', () {
      final ops = converter.convert('my_var_name and 2 * 3 * 4');
      expect(ops.first['insert'], 'my_var_name and 2 * 3 * 4');
    });

    test('escaped characters are literal', () {
      final ops = converter.convert(r'\*not italic\*');
      expect(ops.first['insert'], '*not italic*');
      expect(ops.first['attributes'], isNull);
    });

    test('web links keep the link; anchors keep only the text', () {
      final ops = converter.convert(
        '[site](https://example.org) [Search](#search) <mailto:a@b.c>',
      );
      expect(attributesOf(ops, 'site'), {'link': 'https://example.org'});
      expect(
        ops.any((op) => op['insert'].toString().contains('#search')),
        isFalse,
      );
      expect(
        ops.any((op) => op['insert'].toString().contains('Search')),
        isTrue,
      );
      expect(attributesOf(ops, 'mailto:a@b.c'), {'link': 'mailto:a@b.c'});
    });

    test('bold link text keeps both', () {
      final ops = converter.convert('**[x](https://e.org)**');
      expect(attributesOf(ops, 'x'), {'bold': true, 'link': 'https://e.org'});
    });

    test('stripInline removes the marks', () {
      expect(MarkdownToDelta.stripInline('**a** [b](#c) `d`'), 'a b d');
    });
  });

  test('the sample from the bug report converts cleanly', () {
    const sample = '''# less: quick reference for Debian

Every useful option, key and environment variable of `less`.

## How to read this

| Debian | Ships less |
|---|---|
| 11 (bullseye) | 551 |
| 12 (bookworm) | 590 |

Entries that need a newer less say so, for example *needs less 608+ (Debian 13 only)*.

Levels: **Essential** entries are the ones to learn first.

## Contents

1. [At a glance](#at-a-glance)
2. [Command-line options](#command-line-options)
   - [Search](#search)
   - [Display](#display)
3. [Keys inside less](#keys-inside-less)
''';
    final ops = converter.convert(sample);
    final text = MarkdownToDelta.plainTextOf(ops);
    for (final mark in ['# ', '**', '](#', '|---']) {
      expect(text.contains(mark), isFalse, reason: 'left "$mark" in the text');
    }
    final styles = lineStyles(ops);
    expect(styles.where((a) => a?['header'] != null), hasLength(3));
    expect(styles.where((a) => a?['list'] == 'ordered'), hasLength(3));
    expect(
      styles.where((a) => a?['list'] == 'bullet' && a?['indent'] == 1),
      hasLength(2),
    );
    expect(ops.where((op) => op['insert'] is Map), hasLength(1));
    expect(attributesOf(ops, 'Essential'), {'bold': true});
  });
}
