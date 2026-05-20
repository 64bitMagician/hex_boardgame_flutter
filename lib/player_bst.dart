import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfile {
  String name;
  int wins;
  int losses;

  PlayerProfile({required this.name, this.wins = 0, this.losses = 0});

  Map<String, dynamic> toJson() => {
    'name': name,
    'wins': wins,
    'losses': losses,
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'],
      wins: json['wins'],
      losses: json['losses'],
    );
  }
}

class BSTNode {
  PlayerProfile profile;
  BSTNode? left;
  BSTNode? right;

  BSTNode(this.profile);
}

class PlayerBST {
  BSTNode? root;

  void insert(PlayerProfile newProfile) {
    root = _insertRec(root, newProfile);
  }

  BSTNode _insertRec(BSTNode? node, PlayerProfile newProfile) {
    if (node == null) {
      return BSTNode(newProfile);
    }
    int cmp = newProfile.name.toLowerCase().compareTo(node.profile.name.toLowerCase());

    if (cmp < 0) {
      node.left = _insertRec(node.left, newProfile);
    } else if (cmp > 0) {
      node.right = _insertRec(node.right, newProfile);
    }
    return node;
  }

  PlayerProfile? search(String name) {
    BSTNode? result = _searchRec(root, name.toLowerCase());
    return result?.profile;
  }

  BSTNode? _searchRec(BSTNode? node, String targetName) {
    if (node == null) return null;

    int cmp = targetName.compareTo(node.profile.name.toLowerCase());
    if (cmp == 0) {
      return node;
    } else if (cmp < 0) {
      return _searchRec(node.left, targetName);
    } else {
      return _searchRec(node.right, targetName);
    }
  }

  List<PlayerProfile> getAllPlayersAlphabetically() {
    List<PlayerProfile> list = [];
    _inOrder(root, list);
    return list;
  }

  void _inOrder(BSTNode? node, List<PlayerProfile> list) {
    if (node != null) {
      _inOrder(node.left, list);
      list.add(node.profile);
      _inOrder(node.right, list);
    }
  }

  List<PlayerProfile> searchByPrefix(String prefix) {
    String lowerPrefix = prefix.toLowerCase();
    List<PlayerProfile> allPlayers = getAllPlayersAlphabetically();
    return allPlayers.where((p) => p.name.toLowerCase().startsWith(lowerPrefix)).toList();
  }

  Future<void> saveTreeToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    List<PlayerProfile> sortedPlayers = getAllPlayersAlphabetically();

    List<Map<String, dynamic>> jsonList = sortedPlayers.map((p) => p.toJson()).toList();

    String jsonString = jsonEncode(jsonList);
    await prefs.setString('hex_players_data', jsonString);
  }

  Future<void> loadTreeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('hex_players_data');

    if (jsonString != null && jsonString.isNotEmpty) {
      List<dynamic> decodedList = jsonDecode(jsonString);

      List<PlayerProfile> sortedPlayers = decodedList.map((json) => PlayerProfile.fromJson(json)).toList();

      root = _buildBalancedTree(sortedPlayers, 0, sortedPlayers.length - 1);
    }
  }

  BSTNode? _buildBalancedTree(List<PlayerProfile> list, int start, int end) {
    if (start > end) {
      return null;
    }

    int mid = start + (end - start) ~/ 2;
    BSTNode node = BSTNode(list[mid]);

    node.left = _buildBalancedTree(list, start, mid - 1);
    node.right = _buildBalancedTree(list, mid + 1, end);

    return node;
  }
}