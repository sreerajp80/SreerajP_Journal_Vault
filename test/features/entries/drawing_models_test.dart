import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_models.dart';

void main() {
  group('DrawingTool', () {
    test('toJson and fromJson round-trips tools correctly', () {
      expect(DrawingTool.fromJson(DrawingTool.pen.toJson()), DrawingTool.pen);
      expect(
        DrawingTool.fromJson(DrawingTool.highlighter.toJson()),
        DrawingTool.highlighter,
      );
      expect(
        DrawingTool.fromJson(DrawingTool.eraser.toJson()),
        DrawingTool.eraser,
      );
      expect(DrawingTool.fromJson('unknown'), DrawingTool.pen);
      expect(DrawingTool.fromJson(null), DrawingTool.pen);
    });
  });

  group('DrawingBackgroundStyle', () {
    test('toJson and fromJson round-trips styles correctly', () {
      for (final style in DrawingBackgroundStyle.values) {
        expect(DrawingBackgroundStyle.fromJson(style.toJson()), style);
      }
      expect(
        DrawingBackgroundStyle.fromJson('invalid'),
        DrawingBackgroundStyle.blank,
      );
      expect(
        DrawingBackgroundStyle.fromJson(null),
        DrawingBackgroundStyle.blank,
      );
    });
  });

  group('DrawingPoint', () {
    test('round-trips position and pressure to/from JSON', () {
      const p1 = DrawingPoint(x: 10.5, y: 20.25, pressure: 0.75);
      final json = p1.toJson();
      final p2 = DrawingPoint.fromJson(json);

      expect(p2.x, 10.5);
      expect(p2.y, 20.25);
      expect(p2.pressure, 0.75);
      expect(p2.offset, const Offset(10.5, 20.25));
    });

    test('omits default 1.0 pressure in JSON', () {
      const p = DrawingPoint(x: 5.0, y: 15.0);
      expect(p.toJson().containsKey('p'), isFalse);
    });
  });

  group('DrawingStroke', () {
    test('round-trips full stroke to/from JSON', () {
      const stroke = DrawingStroke(
        points: [
          DrawingPoint(x: 0, y: 0),
          DrawingPoint(x: 50, y: 50),
          DrawingPoint(x: 100, y: 50),
        ],
        color: Color(0xFFE11D48),
        strokeWidth: 4.5,
        tool: DrawingTool.pen,
      );

      final json = stroke.toJson();
      final recovered = DrawingStroke.fromJson(json);

      expect(recovered, isNotNull);
      expect(recovered!.points.length, 3);
      expect(recovered.color.toARGB32(), const Color(0xFFE11D48).toARGB32());
      expect(recovered.strokeWidth, 4.5);
      expect(recovered.tool, DrawingTool.pen);
      expect(recovered.isHighlighter, isFalse);
    });

    test('preserves highlighter flag', () {
      const stroke = DrawingStroke(
        points: [DrawingPoint(x: 10, y: 10)],
        color: Colors.yellow,
        strokeWidth: 10.0,
        tool: DrawingTool.highlighter,
        isHighlighter: true,
      );

      final json = stroke.toJson();
      final recovered = DrawingStroke.fromJson(json);
      expect(recovered!.isHighlighter, isTrue);
      expect(recovered.tool, DrawingTool.highlighter);
    });

    test('returns null when stroke has no points or corrupt JSON', () {
      expect(DrawingStroke.fromJson({'points': []}), isNull);
      expect(DrawingStroke.fromJson({'points': 'not a list'}), isNull);
    });
  });

  group('DrawingCanvasState', () {
    test('encodes and parses complete canvas state', () {
      const state = DrawingCanvasState(
        strokes: [
          DrawingStroke(
            points: [DrawingPoint(x: 1, y: 2), DrawingPoint(x: 3, y: 4)],
            color: Colors.blue,
            strokeWidth: 3.0,
            tool: DrawingTool.pen,
          ),
        ],
        backgroundStyle: DrawingBackgroundStyle.grid,
      );

      final encoded = state.encode();
      final parsed = DrawingCanvasState.parse(encoded);

      expect(parsed.backgroundStyle, DrawingBackgroundStyle.grid);
      expect(parsed.strokes.length, 1);
      expect(parsed.strokes.first.points.length, 2);
    });

    test('gracefully recovers from null or corrupt JSON', () {
      expect(DrawingCanvasState.parse(null).strokes, isEmpty);
      expect(DrawingCanvasState.parse('').strokes, isEmpty);
      expect(DrawingCanvasState.parse('{corrupt json').strokes, isEmpty);
      expect(DrawingCanvasState.parse('[]').strokes, isEmpty);
    });

    test('copyWith works correctly', () {
      const state1 = DrawingCanvasState(strokes: []);
      final state2 = state1.copyWith(
        backgroundStyle: DrawingBackgroundStyle.ruled,
      );
      expect(state2.backgroundStyle, DrawingBackgroundStyle.ruled);
      expect(state2.strokes, isEmpty);
    });
  });
}
