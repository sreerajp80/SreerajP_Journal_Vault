/// Renders parsed entry blocks as an HTML fragment.
///
/// This is a fragment, not a page: `export_html_builder.dart` wraps it with the
/// document shell, the embedded fonts and the print CSS. The same fragment
/// serves both the `.html` export and the PDF export, so what a user sees in a
/// browser is what they get on paper.
///
/// Every piece of user text goes through [escapeHtml]. That is not a style
/// choice — the HTML is handed to a WebView and printed, so unescaped text
/// would let entry content break the markup, and an entry that happens to
/// contain `<script>` must stay inert. (`SreerajP_PDFApp` rule 5.)
///
/// Pure Dart — no Flutter, no plugins — so it is cheap to test.
library;

import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_labels.dart';

/// Turns [blocks] into an HTML fragment.
///
/// [imageSources] maps an attachment id to the `src` an inline image should be
/// drawn with — in practice a `data:` URI built by `ExportService`, because the
/// exported page has to stay one self-contained file. An image with no entry in
/// the map (locked, missing, or unreadable) is named instead of drawn; it is
/// never silently dropped.
///
/// [labels] supplies the words written into the page (callout names, image
/// placeholders), in the language the user exported in.
String renderHtml(
  List<ExportBlock> blocks, {
  required ExportLabels labels,
  Map<int, String> imageSources = const {},
}) {
  final buffer = StringBuffer();
  // Lists are built by looking ahead at runs of the same style, because HTML
  // needs one <ul>/<ol> wrapping all of its items.
  var i = 0;
  while (i < blocks.length) {
    final block = blocks[i];

    if (block is TextBlock && _isList(block.style)) {
      final run = <TextBlock>[];
      while (i < blocks.length) {
        final next = blocks[i];
        if (next is! TextBlock || !_sameListKind(next.style, block.style)) {
          break;
        }
        run.add(next);
        i++;
      }
      buffer.write(_renderList(run));
      continue;
    }

    if (block is TextBlock && block.style == BlockStyle.codeBlock) {
      // Consecutive code lines belong in one <pre>, or each line gets its own
      // box and the code is unreadable.
      final run = <TextBlock>[];
      while (i < blocks.length) {
        final next = blocks[i];
        if (next is! TextBlock || next.style != BlockStyle.codeBlock) break;
        run.add(next);
        i++;
      }
      final code = run.map((line) => escapeHtml(line.plainText)).join('\n');
      buffer.writeln('<pre class="code"><code>$code</code></pre>');
      continue;
    }

    buffer.write(_renderBlock(block, imageSources, labels));
    i++;
  }
  return buffer.toString();
}

bool _isList(BlockStyle style) =>
    style == BlockStyle.bulletList ||
    style == BlockStyle.orderedList ||
    style == BlockStyle.checkedList ||
    style == BlockStyle.uncheckedList;

/// Whether two list styles belong in the same list element.
///
/// Checked and unchecked items are the same list — a task list mixes them.
bool _sameListKind(BlockStyle a, BlockStyle b) {
  if (!_isList(a) || !_isList(b)) return false;
  if (a == b) return true;
  const task = {BlockStyle.checkedList, BlockStyle.uncheckedList};
  return task.contains(a) && task.contains(b);
}

String _renderList(List<TextBlock> items) {
  if (items.isEmpty) return '';
  final style = items.first.style;
  final ordered = style == BlockStyle.orderedList;
  final isTask =
      style == BlockStyle.checkedList || style == BlockStyle.uncheckedList;

  final tag = ordered ? 'ol' : 'ul';
  final classAttribute = isTask ? ' class="task-list"' : '';

  final buffer = StringBuffer('<$tag$classAttribute>');
  for (final item in items) {
    final content = _renderSpans(item.spans);
    if (isTask) {
      // A printed checkbox, not an <input> — the PDF is not interactive, and a
      // real checkbox renders as an empty grey square in print.
      final mark = item.style == BlockStyle.checkedList ? '&#9745;' : '&#9744;';
      buffer.write('<li><span class="task-mark">$mark</span> $content</li>');
    } else {
      buffer.write('<li>$content</li>');
    }
  }
  buffer.write('</$tag>');
  return buffer.toString();
}

String _renderBlock(
  ExportBlock block,
  Map<int, String> imageSources,
  ExportLabels labels,
) {
  switch (block) {
    case TextBlock():
      final content = _renderSpans(block.spans);
      switch (block.style) {
        case BlockStyle.heading1:
          return '<h1>$content</h1>';
        case BlockStyle.heading2:
          return '<h2>$content</h2>';
        case BlockStyle.heading3:
          return '<h3>$content</h3>';
        case BlockStyle.blockquote:
          return '<blockquote>$content</blockquote>';
        case BlockStyle.paragraph:
          // An empty paragraph is real vertical space the user typed, so it is
          // kept — but it needs a non-breaking space or it collapses to
          // nothing.
          return block.isEmpty ? '<p>&nbsp;</p>' : '<p>$content</p>';
        // Handled by the run-gathering loop in renderHtml; reaching here means
        // a single stray line, which still renders correctly.
        case BlockStyle.codeBlock:
          return '<pre class="code"><code>${escapeHtml(block.plainText)}'
              '</code></pre>';
        case BlockStyle.bulletList:
        case BlockStyle.orderedList:
        case BlockStyle.checkedList:
        case BlockStyle.uncheckedList:
          return '<ul><li>$content</li></ul>';
      }

    case TableBlock():
      return _renderTable(block.rows);

    case CalloutBlock():
      return _renderCallout(block, labels);

    case ImageBlock():
      return _renderImage(block, imageSources[block.attachmentId], labels);

    case DrawingBlock():
      return _renderDrawing(block, imageSources[block.attachmentId], labels);

    case UnknownEmbedBlock():
      return '<p class="unknown-embed">'
          '[${escapeHtml(labels.unexportableBlock(block.type))}]</p>';
  }
}

