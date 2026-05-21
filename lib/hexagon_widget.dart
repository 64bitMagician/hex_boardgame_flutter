import 'package:flutter/material.dart';
import 'dart:math' as math;

// [Documentation State: FINISHED]

/// This represents one Hexagon you see on the entire game board.
/// It uses Geometry-based Custom Drawing.
class HexagonWidget extends StatelessWidget {
  final double size; // determine size
  final Color color; // determine color
  final Widget? child; //

  const HexagonWidget({
    Key? key,
    required this.size,
    required this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.732, // It uses the ratio 1.732 multiplied by radius. This is a mathematical requirement to get a perfect hexagon
      height: size * 2.0,
      color: Colors.transparent, // this is transparent, since this is the shell not yet the visual part
      child: CustomPaint( // We use CustomPaint to create our Custom Hexagon Shape
        painter: HexPainter(color), // This is the actual tool that draws the shapes. It is always created by us and inheriting CustomPainter (because CustomPainter is abstract and must be inherited)
        child: Center(child: child), // If 'child' != null, CustomPaint will inherit the size of 'child', otherwise CustomPaint == Size.zero
      ),
    );
  }
}

///
class HexPainter extends CustomPainter {
  final Color fillColor; // the inner color of hex

  HexPainter(this.fillColor);

  // this method will be called whenever the custom object needs to be repainted
  @override
  void paint(Canvas canvas, Size size) {
    // We have the anchor points for drawing
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.height / 2;

    // we create the actual object that is painting/rendering on the screen
    // This is like our brush
    final paint = Paint()
      ..color = fillColor // it has a color | determined at HexPainter Object Creation
      ..style = PaintingStyle.fill; // and it has a style: fill (acts like the bucket tool)

    // We will define a path which will act as a Blueprint for our Shape's Outline
    final path = Path();

    // Since we do a hexagon, there are 6 corners
    // So we need to calculate the coordinates of each corner in 6 for loops
    for (int i = 0; i < 6; i++) {
      double angle = 2 * math.pi / 6 * i + math.pi / 6;
      double cornerX = centerX + radius * math.cos(angle);
      double cornerY = centerY + radius * math.sin(angle);

      // Now we connect the dots | draw the outline of the shape
      if (i == 0) {
        path.moveTo(cornerX, cornerY);
      } else {
        path.lineTo(cornerX, cornerY);
      }
    }
    path.close();

    //Once the "blueprint" (the Path) is ready canvas.drawPath renders the shape onto the screen.
    // Now it draws the out filled shape
    canvas.drawPath(path, paint);

    // now because we want to draw the outline of the shape, we are no longer using the same brush style (fill)
    // rather the stroke: because we want to draw lines with a given dimension and color
    final outlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Now it draws the outline of the shape
    canvas.drawPath(path, outlinePaint);
  }

  // This method is used for performance
  // It is used for repainting the already processed shape
  // It checks the current color from the previous color. If they differ, then
  // it should repaint the shape (re-process it), otherwise, it simply uses the same
  // processed shape
  @override
  bool shouldRepaint(covariant HexPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor;
  }
}