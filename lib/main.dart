import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'leaderboard_screen.dart';
import 'dart:math' as math;
import 'hex_engine.dart';
import 'player_bst.dart';
import 'player_dashboard.dart';
import 'game_board_view.dart';
import 'game_app_bar.dart';
import 'game_bottom_bar.dart';
import 'login_dialog.dart';
import 'visual_tree_screen.dart';

// [Documentation State: ___]

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HexGameScreen()),
  );
}

class HexGameScreen extends StatefulWidget {
  const HexGameScreen({Key? key}) : super(key: key);

  @override
  State<HexGameScreen> createState() => _HexGameScreenState();
}

class _HexGameScreenState extends State<HexGameScreen> {
  late HexEngine _engine;
  Player _currentPlayer = Player.red;
  bool _gameOver = false;
  final double _hexRadius = 30.0;

  final PlayerBST _playerDB = PlayerBST();
  PlayerProfile? _redPlayer;
  PlayerProfile? _bluePlayer;

  @override
  void initState() {
    super.initState();
    _engine = HexEngine(boardSize: 11);
    _loadDatabase();
  }

  Future<void> _loadDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('hex_players_data')) {
      String dummyData = ''' 
      [
        {"name": "Aaron", "wins": 14, "losses": 21},
        {"name": "Alice", "wins": 42, "losses": 10},
        {"name": "Bella", "wins": 25, "losses": 30},
        {"name": "Bob", "wins": 55, "losses": 5},
        {"name": "Caleb", "wins": 12, "losses": 40},
        {"name": "Charlie", "wins": 33, "losses": 15},
        {"name": "Chloe", "wins": 8, "losses": 12},
        {"name": "Daniel", "wins": 60, "losses": 2},
        {"name": "David", "wins": 19, "losses": 20},
        {"name": "Diana", "wins": 45, "losses": 22},
        {"name": "Emma", "wins": 31, "losses": 11},
        {"name": "Eve", "wins": 27, "losses": 27},
        {"name": "Finn", "wins": 10, "losses": 50},
        {"name": "Frank", "wins": 4, "losses": 8},
        {"name": "Gina", "wins": 38, "losses": 19},
        {"name": "Grace", "wins": 50, "losses": 10},
        {"name": "Harry", "wins": 22, "losses": 33},
        {"name": "Heidi", "wins": 15, "losses": 15},
        {"name": "Isla", "wins": 41, "losses": 9},
        {"name": "Ivan", "wins": 5, "losses": 25},
        {"name": "Jack", "wins": 65, "losses": 4},
        {"name": "Judy", "wins": 28, "losses": 28},
        {"name": "Kira", "wins": 34, "losses": 16},
        {"name": "Liam", "wins": 11, "losses": 42},
        {"name": "Mallory", "wins": 49, "losses": 21},
        {"name": "Mia", "wins": 37, "losses": 13},
        {"name": "Nina", "wins": 18, "losses": 30},
        {"name": "Noah", "wins": 52, "losses": 8},
        {"name": "Olivia", "wins": 29, "losses": 14},
        {"name": "Oscar", "wins": 7, "losses": 55},
        {"name": "Paul", "wins": 44, "losses": 26},
        {"name": "Peggy", "wins": 20, "losses": 20},
        {"name": "Quinn", "wins": 36, "losses": 18},
        {"name": "Romeo", "wins": 9, "losses": 35},
        {"name": "Ruby", "wins": 58, "losses": 12},
        {"name": "Sam", "wins": 24, "losses": 24},
        {"name": "Sybil", "wins": 47, "losses": 23},
        {"name": "Tara", "wins": 32, "losses": 15},
        {"name": "Trent", "wins": 13, "losses": 45},
        {"name": "Uma", "wins": 61, "losses": 9},
        {"name": "Victor", "wins": 26, "losses": 26},
        {"name": "Vince", "wins": 3, "losses": 17},
        {"name": "Walter", "wins": 39, "losses": 11},
        {"name": "Will", "wins": 53, "losses": 17},
        {"name": "Xander", "wins": 16, "losses": 38},
        {"name": "Yara", "wins": 43, "losses": 7},
        {"name": "Zane", "wins": 21, "losses": 49},
        {"name": "Zoe", "wins": 66, "losses": 3}
      ]
      ''';

      await prefs.setString('hex_players_data', dummyData);
    }

    await _playerDB.loadTreeFromStorage();
    setState(() {});
  }

  void _handleTap(TapDownDetails details) {
    if (_gameOver) return;

    if (_redPlayer == null || _bluePlayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select profiles for both players first!"),
        ),
      );
      return;
    }

    final double actualX = details.localPosition.dx;
    final double actualY = details.localPosition.dy;
    final double h = _hexRadius;
    final double w = math.sqrt(3) * h;
    double minDistance = double.infinity;
    int? bestRow;
    int? bestCol;

    for (int r = 0; r < _engine.boardSize; r++) {
      for (int c = 0; c < _engine.boardSize; c++) {
        final double hexCenterX = (c * w) + (r * w / 2) + w / 2;
        final double hexCenterY = (r * 1.5 * h) + h;
        double dist = math.sqrt(
          math.pow(actualX - hexCenterX, 2) + math.pow(actualY - hexCenterY, 2),
        );

        if (dist < minDistance) {
          minDistance = dist;
          bestRow = r;
          bestCol = c;
        }
      }
    }

    if (minDistance <= _hexRadius && bestRow != null && bestCol != null) {
      setState(() {
        if (_engine.makeMove(bestRow!, bestCol!, _currentPlayer)) {
          if (_engine.checkWin(_currentPlayer)) {
            _gameOver = true;
            _recordMatchResults();
          } else {
            _currentPlayer =
                (_currentPlayer == Player.red) ? Player.blue : Player.red;
          }
        }
      });
    }
  }

  void _recordMatchResults() {
    if (_redPlayer != null && _bluePlayer != null) {
      if (_currentPlayer == Player.red) {
        _redPlayer!.wins += 1;
        _bluePlayer!.losses += 1;
      } else {
        _bluePlayer!.wins += 1;
        _redPlayer!.losses += 1;
      }
      _playerDB.saveTreeToStorage();
    }
  }

  void _openLoginDialog(Player side) {
    bool gameInProgress = _engine.board.any((cell) => cell != Player.none) && !_gameOver;

    if (gameInProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cannot switch profiles mid-game! Finish or Reset the game first."),
            backgroundColor: Colors.orange,
          )
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => LoginDialog(
        side: side,
        playerDB: _playerDB,
        onProfileSelected: (selectedProfile) {

          if (side == Player.red && _bluePlayer?.name == selectedProfile.name) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("This player is already logged in as Blue!"),
                  backgroundColor: Colors.red,
                )
            );
            return;
          }

          if (side == Player.blue && _redPlayer?.name == selectedProfile.name) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("This player is already logged in as Red!"),
                  backgroundColor: Colors.red,
                )
            );
            return;
          }

          setState(() {
            if (side == Player.red) {
              _redPlayer = selectedProfile;
            } else {
              _bluePlayer = selectedProfile;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: GameAppBar(
        onRestart:
            () => setState(() {
              _engine = HexEngine(boardSize: 11);
              _currentPlayer = Player.red;
              _gameOver = false;
              _redPlayer = null;
              _bluePlayer = null;
            }),
      ),
      body: Column(
        children: [
          PlayerDashboard(
            currentPlayer: _currentPlayer,
            gameOver: _gameOver,
            redPlayer: _redPlayer,
            bluePlayer: _bluePlayer,
            onLoginTap: _openLoginDialog,
          ),
          Expanded(
            child: GameBoardView(
              engine: _engine,
              hexRadius: _hexRadius,
              onBoardTap: _handleTap,
            ),
          ),
          GameBottomBar(
            onLeaderboardTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardScreen(playerDB: _playerDB),
                ),
              );
            },
            onViewTreeTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisualTreeScreen(playerDB: _playerDB),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
