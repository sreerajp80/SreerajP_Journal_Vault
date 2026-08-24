import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing_embed.dart';

void main() {
  group('DrawingEmbedData', () {
    test('create round-trips attachment id, name, width, and strokeJson', () {
      final embed = DrawingEmbed.create(
        attachmentId: 42,
        fileName: 'sketch.png',
        widthFactor: DrawingEmbedData.mediumWidth,
        strokeJson: '{"version":1,"strokes":[]}',
      );

      final data = embed.drawingData;
      expect(data.attachmentId, 42);
      expect(data.fileName, 'sketch.png');
      expect(data.widthFactor, DrawingEmbedData.mediumWidth);
      expect(data.strokeJson, '{"version":1,"strokes":[]}');
    });

    test('defaults to full width and null strokeJson', () {
      final embed = DrawingEmbed.create(
        attachmentId: 10,
        fileName: 'drawing.png',
      );
      expect(embed.drawingData.widthFactor, DrawingEmbedData.fullWidth);
      expect(embed.drawingData.strokeJson, isNull);
    });

    test(
      'never stores raw image bytes — only attachment id and vector data',
      () {
        final embed = DrawingEmbed.create(
          attachmentId: 7,
          fileName: 'drawing.png',
          strokeJson: '{"strokes":[]}',
        );
        final parsed = jsonDecode(embed.data) as Map<String, dynamic>;
        expect(parsed.keys, {
          'attachmentId',
          'fileName',
          'widthFactor',
          'strokeJson',
        });
      },
    );

    test('type key matches drawing constant', () {
      final embed = DrawingEmbed.create(
        attachmentId: 1,
        fileName: 'drawing.png',
      );
      expect(embed.type, DrawingEmbed.drawingType);
      expect(embed.type, 'drawing');
    });

    test('snaps unexpected width factors to nearest valid factor', () {
      final large = DrawingEmbedData.parse(
        jsonEncode({
          'attachmentId': 3,
          'fileName': 'd.png',
          'widthFactor': 12.0,
        }),
      );
      expect(large.widthFactor, DrawingEmbedData.fullWidth);

      final tiny = DrawingEmbedData.parse(
        jsonEncode({
          'attachmentId': 3,
          'fileName': 'd.png',
          'widthFactor': 0.1,
        }),
      );
      expect(tiny.widthFactor, DrawingEmbedData.smallWidth);
    });

    test('unreadable raw data falls back gracefully', () {
      for (final raw in <Object?>['not json', '[]', '', null, 123]) {
        final data = DrawingEmbedData.parse(raw);
        expect(data.attachmentId, 0);
        expect(data.fileName, '');
        expect(data.widthFactor, DrawingEmbedData.fullWidth);
        expect(data.strokeJson, isNull);
      }
    });

    test('copyWith updates fields appropriately', () {
      const data = DrawingEmbedData(attachmentId: 1, fileName: 'd1.png');
      final updated = data.copyWith(
        attachmentId: 2,
        fileName: 'd2.png',
        widthFactor: DrawingEmbedData.smallWidth,
        strokeJson: '{"strokes":[]}',
      );
      expect(updated.attachmentId, 2);
      expect(updated.fileName, 'd2.png');
      expect(updated.widthFactor, DrawingEmbedData.smallWidth);
      expect(updated.strokeJson, '{"strokes":[]}');
    });
  });
}
