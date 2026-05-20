import 'package:flutter/material.dart';

class GameBottomBar extends StatelessWidget {
  final VoidCallback onLeaderboardTap;
  final VoidCallback onViewTreeTap; // NEW: Callback for the Tree screen

  const GameBottomBar({
    Key? key,
    required this.onLeaderboardTap,
    required this.onViewTreeTap,    // NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.leaderboard),
              label: const Text("Leaderboard"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: onLeaderboardTap,
            ),

            // NEW: The Button to view the Data Structure
            ElevatedButton.icon(
              icon: const Icon(Icons.account_tree),
              label: const Text("Visual BST"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: onViewTreeTap,
            ),
          ],
        ),
      ),
    );
  }
}