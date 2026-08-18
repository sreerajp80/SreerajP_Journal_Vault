import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_html.dart';

/// Covers the HTML renderer.
///
/// The escaping group matters most: this HTML is handed to a WebView and
/// printed, so entry text must never be able to become markup or script.
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
  group('renderHtml — block styles', () {
    test('renders headings and paragraphs', () {
      expect(
        renderHtml([_text('a', style: BlockStyle.heading1)]),
        '<h1>a</h1>',
      );
      expect(
        renderHtml([_text('b', style: BlockStyle.heading2)]),
        '<h2>b</h2>',
      );
      expect(
        renderHtml([_text('c', style: BlockStyle.heading3)]),
        '<h3>c</h3>',
      );
      expect(renderHtml([_text('d')]), '<p>d</p>');
    });

    test('wraps a run of bullet items in one list element', () {
      final html = renderHtml([
        _text('a', style: BlockStyle.bulletList),
        _text('b', style: BlockStyle.bulletList),
      ]);
      expect(html, '<ul><li>a</li><li>b</li></ul>');
    });

    test('uses an ordered list element for numbered items', () {
      final html = renderHtml([
        _text('a', style: BlockStyle.orderedList),
        _text('b', style: BlockStyle.orderedList),
      ]);
      expect(html, '<ol><li>a</li><li>b</li></ol>');
    });

    test('starts a new list element when the list kind changes', () {
      final html = renderHtml([
        _text('a', style: BlockStyle.bulletList),
        _text('b', style: BlockStyle.orderedList),
      ]);
      expect(html, '<ul><li>a</li></ul><ol><li>b</li></ol>');
    });

    test('keeps checked and unchecked items in one task list', () {
      final html = renderHtml([
        _text('done', style: BlockStyle.checkedList),
        _text('todo', style: BlockStyle.uncheckedList),
      ]);
      expect(html, startsWith('<ul class="task-list">'));
      // Printed box characters, not <input> — a PDF is not interactive.
      expect(html, contains('&#9745;'));
      expect(html, contains('&#9744;'));
      expect(html, isNot(contains('<input')));
    });

    test('gathers consecutive code lines into one pre block', () {
      final html = renderHtml([
        _text('line one', style: BlockStyle.codeBlock),
        _text('line two', style: BlockStyle.codeBlock),
      ]);
      expect(html, '<pre class="code"><code>line one\nline two</code></pre>\n');
    });

    test('renders a blockquote', () {
      expect(
        renderHtml([_text('q', style: BlockStyle.blockquote)]),
        '<blockquote>q</blockquote>',
      );
    });

    test('keeps an empty paragraph as real vertical space', () {
      expect(renderHtml([_text('')]), '<p>&nbsp;</p>');
    });
  });

  group('renderHtml — inline styles', () {
    String render(InlineSpan span) => renderHtml([
      TextBlock(spans: [span]),
    ]);

    test('renders each inline style with the right element', () {
      expect(
        render(const InlineSpan(text: 'x', bold: true)),
        '<p><strong>x</strong></p>',
      );
      expect(
        render(const InlineSpan(text: 'x', italic: true)),
        '<p><em>x</em></p>',
      );
      expect(
        render(const InlineSpan(text: 'x', underline: true)),
        '<p><u>x</u></p>',
      );
      expect(
        render(const InlineSpan(text: 'x', strikethrough: true)),
        '<p><s>x</s></p>',
      );
      expect(
        render(const InlineSpan(text: 'x', code: true)),
        '<p><code>x</code></p>',
      );
    });

    test('renders a link', () {
      expect(
        render(const InlineSpan(text: 'go', link: 'https://example.com')),
        '<p><a href="https://example.com">go</a></p>',
      );
    });

    test('keeps Malayalam text unchanged', () {
      expect(render(const InlineSpan(text: 'ഡയറി')), '<p>ഡയറി</p>');
    });
  });

  group('renderHtml — escaping and link safety', () {
    test('escapes markup characters in entry text', () {
      final html = renderHtml([_text('<script>alert(1)</script>')]);
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });

    test('escapes ampersands, quotes and apostrophes', () {
      final html = renderHtml([_text('''a & b "c" 'd' ''')]);
      expect(html, contains('&amp;'));
      expect(html, contains('&quot;'));
      expect(html, contains('&#39;'));
    });

    test('escapes text inside a code block', () {
      final html = renderHtml([
        _text('<b>not bold</b>', style: BlockStyle.codeBlock),
      ]);
      expect(html, contains('&lt;b&gt;'));
      expect(html, isNot(contains('<b>')));
    });

    test('escapes text inside a table cell', () {
      final html = renderHtml([
        const TableBlock([
          ['<td>injected</td>'],
        ]),
      ]);
      expect(html, contains('&lt;td&gt;'));
    });

    test('drops a javascript: link but keeps its text', () {
      final html = renderHtml([
        const TextBlock(
          spans: [InlineSpan(text: 'click me', link: 'javascript:alert(1)')],
        ),
      ]);
      expect(html, isNot(contains('javascript:')));
      expect(html, isNot(contains('<a ')));
      expect(html, contains('click me'));
    });

    test('allows http, https and mailto links', () {
      for (final url in [
        'http://a.test',
        'https://a.test',
        'mailto:a@b.test',
      ]) {
        final html = renderHtml([
          TextBlock(
            spans: [InlineSpan(text: 'x', link: url)],
          ),
        ]);
        expect(html, contains('href="$url"'));
      }
    });

    test('treats a bare domain as https rather than dropping it', () {
      final html = renderHtml([
        const TextBlock(
          spans: [InlineSpan(text: 'x', link: 'example.com')],
        ),
      ]);
      expect(html, contains('href="https://example.com"'));
    });

    test(
      'escapes a quote inside a link URL so it cannot end the attribute',
      () {
        final html = renderHtml([
          const TextBlock(
            spans: [
              InlineSpan(
                text: 'x',
                link: 'https://a.test/"onmouseover="evil()',
              ),
            ],
          ),
        ]);
        expect(html, isNot(contains('onmouseover="evil')));
        expect(html, contains('&quot;'));
      },
    );
  });

  group('renderHtml — embeds', () {
    test('renders a table with the first row as the header', () {
      final html = renderHtml([
        const TableBlock([
          ['Name', 'Value'],
          ['a', '1'],
        ]),
      ]);
      expect(html, contains('<thead><tr><th>Name</th><th>Value</th></tr>'));
      expect(html, contains('<td>a</td><td>1</td>'));
    });

    test('pads a short row so every row has the same cell count', () {
      final html = renderHtml([
        const TableBlock([
          ['a', 'b'],
          ['c'],
        ]),
      ]);
      expect(html, contains('<td>c</td><td></td>'));
    });

    test('renders a callout with a style class and a label', () {
      final html = renderHtml([
        const CalloutBlock(style: 'warning', text: 'careful'),
      ]);
      expect(html, contains('class="callout callout-warning"'));
      expect(html, contains('Warning'));
      expect(html, contains('careful'));
    });

    test('falls back to a known class for an unexpected callout style', () {
      // The style becomes a CSS class, so an odd value must not be able to
      // inject an attribute.
      final html = renderHtml([
        const CalloutBlock(style: 'x" onload="evil', text: 't'),
      ]);
      expect(html, contains('class="callout callout-info"'));
      // The odd style still appears as the visible label, but fully escaped,
      // so it is text and not an attribute. What must not appear is the raw
      // quote sequence that would close the class attribute and start a new
      // one.
      expect(html, isNot(contains('" onload="')));
      expect(html, contains('x&quot; onload=&quot;evil'));
    });

    test('names an unknown embed rather than dropping it', () {
      final html = renderHtml([const UnknownEmbedBlock('sketch')]);
      expect(html, contains('sketch'));
    });
  });

  group('inline images', () {
    const image = ImageBlock(attachmentId: 12, fileName: 'beach.jpg');

    test('draws the picture when a source is supplied', () {
      final html = renderHtml(
        [image],
        imageSources: const {12: 'data:image/jpeg;base64,AAAA'},
      );

      expect(html, contains('<figure class="inline-image">'));
      expect(html, contains('src="data:image/jpeg;base64,AAAA"'));
      expect(html, contains('alt="beach.jpg"'));
    });

    test('names the picture when there is no source for it', () {
      final html = renderHtml([image]);

      expect(html, isNot(contains('<img')));
      expect(html, contains('beach.jpg'));
      expect(html, contains('image not included'));
    });

    test('refuses a source that is not a data image URI', () {
      // An exported page must load nothing from the network, ever.
      final html = renderHtml(
        [image],
        imageSources: const {12: 'https://example.com/tracker.png'},
      );

      expect(html, isNot(contains('<img')));
      expect(html, isNot(contains('example.com')));
    });

    test('escapes the file name', () {
      final html = renderHtml([
        const ImageBlock(attachmentId: 1, fileName: '"><script>evil'),
      ]);

      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });
  });

  test('renders an empty document as an empty string', () {
    expect(renderHtml(const []), '');
  });
}
