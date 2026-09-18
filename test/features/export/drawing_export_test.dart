import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import '../../helpers/export_labels.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_html.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_markdown.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_to_plain_text.dart';

void main() {
  group('DrawingBlock — delta parser and renderers', () {
    test('parses drawing embed correctly from delta JSON', () {
      final deltaJson = jsonEncode([
        {'insert': 'My Sketch:\n'},
        {
          'insert': {
            'drawing': jsonEncode({
              'attachmentId': 99,
              'fileName': 'drawing_123.png',
              'widthFactor': 1.0,
              'strokeJson': '{"strokes":[]}',
            }),
          },
        },
        {'insert': '\n'},
      ]);

      final blocks = parseDelta(deltaJson);
      final drawingBlocks = blocks.whereType<DrawingBlock>().toList();

      expect(drawingBlocks.length, 1);
      expect(drawingBlocks.first.attachmentId, 99);
      expect(drawingBlocks.first.fileName, 'drawing_123.png');
      expect(drawingBlocks.first.strokeJson, '{"strokes":[]}');
    });

    test('also parses vault_drawing keys', () {
      final deltaJson = jsonEncode([
        {
          'insert': {
            'vault_drawing': jsonEncode({
              'attachmentId': 101,
              'fileName': 'vd.png',
            }),
          },
        },
        {'insert': '\n'},
      ]);

      final blocks = parseDelta(deltaJson);
      expect(blocks.whereType<DrawingBlock>().length, 1);
      expect(blocks.whereType<DrawingBlock>().first.attachmentId, 101);
    });

    test('renders DrawingBlock to Markdown', () {
      const block = DrawingBlock(attachmentId: 10, fileName: 'doodle.png');

      // When linkable
      final linkedMd = renderMarkdown(
        labels: englishExportLabels,
        [block],
        linkableImageIds: {10},
      );
      expect(linkedMd, contains('![doodle.png](attachments/10_doodle.png)'));

      // When not linkable
      final unlinkedMd = renderMarkdown(labels: englishExportLabels, [
        block,
      ], linkableImageIds: {});
      expect(unlinkedMd, contains('_[Drawing: doodle.png]_'));
    });

    test('renders DrawingBlock to HTML', () {
      const block = DrawingBlock(attachmentId: 15, fileName: 'art.png');

      // When data source provided
      final html = renderHtml(
        labels: englishExportLabels,
        [block],
        imageSources: {15: 'data:image/png;base64,iVBORw0KGgo='},
      );
      expect(html, contains('<figure class="inline-drawing">'));
      expect(
        html,
        contains(
          '<img src="data:image/png;base64,iVBORw0KGgo=" alt="art.png">',
        ),
      );

      // When not provided
      final unincludedHtml = renderHtml(labels: englishExportLabels, [
        block,
      ], imageSources: {});
      expect(unincludedHtml, contains('drawing not included'));
    });

    test('renders DrawingBlock to Plain Text', () {
      const block = DrawingBlock(attachmentId: 20, fileName: 'sketch.png');

      final plainText = renderPlainText(labels: englishExportLabels, [block]);
      expect(plainText, contains('[Drawing: sketch.png]'));
    });
  });
}