String _renderSpans(List<InlineSpan> spans) {
  final buffer = StringBuffer();
  for (final span in spans) {
    if (span.text.isEmpty) continue;

    // Escaping happens first, so a tag can never be built out of user text.
    var html = escapeHtml(span.text);

    if (span.code) html = '<code>$html</code>';
    if (span.bold) html = '<strong>$html</strong>';
    if (span.italic) html = '<em>$html</em>';
    if (span.underline) html = '<u>$html</u>';
    if (span.strikethrough) html = '<s>$html</s>';
    if (span.link != null) {
      // The href is escaped as an attribute value, and only http/https/mailto
      // are allowed through. A `javascript:` URL in an entry must never become
      // a live link in an exported page someone opens in a browser.
      final href = _safeHref(span.link!);
      html = href == null ? html : '<a href="$href">$html</a>';
    }
    buffer.write(html);
  }
  return buffer.toString();
}

/// Returns an escaped href, or null when the URL scheme is not safe to emit.
String? _safeHref(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  final lower = trimmed.toLowerCase();
  const allowed = ['http://', 'https://', 'mailto:'];
  final isAllowed = allowed.any(lower.startsWith);
  // A bare "example.com" is treated as https rather than dropped.
  if (!isAllowed) {
    if (lower.contains(':')) return null; // some other scheme — refuse it
    return escapeHtmlAttribute('https://$trimmed');
  }
  return escapeHtmlAttribute(trimmed);
}

String _renderTable(List<List<String>> rows) {
  if (rows.isEmpty) return '';
  final width = rows.fold<int>(0, (m, row) => row.length > m ? row.length : m);
  if (width == 0) return '';

  String cellAt(List<String> row, int i) => i < row.length ? row[i] : '';

  final buffer = StringBuffer('<table>');
  // The first row is the header, matching how the Markdown renderer treats it,
  // so the two formats describe the same table.
  buffer.write('<thead><tr>');
  for (var i = 0; i < width; i++) {
    buffer.write('<th>${escapeHtml(cellAt(rows.first, i))}</th>');
  }
  buffer.write('</tr></thead>');

  if (rows.length > 1) {
    buffer.write('<tbody>');
    for (final row in rows.skip(1)) {
      buffer.write('<tr>');
      for (var i = 0; i < width; i++) {
        buffer.write('<td>${escapeHtml(cellAt(row, i))}</td>');
      }
      buffer.write('</tr>');
    }
    buffer.write('</tbody>');
  }

  buffer.write('</table>');
  return buffer.toString();
}

/// Renders an inline image, or names it when there is no source for it.
///
/// Only a `data:image/...` source is emitted. The map is built by this app, but
/// an `<img src>` in an exported page is exactly the kind of place a surprising
/// value must not be able to reach out to the network from — the export is
/// meant to be one self-contained file that works offline forever.
String _renderImage(ImageBlock block, String? source, ExportLabels labels) {
  final label = block.fileName.isEmpty ? labels.image : block.fileName;

  if (source == null || !source.startsWith('data:image/')) {
    return '<p class="unknown-embed">[${escapeHtml(label)} — '
        '${escapeHtml(labels.imageNotIncluded)}]</p>';
  }

  return '<figure class="inline-image">'
      '<img src="${escapeHtmlAttribute(source)}" alt="${escapeHtml(label)}">'
      '</figure>';
}

/// Renders an inline drawing, or names it when there is no source for it.
String _renderDrawing(DrawingBlock block, String? source, ExportLabels labels) {
  final label = block.fileName.isEmpty ? labels.drawing : block.fileName;

  if (source == null || !source.startsWith('data:image/')) {
    return '<p class="unknown-embed">[${escapeHtml(label)} — '
        '${escapeHtml(labels.drawingNotIncluded)}]</p>';
  }

  return '<figure class="inline-drawing">'
      '<img src="${escapeHtmlAttribute(source)}" alt="${escapeHtml(label)}">'
      '</figure>';
}

String _renderCallout(CalloutBlock block, ExportLabels labels) {
  // The style becomes a CSS class, so it is restricted to a known list. An
  // unexpected value must not be able to inject an attribute.
  const known = {'info', 'warning', 'tip', 'important'};
  final style = known.contains(block.style) ? block.style : 'info';
  final label = labels.calloutLabel(block.style);

  final paragraphs = block.text
      .split('\n')
      .map((line) => '<p>${escapeHtml(line)}</p>')
      .join();

  return '<div class="callout callout-$style">'
      '<p class="callout-label">${escapeHtml(label)}</p>'
      '$paragraphs'
      '</div>';
}

/// Escapes text for safe use inside HTML content.
String escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

/// Escapes text for safe use inside a double-quoted HTML attribute.
String escapeHtmlAttribute(String value) => escapeHtml(value);
