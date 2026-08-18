import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';

/// Covers the shared delta parser that all three export renderers walk.
///
/// The bad-input group is the important one: an entry written years ago, or by
/// a newer build, must never make the vault unexportable.
String _delta(List<Map<String, dynamic>> ops) => jsonEncode(ops);

void main() {
  group('parseDelta — text and block styles', () {
    test('reads a plain paragraph', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'hello\n'},
        ]),
      );

      expect(blocks, hasLength(1));
      final block = blocks.single as TextBlock;
      expect(block.plainText, 'hello');
      expect(block.style, BlockStyle.paragraph);
    });

    test('splits a multi-line insert into one block per line', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'one\ntwo\nthree\n'},
        ]),
      );

      expect(blocks.whereType<TextBlock>().map((b) => b.plainText), [
        'one',
        'two',
        'three',
      ]);
    });

    test('takes the block style from the newline op, not the text op', () {
      // This is the delta rule the parser exists to centralise.
      final blocks = parseDelta(
        _delta([
          {'insert': 'My heading'},
          {
            'insert': '\n',
            'attributes': {'header': 1},
          },
        ]),
      );

      final block = blocks.single as TextBlock;
      expect(block.plainText, 'My heading');
      expect(block.style, BlockStyle.heading1);
    });

    test('reads all three heading levels and clamps deeper ones', () {
      BlockStyle styleFor(int level) {
        final blocks = parseDelta(
          _delta([
            {'insert': 'h'},
            {
              'insert': '\n',
              'attributes': {'header': level},
            },
          ]),
        );
        return (blocks.single as TextBlock).style;
      }

      expect(styleFor(1), BlockStyle.heading1);
      expect(styleFor(2), BlockStyle.heading2);
      expect(styleFor(3), BlockStyle.heading3);
      // The toolbar offers three levels; an imported h6 is clamped, not lost.
      expect(styleFor(6), BlockStyle.heading3);
    });

    test('reads every list kind', () {
      BlockStyle styleFor(String list) {
        final blocks = parseDelta(
          _delta([
            {'insert': 'item'},
            {
              'insert': '\n',
              'attributes': {'list': list},
            },
          ]),
        );
        return (blocks.single as TextBlock).style;
      }

      expect(styleFor('bullet'), BlockStyle.bulletList);
      expect(styleFor('ordered'), BlockStyle.orderedList);
      expect(styleFor('checked'), BlockStyle.checkedList);
      expect(styleFor('unchecked'), BlockStyle.uncheckedList);
    });

    test('reads blockquote and code-block', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'quoted'},
          {
            'insert': '\n',
            'attributes': {'blockquote': true},
          },
          {'insert': 'coded'},
          {
            'insert': '\n',
            'attributes': {'code-block': true},
          },
        ]),
      );

      expect((blocks[0] as TextBlock).style, BlockStyle.blockquote);
      expect((blocks[1] as TextBlock).style, BlockStyle.codeBlock);
    });

    test('reads the list indent level', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'nested'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet', 'indent': 2},
          },
        ]),
      );

      expect((blocks.single as TextBlock).indent, 2);
    });

    test('caps a runaway indent value', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'x'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet', 'indent': 9999},
          },
        ]),
      );

      expect((blocks.single as TextBlock).indent, 8);
    });

    test('drops the trailing empty paragraph Quill always keeps', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'only line\n'},
        ]),
      );

      expect(blocks, hasLength(1));
    });

    test('keeps blank lines the user typed in the middle', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'a\n\nb\n'},
        ]),
      );

      expect(blocks.whereType<TextBlock>().map((b) => b.plainText), [
        'a',
        '',
        'b',
      ]);
    });
  });

  group('parseDelta — inline styles', () {
    test('reads each inline style', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': 'styled',
            'attributes': {
              'bold': true,
              'italic': true,
              'underline': true,
              'strike': true,
              'code': true,
              'link': 'https://example.com',
            },
          },
          {'insert': '\n'},
        ]),
      );

      final span = (blocks.single as TextBlock).spans.single;
      expect(span.bold, isTrue);
      expect(span.italic, isTrue);
      expect(span.underline, isTrue);
      expect(span.strikethrough, isTrue);
      expect(span.code, isTrue);
      expect(span.link, 'https://example.com');
    });

    test('merges neighbouring spans that share styling', () {
      // Quill often splits text across ops mid-edit. Rendering each separately
      // would produce "**a****b**".
      final blocks = parseDelta(
        _delta([
          {
            'insert': 'a',
            'attributes': {'bold': true},
          },
          {
            'insert': 'b',
            'attributes': {'bold': true},
          },
          {'insert': '\n'},
        ]),
      );

      final spans = (blocks.single as TextBlock).spans;
      expect(spans, hasLength(1));
      expect(spans.single.text, 'ab');
    });

    test('does not merge spans with different styling', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': 'a',
            'attributes': {'bold': true},
          },
          {
            'insert': 'b',
            'attributes': {'italic': true},
          },
          {'insert': '\n'},
        ]),
      );

      expect((blocks.single as TextBlock).spans, hasLength(2));
    });

    test('ignores an empty link', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': 'text',
            'attributes': {'link': ''},
          },
          {'insert': '\n'},
        ]),
      );

      expect((blocks.single as TextBlock).spans.single.link, isNull);
    });
  });

  group('parseDelta — embeds', () {
    test('reads a table embed', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': {
              'table': jsonEncode([
                ['a', 'b'],
                ['c', 'd'],
              ]),
            },
          },
          {'insert': '\n'},
        ]),
      );

      final table = blocks.whereType<TableBlock>().single;
      expect(table.rows, [
        ['a', 'b'],
        ['c', 'd'],
      ]);
    });

    test('reads a callout embed', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': {
              'callout': jsonEncode({'style': 'warning', 'text': 'careful'}),
            },
          },
          {'insert': '\n'},
        ]),
      );

      final callout = blocks.whereType<CalloutBlock>().single;
      expect(callout.style, 'warning');
      expect(callout.text, 'careful');
    });

    test('reads an inline image embed', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': {
              'vault_image': jsonEncode({
                'attachmentId': 12,
                'fileName': 'beach.jpg',
                'widthFactor': 1.0,
              }),
            },
          },
          {'insert': '\n'},
        ]),
      );

      final image = blocks.whereType<ImageBlock>().single;
      expect(image.attachmentId, 12);
      expect(image.fileName, 'beach.jpg');
    });

    test('an image embed with no usable id is named, not invented', () {
      // An id of 0 points at no row at all, so the renderers could never find
      // the picture. Better to say an embed was here than to promise an image.
      for (final data in <String>[
        jsonEncode({'attachmentId': 0, 'fileName': 'x.jpg'}),
        jsonEncode({'fileName': 'x.jpg'}),
        'not json',
      ]) {
        final blocks = parseDelta(
          _delta([
            {
              'insert': {'vault_image': data},
            },
            {'insert': '\n'},
          ]),
        );

        expect(blocks.whereType<ImageBlock>(), isEmpty);
        expect(
          blocks.whereType<UnknownEmbedBlock>().single.type,
          'vault_image',
        );
      }
    });

    test('keeps text that came before an embed on the same line', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'before'},
          {
            'insert': {
              'callout': jsonEncode({'style': 'info', 'text': 'c'}),
            },
          },
          {'insert': '\n'},
        ]),
      );

      expect((blocks.first as TextBlock).plainText, 'before');
      expect(blocks[1], isA<CalloutBlock>());
    });

    test('keeps an unknown embed as a named placeholder', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': {'sketch': 'whatever'},
          },
          {'insert': '\n'},
        ]),
      );

      expect(blocks.whereType<UnknownEmbedBlock>().single.type, 'sketch');
    });
  });

  group('parseDelta — bad input never throws', () {
    test('falls back to plain text when the JSON is corrupt', () {
      final blocks = parseDelta(
        '{not json at all',
        fallbackPlainText: 'the words survive',
      );

      expect((blocks.single as TextBlock).plainText, 'the words survive');
    });

    test('falls back to plain text when contentJson is null', () {
      final blocks = parseDelta(null, fallbackPlainText: 'saved text');
      expect((blocks.single as TextBlock).plainText, 'saved text');
    });

    test('returns nothing when there is no content at all', () {
      expect(parseDelta(null), isEmpty);
      expect(parseDelta(''), isEmpty);
      expect(parseDelta('[]'), isEmpty);
    });

    test('accepts the {"ops": [...]} wrapper form', () {
      final blocks = parseDelta(
        jsonEncode({
          'ops': [
            {'insert': 'wrapped\n'},
          ],
        }),
      );

      expect((blocks.single as TextBlock).plainText, 'wrapped');
    });

    test('skips ops that are not maps', () {
      final blocks = parseDelta(
        jsonEncode([
          'a stray string',
          {'insert': 'real\n'},
        ]),
      );

      expect((blocks.single as TextBlock).plainText, 'real');
    });

    test('survives a table embed holding unusable data', () {
      final blocks = parseDelta(
        _delta([
          {
            'insert': {'table': 'not json'},
          },
          {'insert': '\n'},
        ]),
      );

      expect(blocks.whereType<UnknownEmbedBlock>().single.type, 'table');
    });

    test('survives attributes of an unexpected type', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'text'},
          {'insert': '\n', 'attributes': 'not a map'},
        ]),
      );

      expect((blocks.single as TextBlock).style, BlockStyle.paragraph);
    });

    test('keeps trailing text when the delta has no final newline', () {
      final blocks = parseDelta(
        _delta([
          {'insert': 'no newline at the end'},
        ]),
      );

      expect((blocks.single as TextBlock).plainText, 'no newline at the end');
    });
  });
}
