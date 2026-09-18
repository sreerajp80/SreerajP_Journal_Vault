import 'package:flutter_test/flutter_test.dart';
import '../../helpers/export_labels.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_markdown.dart';

/// Covers the Markdown renderer — the mirror of `markdown_import_adapter.dart`.
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
  group('renderMarkdown — block styles', () {
    test('renders the three heading levels', () {
      expect(
        renderMarkdown(labels: englishExportLabels, [
          _text('One', style: BlockStyle.heading1),
        ]),
        '# One',
      );
      expect(
        renderMarkdown(labels: englishExportLabels, [
          _text('Two', style: BlockStyle.heading2),
        ]),
        '## Two',
      );
      expect(
        renderMarkdown(labels: englishExportLabels, [
          _text('Three', style: BlockStyle.heading3),
        ]),
        '### Three',
      );
    });

    test('renders a bullet list', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        _text('a', style: BlockStyle.bulletList),
        _text('b', style: BlockStyle.bulletList),
      ]);
      expect(md, '- a\n- b');
    });

    test('numbers an ordered list from one', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        _text('a', style: BlockStyle.orderedList),
        _text('b', style: BlockStyle.orderedList),
        _text('c', style: BlockStyle.orderedList),
      ]);
      expect(md, '1. a\n2. b\n3. c');
    });

    test('restarts numbering for a second, separate list', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        _text('a', style: BlockStyle.orderedList),
        _text('para'),
        _text('b', style: BlockStyle.orderedList),
      ]);
      expect(md, contains('1. a'));
      expect(md, contains('1. b'));
      expect(md, isNot(contains('2.')));
    });

    test('renders task list items', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        _text('done', style: BlockStyle.checkedList),
        _text('todo', style: BlockStyle.uncheckedList),
      ]);
      expect(md, contains('- [x] done'));
      expect(md, contains('- [ ] todo'));
    });

    test('indents a nested list', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        _text('top', style: BlockStyle.bulletList),
        _text('nested', style: BlockStyle.bulletList, indent: 1),
      ]);
      expect(md, '- top\n  - nested');
    });

    test('renders a blockquote', () {
      expect(
        renderMarkdown(labels: englishExportLabels, [
          _text('quoted', style: BlockStyle.blockquote),
        ]),
        '> quoted',
      );
    });

    test('renders a code block verbatim, without escaping', () {
      // Escaping inside code would corrupt the code itself.
      final md = renderMarkdown(labels: englishExportLabels, [
        _text('a * b _ c', style: BlockStyle.codeBlock),
      ]);
      expect(md, contains('a * b _ c'));
      expect(md, isNot(contains(r'\*')));
    });

    test('puts a blank line between a paragraph and a list', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        _text('intro'),
        _text('item', style: BlockStyle.bulletList),
      ]);
      // Without the blank line most renderers swallow the list into the
      // paragraph.
      expect(md, 'intro\n\n- item');
    });
  });

  group('renderMarkdown — inline styles', () {
    String render(InlineSpan span) =>
        renderMarkdown(labels: englishExportLabels, [
          TextBlock(spans: [span]),
        ]);

    test('renders bold, italic and strikethrough', () {
      expect(render(const InlineSpan(text: 'x', bold: true)), '**x**');
      expect(render(const InlineSpan(text: 'x', italic: true)), '_x_');
      expect(render(const InlineSpan(text: 'x', strikethrough: true)), '~~x~~');
    });

    test('falls back to HTML for underline, which Markdown lacks', () {
      expect(render(const InlineSpan(text: 'x', underline: true)), '<u>x</u>');
    });

    test('renders a link', () {
      expect(
        render(const InlineSpan(text: 'here', link: 'https://example.com')),
        '[here](https://example.com)',
      );
    });

    test('renders inline code without escaping its contents', () {
      expect(render(const InlineSpan(text: 'a_b', code: true)), '`a_b`');
    });

    test('widens the fence when the code contains a backtick', () {
      final md = render(const InlineSpan(text: 'a`b', code: true));
      expect(md, '``a`b``');
    });

    test('escapes Markdown syntax in ordinary text', () {
      expect(render(const InlineSpan(text: 'a*b_c[d]')), r'a\*b\_c\[d\]');
    });

    test('moves surrounding spaces outside the emphasis markers', () {
      // "** bold **" is not emphasis in Markdown; the markers must touch text.
      // Checked mid-line, because a trailing space at the very end of the
      // document is trimmed off by the document-level cleanup.
      final md = renderMarkdown(labels: englishExportLabels, [
        const TextBlock(
          spans: [
            InlineSpan(text: 'a'),
            InlineSpan(text: ' x ', bold: true),
            InlineSpan(text: 'b'),
          ],
        ),
      ]);
      expect(md, 'a **x** b');
    });

    test('trims trailing whitespace at the end of the document', () {
      expect(render(const InlineSpan(text: 'x  ')), 'x');
    });

    test('combines styles in a stable order', () {
      expect(
        render(const InlineSpan(text: 'x', bold: true, italic: true)),
        '_**x**_',
      );
    });

    test('keeps Malayalam text unchanged', () {
      expect(render(const InlineSpan(text: 'ഡയറി')), 'ഡയറി');
    });
  });

  group('renderMarkdown — embeds', () {
    test('renders a table as a pipe table with a header row', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        const TableBlock([
          ['Name', 'Value'],
          ['a', '1'],
        ]),
      ]);

      expect(md, contains('| Name | Value |'));
      expect(md, contains('| --- | --- |'));
      expect(md, contains('| a | 1 |'));
    });

    test('escapes a pipe inside a table cell', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        const TableBlock([
          ['a|b'],
        ]),
      ]);
      expect(md, contains(r'a\|b'));
    });

    test('pads a short row so the columns still line up', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        const TableBlock([
          ['a', 'b'],
          ['c'],
        ]),
      ]);
      expect(md, contains('| c |  |'));
    });

    test('renders a callout as a labelled blockquote', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        const CalloutBlock(style: 'warning', text: 'be careful'),
      ]);
      expect(md, contains('> **Warning**'));
      expect(md, contains('> be careful'));
    });

    test('keeps an unknown callout style as its own label', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        const CalloutBlock(style: 'custom', text: 't'),
      ]);
      expect(md, contains('> **custom**'));
    });

    test('names an unknown embed rather than dropping it', () {
      final md = renderMarkdown(labels: englishExportLabels, [
        const UnknownEmbedBlock('sketch'),
      ]);
      expect(md, contains('sketch'));
    });
  });

  group('inline images', () {
    const image = ImageBlock(attachmentId: 12, fileName: 'beach photo.jpg');

    test('links to the attachment file when it travels with the export', () {
      final md = renderMarkdown(
        labels: englishExportLabels,
        [image],
        linkableImageIds: const {12},
      );

      expect(
        md,
        contains('![beach photo.jpg](attachments/12_beach_photo.jpg)'),
      );
    });

    test('names the image when its file is not in the export', () {
      final md = renderMarkdown(labels: englishExportLabels, [image]);

      expect(md, isNot(contains('](attachments/')));
      expect(md, contains('[Image: beach photo.jpg]'));
    });

    test('only links the images whose files came along', () {
      final md = renderMarkdown(
        labels: englishExportLabels,
        [image, const ImageBlock(attachmentId: 13, fileName: 'locked.jpg')],
        linkableImageIds: const {12},
      );

      expect(md, contains('attachments/12_beach_photo.jpg'));
      expect(md, isNot(contains('attachments/13_')));
      expect(md, contains('[Image: locked.jpg]'));
    });
  });

  test('renders an empty document as an empty string', () {
    expect(renderMarkdown(labels: englishExportLabels, const []), '');
  });
}
