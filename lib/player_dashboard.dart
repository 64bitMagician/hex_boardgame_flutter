import 'package:flutter/material.dart';
import 'hex_engine.dart';
import 'player_bst.dart';

// [Documentation State: ___]

class PlayerDashboard extends StatelessWidget {
  final Player currentPlayer;
  final bool gameOver;
  final PlayerProfile? redPlayer;
  final PlayerProfile? bluePlayer;
  final Function(Player) onLoginTap;

  const PlayerDashboard({
    super.key,
    required this.currentPlayer,
    required this.gameOver,
    required this.redPlayer,
    required this.bluePlayer,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPlayerCard(
            playerSide: Player.red,
            profile: redPlayer,
            color: Colors.red,
            icon: Icons.link,
            goalText: "Link Top & Bottom",
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
                color: gameOver
                    ? (currentPlayer == Player.red ? Colors.red.shade100 : Colors.blue.shade100)
                    : (currentPlayer == Player.red ? Colors.red.shade50 : Colors.blue.shade50),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: currentPlayer == Player.red ? Colors.red : Colors.blue,
                    width: 2
                )
            ),
            child: Text(
              gameOver ? "${currentPlayer == Player.red ? 'RED' : 'BLUE'} WINS!" : "${currentPlayer == Player.red ? 'Red' : 'Blue'}'s Turn",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: currentPlayer == Player.red ? Colors.red.shade900 : Colors.blue.shade900,
              ),
            ),
          ),

          _buildPlayerCard(
            playerSide: Player.blue,
            profile: bluePlayer,
            color: Colors.blue,
            icon: Icons.link,
            goalText: "Link Left & Right",
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({required Player playerSide, required PlayerProfile? profile, required MaterialColor color, required IconData icon, required String goalText}) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onLoginTap(playerSide),
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.shade50,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                  profile?.name.toUpperCase() ?? "LOGIN ${playerSide == Player.red ? 'RED' : 'BLUE'}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.shade700)
              ),
              const SizedBox(height: 4),
              if (profile != null)
                Text("W: ${profile.wins} | L: ${profile.losses}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: color.shade300),
                  const SizedBox(width: 6),
                  Text(goalText, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}