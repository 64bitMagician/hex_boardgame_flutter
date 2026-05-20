import 'package:flutter/material.dart';
import 'player_bst.dart';

class VisualTreeScreen extends StatelessWidget {
  final PlayerBST playerDB;

  const VisualTreeScreen({Key? key, required this.playerDB}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900, // Dark mode looks great for data visualization
      appBar: AppBar(
        title: const Text("BST Structure"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      // We use InteractiveViewer so you can pan and zoom around your massive tree!
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(2000),
        minScale: 0.1,
        maxScale: 5.0,
        child: Container(
          width: 4000,  // Give the canvas a massive virtual space to draw on
          height: 4000,
          color: Colors.transparent,
          child: CustomPaint(
            painter: BSTPainter(playerDB.root),
          ),
        ),
      ),
    );
  }
}

class BSTPainter extends CustomPainter {
  final BSTNode? root;
  final double nodeRadius = 30.0;

  BSTPainter(this.root);

  @override
  void paint(Canvas canvas, Size size) {
    if (root == null) return;

    // Start painting from the top center of our virtual canvas
    _drawNode(
      canvas: canvas,
      node: root!,
      x: size.width / 2,
      y: 100,
      horizontalSpacing: size.width / 4, // Initial horizontal spread
    );
  }

  void _drawNode({
    required Canvas canvas,
    required BSTNode node,
    required double x,
    required double y,
    required double horizontalSpacing,
  }) {
    final paintLine = Paint()
      ..color = Colors.white54
      ..strokeWidth = 3.0;

    final paintNode = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    // 1. Recursively draw lines to children FIRST (so they render under the circles)
    if (node.left != null) {
      double nextX = x - horizontalSpacing;
      double nextY = y + 100; // Drop down 100 pixels for the next level
      canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paintLine);

      _drawNode(
        canvas: canvas,
        node: node.left!,
        x: nextX,
        y: nextY,
        horizontalSpacing: horizontalSpacing / 2, // Halve the spread for the next level
      );
    }

    if (node.right != null) {
      double nextX = x + horizontalSpacing;
      double nextY = y + 100;
      canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paintLine);

      _drawNode(
        canvas: canvas,
        node: node.right!,
        x: nextX,
        y: nextY,
        horizontalSpacing: horizontalSpacing / 2,
      );
    }

    // 2. Draw the Node Circle
    canvas.drawCircle(Offset(x, y), nodeRadius, paintNode);
    canvas.drawCircle(Offset(x, y), nodeRadius, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

    // 3. Draw the Player's Name inside the Node
    final textSpan = TextSpan(
      text: node.profile.name,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: 0, maxWidth: nodeRadius * 2);

    // Center the text inside the circle
    final textOffset = Offset(x - (textPainter.width / 2), y - (textPainter.height / 2));
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}