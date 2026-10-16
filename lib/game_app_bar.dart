import 'package:flutter/material.dart';

// [Documentation State: FINISHED]

/// The App Bar of our application. It requires a [VoidCallback] method at it's construction.
/// The passed method will trigger everytime you press the Restart Game Icon at the far right
/// of the App Bar. So what you need to pass is a [VoidCallback] method that implements the
/// behaviour of restarting the Game of Hex.
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRestart;

  const GameAppBar({
    super.key,
    required this.onRestart
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Hex Tabletop Game"),
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: "Restart Game",
          onPressed: onRestart,
        )
      ],
    );
  }

  // we need to register the heigth of the AppBar beforehand such that the Scaffold knows
  // where to start drawing the body. This is because we are implementing our own custom
  // AppBar. The AppBar already has this defined within it, but since we have a new class
  // we also need to define this ourselves, but we simply copy the implementation of the
  // general AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}