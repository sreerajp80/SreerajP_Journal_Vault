import 'dart:convert';
import 'package:flutter/material.dart';

/// Available drawing instruments on the canvas.
enum DrawingTool {
  pen,
  highlighter,
  eraser;

  String toJson() => name;

  static DrawingTool fromJson(String? value) => switch (value) {
    'highlighter' => DrawingTool.highlighter,
    'eraser' => DrawingTool.eraser,
    _ => DrawingTool.pen,
  };
}

/// Paper background patterns for the drawing canvas.
enum DrawingBackgroundStyle {
  blank,
  ruled,
  grid,
  dots;

  String toJson() => name;

  static DrawingBackgroundStyle fromJson(String? value) => switch (value) {
    'ruled' => DrawingBackgroundStyle.ruled,
    'grid' => DrawingBackgroundStyle.grid,
    'dots' => DrawingBackgroundStyle.dots,
    _ => DrawingBackgroundStyle.blank,
  };
}

/// Single point along a drawing stroke with position and stylus pressure.
class DrawingPoint {
  const DrawingPoint({required this.x, required this.y, this.pressure = 1.0});

  final double x;
  final double y;
  final double pressure;

  Offset get offset => Offset(x, y);

  Map<String, dynamic> toJson() => {
    'x': double.parse(x.toStringAsFixed(2)),
    'y': double.parse(y.toStringAsFixed(2)),
    if (pressure != 1.0) 'p': double.parse(pressure.toStringAsFixed(2)),
  };

  static DrawingPoint fromJson(Map<String, dynamic> map) {
    final x = (map['x'] as num?)?.toDouble() ?? 0.0;
    final y = (map['y'] as num?)?.toDouble() ?? 0.0;
    final p = (map['p'] as num?)?.toDouble() ?? 1.0;
    return DrawingPoint(x: x, y: y, pressure: p);
  }
}

/// A continuous stroke drawn with a specific tool, color, and width.
class DrawingStroke {
  const DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
    this.isHighlighter = false,
  });

  final List<DrawingPoint> points;
  final Color color;
  final double strokeWidth;
  final DrawingTool tool;
  final bool isHighlighter;

  Map<String, dynamic> toJson() => {
    'tool': tool.toJson(),
    'color': color.toARGB32(),
    'width': strokeWidth,
    'highlighter': isHighlighter,
    'points': points.map((p) => p.toJson()).toList(),
  };

  static DrawingStroke? fromJson(Map<String, dynamic> map) {
    final rawPoints = map['points'];
    if (rawPoints is! List || rawPoints.isEmpty) return null;

    final points = <DrawingPoint>[];
    for (final item in rawPoints) {
      if (item is Map<String, dynamic>) {
        points.add(DrawingPoint.fromJson(item));
      } else if (item is Map) {
        points.add(DrawingPoint.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    if (points.isEmpty) return null;

    final colorValue = map['color'] as int? ?? 0xFF000000;
    final strokeWidth = (map['width'] as num?)?.toDouble() ?? 3.0;
    final tool = DrawingTool.fromJson(map['tool'] as String?);
    final isHighlighter =
        map['highlighter'] == true || tool == DrawingTool.highlighter;

    return DrawingStroke(
      points: points,
      color: Color(colorValue),
      strokeWidth: strokeWidth,
      tool: tool,
      isHighlighter: isHighlighter,
    );
  }
}

/// The entire state of a drawing canvas, including strokes and background pattern.
class DrawingCanvasState {
  const DrawingCanvasState({
    required this.strokes,
    this.backgroundStyle = DrawingBackgroundStyle.blank,
  });

  final List<DrawingStroke> strokes;
  final DrawingBackgroundStyle backgroundStyle;

  String encode() {
    return jsonEncode({
      'version': 1,
      'background': backgroundStyle.toJson(),
      'strokes': strokes.map((s) => s.toJson()).toList(),
    });
  }

  static DrawingCanvasState parse(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return const DrawingCanvasState(strokes: []);
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return const DrawingCanvasState(strokes: []);

      final bgStyle = DrawingBackgroundStyle.fromJson(
        decoded['background'] as String?,
      );
      final rawStrokes = decoded['strokes'];
      final strokes = <DrawingStroke>[];

      if (rawStrokes is List) {
        for (final item in rawStrokes) {
          if (item is Map<String, dynamic>) {
            final stroke = DrawingStroke.fromJson(item);
            if (stroke != null) strokes.add(stroke);
          } else if (item is Map) {
            final stroke = DrawingStroke.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (stroke != null) strokes.add(stroke);
          }
        }
      }

      return DrawingCanvasState(strokes: strokes, backgroundStyle: bgStyle);
    } catch (_) {
      return const DrawingCanvasState(strokes: []);
    }
  }

  DrawingCanvasState copyWith({
    List<DrawingStroke>? strokes,
    DrawingBackgroundStyle? backgroundStyle,
  }) {
    return DrawingCanvasState(
      strokes: strokes ?? this.strokes,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
    );
  }
}
