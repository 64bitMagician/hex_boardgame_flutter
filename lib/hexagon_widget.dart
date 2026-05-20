import 'package:flutter/material.dart';
import 'dart:math' as math;

// [Documentation State: ___]

class HexagonWidget extends StatelessWidget {
  final double size;
  final Color color;
  final Widget? child;

  const HexagonWidget({
    Key? key,
    required this.size,
    required this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.732,
      height: size * 2.0,
      color: Colors.transparent,
      child: CustomPaint(
        painter: HexPainter(color),
        child: Center(child: child),
      ),
    );
  }
}

class HexPainter extends CustomPainter {
  final Color fillColor;

  HexPainter(this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.height / 2;

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = 2 * math.pi / 6 * i + math.pi / 6;
      double cornerX = centerX + radius * math.cos(angle);
      double cornerY = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(cornerX, cornerY);
      } else {
        path.lineTo(cornerX, cornerY);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    final outlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant HexPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor;
  }
}