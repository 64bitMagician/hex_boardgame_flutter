import 'package:flutter/material.dart';

// [Documentation State: FINISHED]

/// The Bottom App Bar of the Application. At widget construction, it requires two [VoidCallback] functions.
/// One will be stored as trigger for the Leaderboard Button. The other will be stored as trigger for the View BST Button.
class GameBottomBar extends StatelessWidget {
  // Callbacks for what happens when you click on the Leaderboard and ViewTree Buttons
  final VoidCallback onLeaderboardTap;
  final VoidCallback onViewTreeTap;

  // The callbacks need to be passed at construction of widget
  const GameBottomBar({
    Key? key,
    required this.onLeaderboardTap,
    required this.onViewTreeTap,
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

            // LEADERBOARD BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.leaderboard),
              label: const Text("Leaderboard"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: onLeaderboardTap, // when pressed => executes oneLeaderboardTap callback function behaviour
            ),

            // VISUAL BST BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.account_tree),
              label: const Text("Visual BST"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: onViewTreeTap, // when pressed => executes onViewTreeTap callback function behaviour
            ),
          ],
        ),
      ),
    );
  }
}