import 'package:flutter/material.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRestart;

  const GameAppBar({
    Key? key,
    required this.onRestart
  }) : super(key: key);

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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}