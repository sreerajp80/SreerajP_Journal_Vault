import 'package:flutter_test/flutter_test.dart';
import '../../helpers/export_labels.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_plain_text.dart';

/// Covers the plain-text renderer.
///
/// The rule being tested throughout: styling may be lost, but no *content* is.
/// A `.txt` export is what someone falls back to when every other format has
/// failed them.
TextBlock _text(
  String text, {
  BlockStyle style = BlockStyle.paragraph,
  int indent = 0,
}) => TextBlock(
  spans: [InlineSpan(text: text)],
  style: style,
  indent: indent,
);

void main() {
  group('renderPlainText — block styles', () {
    test('underlines a heading instead of inventing syntax', () {
      expect(
        renderPlainText(labels: englishExportLabels, [
          _text('Title', style: BlockStyle.heading1),
        ]),
        'Title\n=====',
      );
      expect(
        renderPlainText(labels: englishExportLabels, [
          _text('Sub', style: BlockStyle.heading2),
        ]),
        'Sub\n---',
      );
    });

    test('measures the heading rule in characters, not bytes', () {
      // Four Malayalam letters must draw a four-character rule, not twelve.
      final out = renderPlainText(labels: englishExportLabels, [
        _text('ഡയറി', style: BlockStyle.heading1),
      ]);
      expect(out, 'ഡയറി\n====');
    });

    test('caps the rule under a very long heading', () {
      final out = renderPlainText(labels: englishExportLabels, [
        _text('x' * 200, style: BlockStyle.heading1),
      ]);
      expect(out.split('\n').last.length, 80);
    });

    test('renders bullet and numbered lists', () {
      expect(
        renderPlainText(labels: englishExportLabels, [
          _text('a', style: BlockStyle.bulletList),
          _text('b', style: BlockStyle.bulletList),
        ]),
        '* a\n* b',
      );
      expect(
        renderPlainText(labels: englishExportLabels, [
          _text('a', style: BlockStyle.orderedList),
          _text('b', style: BlockStyle.orderedList),
        ]),
        '1. a\n2. b',
      );
    });

    test('shows task state with brackets', () {
      final out = renderPlainText(labels: englishExportLabels, [
        _text('done', style: BlockStyle.checkedList),
        _text('todo', style: BlockStyle.uncheckedList),
      ]);
      expect(out, contains('[x] done'));
      expect(out, contains('[ ] todo'));
    });

    test('indents nested items', () {
      final out = renderPlainText(labels: englishExportLabels, [
        _text('top', style: BlockStyle.bulletList),
        _text('under', style: BlockStyle.bulletList, indent: 1),
      ]);
      expect(out, '* top\n    * under');
    });

    test('marks a blockquote and indents a code block', () {
      expect(
        renderPlainText(labels: englishExportLabels, [
          _text('q', style: BlockStyle.blockquote),
        ]),
        '> q',
      );
      expect(
        renderPlainText(labels: englishExportLabels, [
          _text('code', style: BlockStyle.codeBlock),
        ]),
        '    code',
      );
    });
  });

  group('renderPlainText — styling is dropped, content is not', () {
    test('keeps the text of every styled span', () {
      final out = renderPlainText(labels: englishExportLabels, [
        const TextBlock(
          spans: [
            InlineSpan(text: 'bold', bold: true),
            InlineSpan(text: ' and '),
            InlineSpan(text: 'link', link: 'https://example.com'),
          ],
        ),
      ]);
      expect(out, 'bold and link');
    });

    test('keeps Malayalam text unchanged', () {
      expect(
        renderPlainText(labels: englishExportLabels, [_text('ഡയറി')]),
        'ഡയറി',
      );
    });
  });

  group('renderPlainText — embeds', () {
    test('lines a table up in padded columns', () {
      final out = renderPlainText(labels: englishExportLabels, [
        const TableBlock([
          ['Name', 'Value'],
          ['a', '1'],
        ]),
      ]);
      final lines = out.trim().split('\n');
      expect(lines.first, 'Name  Value');
      expect(lines[1], contains('---'));
      expect(lines[2], 'a     1');
    });

    test('pads Malayalam cells by character count', () {
      final out = renderPlainText(labels: englishExportLabels, [
        const TableBlock([
          ['ഡയറി', 'x'],
          ['a', 'y'],
        ]),
      ]);
      final lines = out.trim().split('\n');
      // Both data rows must start their second column at the same offset.
      expect(lines.first.indexOf('x'), lines.last.indexOf('y'));
    });

    test('keeps a callout with its label and text', () {
      final out = renderPlainText(labels: englishExportLabels, [
        const CalloutBlock(style: 'tip', text: 'try this'),
      ]);
      expect(out, contains('[Tip]'));
      expect(out, contains('try this'));
    });

    test('names an unknown embed rather than dropping it silently', () {
      final out = renderPlainText(labels: englishExportLabels, [
        const UnknownEmbedBlock('sketch'),
      ]);
      expect(out, contains('sketch'));
    });

    test('names an inline image so the reader knows one was there', () {
      final out = renderPlainText(labels: englishExportLabels, [
        const ImageBlock(attachmentId: 12, fileName: 'beach.jpg'),
      ]);
      expect(out, contains('[Image: beach.jpg]'));
    });

    test('an image with no file name still says there was an image', () {
      final out = renderPlainText(labels: englishExportLabels, [
        const ImageBlock(attachmentId: 12, fileName: ''),
      ]);
      expect(out, contains('[Image]'));
    });
  });

  test('renders an empty document as an empty string', () {
    expect(renderPlainText(labels: englishExportLabels, const []), '');
  });
}
