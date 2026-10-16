import 'package:flutter/material.dart';
import 'player_bst.dart';
import 'user_profile_screen.dart';

// [Documentation State: ___]

class NodeHitbox {
  final PlayerProfile profile;
  final Rect rect;
  NodeHitbox(this.profile, this.rect);
}

class VisualTreeScreen extends StatefulWidget {
  final PlayerBST playerDB;

  const VisualTreeScreen({super.key, required this.playerDB});

  @override
  State<VisualTreeScreen> createState() => _VisualTreeScreenState();
}

class _VisualTreeScreenState extends State<VisualTreeScreen> {
  // here will be stored all hitboxes of the nodes
  // it represents the areas on the InteractiveViewer where user tap interactions
  // should trigger a specific behaviour
  // such as in our case, navigating to that Player node's profile
  final List<NodeHitbox> _hitboxes = [];

  // This method handles the screen tap verification
  // if the tap has occured in one of the hitboxes in _hitboxes
  // then we navigate to that correspnding NodeHitboxe's PlayerProfile
  void _handleTap(TapUpDetails details) {
    // we iterate all hitbox node areas
    for (var hitbox in _hitboxes) {
      // if the tap occured in the hitbox
      if (hitbox.rect.contains(details.localPosition)) {
        // Navigate to the UserProfileScreen of that node/Player
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(profile: hitbox.profile, onDelete: () {
              // This code waits until the button is pressed in the profile screen
              widget.playerDB.remove(hitbox.profile.name);
              widget.playerDB.saveTreeToStorage();
              setState(() {}); // This refreshes your tree view
            },),
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
          child: Container( // The area on which the Painter is constrained to work on
            // the container has coordinates 0,0 at the top left corner of the scaffold body
            // and so will CustomPaint and it's canvas
            width: 4000,
            height: 4000,
            color: Colors.transparent,
            // we do not define a size nor a child for CustomPaint, so it will inherit the size of it's parent (the drawing area)
            child: CustomPaint(
              painter: BSTPainter(widget.playerDB.root, _hitboxes), // the painter that will paint our tree
              // CustomPaint will generate the size of the canvas as big as itself
              // Since CustomPaint is a Child of Container, they are stacked, which means they have the exact same coordinate origin
              // which means that the canvas is exactly the Container area
            ),
          ),
        ),
      ),
    );
  }
}

/// The painting tool used to paint the BST tree.
class BSTPainter extends CustomPainter {
  final BSTNode? root;
  final List<NodeHitbox> hitboxes;
  final double nodeRadius = 30.0;

  BSTPainter(this.root, this.hitboxes);

  @override
  void paint(Canvas canvas, Size size) {
    // do nothing if no root provided | no tree
    if (root == null) return;

    // if there is a tree:
    // draw the node on the given canvas (Container Widget)
    // Pass the node structrure
    // pass the horizontalSpacing -
    // you pass the x and y coordinates where to draw the node
    _drawNode(
      canvas: canvas,
      node: root!,
      x: size.width / 2,
      y: 100,
      horizontalSpacing: size.width / 4,
    );
  }

  // custom method to draw a node
  void _drawNode({
    required Canvas canvas,
    required BSTNode node,
    required double x, // x coordinate of the node you want to create on the canvas
    required double y, // y coordinate of the node you want to create on the canvas
    required double horizontalSpacing,
  }) {
    // define the "brush" for connecting lines
    final paintLine = Paint()
      ..color = Colors.white54
      ..strokeWidth = 3.0;

    // define the "brush" for nodes
    final paintNode = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    // if we have node on the left
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