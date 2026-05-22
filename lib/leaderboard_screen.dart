import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import 'player_bst.dart';

// [Documentation State: FINISHED]

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
    // get all players
    _rankedPlayers = widget.playerDB.getAllPlayersAlphabetically();

    // sort them by win count
    _rankedPlayers.sort((a, b) {
      int winComparison = b.wins.compareTo(a.wins);
      // if not equal in wins
      if (winComparison != 0) {
        return winComparison;
      }
      // if equal in wins, the one with less losses is in front
      return a.losses.compareTo(b.losses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Leaderboard"),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      body: _rankedPlayers.isEmpty
          ? const Center(
        child: Text(
          "No players yet!",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _rankedPlayers.length,
        itemBuilder: (context, index) {
          final player = _rankedPlayers[index];

          Color rankColor;
          if (index == 0) rankColor = Colors.amber; // Gold
          else if (index == 1) rankColor = Colors.grey.shade400; // Silver
          else if (index == 2) rankColor = Colors.brown.shade300; // Bronze
          else rankColor = Colors.blueGrey.shade100;

          return Card(
            elevation: index < 3 ? 4 : 1, // spotlight effect for first 3 players
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(profile: player), // when clicking on a player, navigate to his profile screen
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // method to calculate win/matches played ratio of a player
  String _calculateRatio(int wins, int losses) {
    if (wins == 0 && losses == 0) return "0.0";
    double ratio = (wins / (wins + losses)) * 100; // wins over matches played
    return ratio.toStringAsFixed(1); // we keep one decimal place
  }
}