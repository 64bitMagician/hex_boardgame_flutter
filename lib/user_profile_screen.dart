import 'package:flutter/material.dart';
import 'player_bst.dart';

class UserProfileScreen extends StatelessWidget {
  final PlayerProfile profile;

  const UserProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalGames = profile.wins + profile.losses;
    double winRate = totalGames == 0 ? 0 : (profile.wins / totalGames) * 100;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("${profile.name}'s Profile"),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey.shade800,
                child: Text(
                  profile.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                profile.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 40, thickness: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn("Wins", profile.wins, Colors.green),
                  _buildStatColumn("Losses", profile.losses, Colors.red),
                ],
              ),
              const SizedBox(height: 20),

              Text("Win Rate: ${winRate.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: totalGames == 0 ? 0 : profile.wins / totalGames,
                backgroundColor: Colors.red.shade200,
                color: Colors.green,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 10),
              Text("$totalGames Total Matches Played", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}