part of 'ocr_camera_screen.dart';

/// Visual animated reticle shown at the tap-to-focus point.
class _FocusReticle extends StatelessWidget {
  const _FocusReticle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Semi-transparent document framing grid overlay.
class _DocumentFramingGrid extends StatelessWidget {
  const _DocumentFramingGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DocumentGridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DocumentGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Rule of thirds lines
    final thirdW = size.width / 3.0;
    final thirdH = size.height / 3.0;

    canvas.drawLine(Offset(thirdW, 0), Offset(thirdW, size.height), gridPaint);
    canvas.drawLine(
      Offset(thirdW * 2, 0),
      Offset(thirdW * 2, size.height),
      gridPaint,
    );
    canvas.drawLine(Offset(0, thirdH), Offset(size.width, thirdH), gridPaint);
    canvas.drawLine(
      Offset(0, thirdH * 2),
      Offset(size.width, thirdH * 2),
      gridPaint,
    );

    // Central document framing box with corner brackets
    final docRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.82,
      height: size.height * 0.65,
    );

    final cornerPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 22.0;

    // Top-left corner
    canvas.drawLine(
      docRect.topLeft,
      docRect.topLeft + const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.topLeft,
      docRect.topLeft + const Offset(0, cornerLen),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      docRect.topRight,
      docRect.topRight - const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.topRight,
      docRect.topRight + const Offset(0, cornerLen),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      docRect.bottomLeft,
      docRect.bottomLeft + const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.bottomLeft,
      docRect.bottomLeft - const Offset(0, cornerLen),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      docRect.bottomRight,
      docRect.bottomRight - const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.bottomRight,
      docRect.bottomRight - const Offset(0, cornerLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
