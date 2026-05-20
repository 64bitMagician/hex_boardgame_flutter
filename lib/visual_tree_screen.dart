import 'package:flutter/material.dart';
import 'player_bst.dart';
import 'user_profile_screen.dart';

class NodeHitbox {
  final PlayerProfile profile;
  final Rect rect;
  NodeHitbox(this.profile, this.rect);
}

class VisualTreeScreen extends StatefulWidget {
  final PlayerBST playerDB;

  const VisualTreeScreen({Key? key, required this.playerDB}) : super(key: key);

  @override
  State<VisualTreeScreen> createState() => _VisualTreeScreenState();
}

class _VisualTreeScreenState extends State<VisualTreeScreen> {
  List<NodeHitbox> _hitboxes = [];

  void _handleTap(TapUpDetails details) {
    for (var hitbox in _hitboxes) {
      if (hitbox.rect.contains(details.localPosition)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(profile: hitbox.profile),
          ),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _hitboxes.clear();

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text("BST Structure"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(2000),
        minScale: 0.1,
        maxScale: 5.0,
        child: GestureDetector(
          onTapUp: _handleTap,
          child: Container(
            width: 4000,
            height: 4000,
            color: Colors.transparent,
            child: CustomPaint(
              painter: BSTPainter(widget.playerDB.root, _hitboxes),
            ),
          ),
        ),
      ),
    );
  }
}

class BSTPainter extends CustomPainter {
  final BSTNode? root;
  final List<NodeHitbox> hitboxes;
  final double nodeRadius = 30.0;

  BSTPainter(this.root, this.hitboxes);

  @override
  void paint(Canvas canvas, Size size) {
    if (root == null) return;

    _drawNode(
      canvas: canvas,
      node: root!,
      x: size.width / 2,
      y: 100,
      horizontalSpacing: size.width / 4,
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

    if (node.left != null) {
      double nextX = x - horizontalSpacing;
      double nextY = y + 100;
      canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paintLine);
      _drawNode(
        canvas: canvas,
        node: node.left!,
        x: nextX,
        y: nextY,
        horizontalSpacing: horizontalSpacing / 2,
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

    canvas.drawCircle(Offset(x, y), nodeRadius, paintNode);
    canvas.drawCircle(Offset(x, y), nodeRadius, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

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
    final textOffset = Offset(x - (textPainter.width / 2), y - (textPainter.height / 2));
    textPainter.paint(canvas, textOffset);

    hitboxes.add(NodeHitbox(
      node.profile,
      Rect.fromCircle(center: Offset(x, y), radius: nodeRadius),
    ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}