import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_models.dart';

/// Interactive drawing canvas widget.
class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({
    super.key,
    required this.strokes,
    required this.currentStroke,
    required this.backgroundStyle,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.backgroundColor,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;
  final DrawingBackgroundStyle backgroundStyle;
  final ValueChanged<PointerDownEvent> onPointerDown;
  final ValueChanged<PointerMoveEvent> onPointerMove;
  final ValueChanged<PointerUpEvent> onPointerUp;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
            strokes: strokes,
            currentStroke: currentStroke,
            backgroundStyle: backgroundStyle,
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering background patterns and drawing strokes with
/// smooth bezier curves.
class DrawingPainter extends CustomPainter {
  const DrawingPainter({
    required this.strokes,
    this.currentStroke,
    required this.backgroundStyle,
    required this.backgroundColor,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;
  final DrawingBackgroundStyle backgroundStyle;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint canvas background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Paint pattern guidelines if enabled
    _paintBackgroundPattern(canvas, size);

    // 3. Paint completed strokes
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }

    // 4. Paint in-progress stroke
    if (currentStroke != null) {
      _paintStroke(canvas, currentStroke!);
    }
  }

  void _paintBackgroundPattern(Canvas canvas, Size size) {
    if (backgroundStyle == DrawingBackgroundStyle.blank) return;

    final isDark = backgroundColor.computeLuminance() < 0.5;
    final guideColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    final linePaint = Paint()
      ..color = guideColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    switch (backgroundStyle) {
      case DrawingBackgroundStyle.ruled:
        const lineSpacing = 32.0;
        var y = lineSpacing;
        while (y < size.height) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
          y += lineSpacing;
        }

      case DrawingBackgroundStyle.grid:
        const gridSize = 28.0;
        for (double x = gridSize; x < size.width; x += gridSize) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        }
        for (double y = gridSize; y < size.height; y += gridSize) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }

      case DrawingBackgroundStyle.dots:
        const dotSpacing = 28.0;
        final dotPaint = Paint()
          ..color = guideColor
          ..style = PaintingStyle.fill;
        for (double x = dotSpacing; x < size.width; x += dotSpacing) {
          for (double y = dotSpacing; y < size.height; y += dotSpacing) {
            canvas.drawCircle(Offset(x, y), 1.25, dotPaint);
          }
        }

      case DrawingBackgroundStyle.blank:
        break;
    }
  }

  void _paintStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.isHighlighter || stroke.tool == DrawingTool.highlighter) {
      paint
        ..color = stroke.color.withValues(alpha: 0.4)
        ..strokeWidth = stroke.strokeWidth * 2.5
        ..blendMode = BlendMode.srcOver;
    } else {
      paint
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth;
    }

    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      canvas.drawCircle(
        p.offset,
        paint.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path();
    final points = stroke.points;
    path.moveTo(points[0].x, points[0].y);

    if (points.length == 2) {
      path.lineTo(points[1].x, points[1].y);
    } else {
      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.x + p1.x) / 2;
        final midY = (p0.y + p1.y) / 2;
        path.quadraticBezierTo(p0.x, p0.y, midX, midY);
      }
      path.lineTo(points.last.x, points.last.y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.backgroundStyle != backgroundStyle ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Helper for exporting drawing strokes to PNG image bytes.
class DrawingImageExporter {
  static Future<Uint8List> renderToPngBytes({
    required List<DrawingStroke> strokes,
    required DrawingBackgroundStyle backgroundStyle,
    required Size size,
    Color backgroundColor = Colors.white,
    double pixelRatio = 2.0,
  }) async {
    final width = (size.width * pixelRatio).clamp(300.0, 2400.0);
    final height = (size.height * pixelRatio).clamp(300.0, 3600.0);
    final targetSize = Size(width, height);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Scale canvas to target pixel ratio
    canvas.scale(pixelRatio);

    final painter = DrawingPainter(
      strokes: strokes,
      backgroundStyle: backgroundStyle,
      backgroundColor: backgroundColor,
    );
    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      targetSize.width.round(),
      targetSize.height.round(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
