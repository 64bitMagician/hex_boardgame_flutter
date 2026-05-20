import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import 'player_bst.dart';

class LeaderboardScreen extends StatefulWidget {
  final PlayerBST playerDB;

  const LeaderboardScreen({Key? key, required this.playerDB}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late List<PlayerProfile> _rankedPlayers;

  @override
  void initState() {
    super.initState();
    _loadAndSortPlayers();
  }

  void _loadAndSortPlayers() {
    // 1. Get the list from the BST (O(N) Traversal)
    _rankedPlayers = widget.playerDB.getAllPlayersAlphabetically();

    // 2. Sort the list descending by Wins, then by fewest Losses if there's a tie
    _rankedPlayers.sort((a, b) {
      int winComparison = b.wins.compareTo(a.wins);
      if (winComparison != 0) {
        return winComparison;
      }
      return a.losses.compareTo(b.losses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Hall of Fame"),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        actions: [
          // This button will eventually navigate to your Visual Tree screen!
          IconButton(
            icon: const Icon(Icons.account_tree),
            tooltip: "View BST Structure",
            onPressed: () {
              // TODO: Navigate to the Visual BST Painter Screen
            },
          )
        ],
      ),
      body: _rankedPlayers.isEmpty
          ? const Center(
        child: Text(
          "No players yet! Go play some matches.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _rankedPlayers.length,
        itemBuilder: (context, index) {
          final player = _rankedPlayers[index];

          // Style the top 3 players specially
          Color rankColor;
          if (index == 0) rankColor = Colors.amber; // Gold
          else if (index == 1) rankColor = Colors.grey.shade400; // Silver
          else if (index == 2) rankColor = Colors.brown.shade300; // Bronze
          else rankColor = Colors.blueGrey.shade100;

          return Card(
            elevation: index < 3 ? 4 : 1,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: rankColor,
                foregroundColor: index < 3 ? Colors.white : Colors.black87,
                child: Text("#${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                  player.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              subtitle: Text("Win Ratio: ${_calculateRatio(player.wins, player.losses)}%"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${player.wins} Wins", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text("${player.losses} Losses", style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
              // NEW: Navigate to the profile screen on tap!
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(profile: player),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _calculateRatio(int wins, int losses) {
    if (wins == 0 && losses == 0) return "0.0";
    double ratio = (wins / (wins + losses)) * 100;
    return ratio.toStringAsFixed(1); // Keep one decimal place
  }
}