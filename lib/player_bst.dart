import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 1. The Data Model
class PlayerProfile {
  String name;
  int wins;
  int losses;

  PlayerProfile({required this.name, this.wins = 0, this.losses = 0});

  // To easily convert to JSON later for saving
  Map<String, dynamic> toJson() => {
    'name': name,
    'wins': wins,
    'losses': losses,
  };

  // To easily rebuild from JSON later when loading
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'],
      wins: json['wins'],
      losses: json['losses'],
    );
  }
}

/// 2. The BST Node
class BSTNode {
  PlayerProfile profile;
  BSTNode? left;
  BSTNode? right;

  BSTNode(this.profile);
}

/// 3. The Binary Search Tree Logic
class PlayerBST {
  BSTNode? root;

  // Insert a new player (Sorted alphabetically by name)
  void insert(PlayerProfile newProfile) {
    root = _insertRec(root, newProfile);
  }

  BSTNode _insertRec(BSTNode? node, PlayerProfile newProfile) {
    if (node == null) {
      return BSTNode(newProfile);
    }
    // Compare names alphabetically (case-insensitive for better UX)
    int cmp = newProfile.name.toLowerCase().compareTo(node.profile.name.toLowerCase());

    if (cmp < 0) {
      node.left = _insertRec(node.left, newProfile);
    } else if (cmp > 0) {
      node.right = _insertRec(node.right, newProfile);
    }
    // If cmp == 0, the name already exists. We just return the node to ignore duplicates.
    return node;
  }

  // Search for an exact player by name
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

  // In-Order Traversal (Used for saving and dropdown lists)
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

  // Prefix Search for the Autocomplete UI
  List<PlayerProfile> searchByPrefix(String prefix) {
    String lowerPrefix = prefix.toLowerCase();
    List<PlayerProfile> allPlayers = getAllPlayersAlphabetically();
    // Filter the alphabetical list by those starting with the prefix
    return allPlayers.where((p) => p.name.toLowerCase().startsWith(lowerPrefix)).toList();
  }

  // ==========================================
  // SERIALIZATION: SAVING & LOADING (BALANCING)
  // ==========================================

  /// SAVING: We save the tree alphabetically (In-Order Traversal)
  Future<void> saveTreeToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Get the alphabetical list
    List<PlayerProfile> sortedPlayers = getAllPlayersAlphabetically();

    // 2. Convert to standard JSON Maps
    List<Map<String, dynamic>> jsonList = sortedPlayers.map((p) => p.toJson()).toList();

    // 3. Save as a flat JSON string
    String jsonString = jsonEncode(jsonList);
    await prefs.setString('hex_players_data', jsonString);
  }

  /// LOADING: Optimal "Middle Element" algorithm to guarantee an O(log N) balanced tree
  Future<void> loadTreeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('hex_players_data');

    if (jsonString != null && jsonString.isNotEmpty) {
      // 1. Decode the string
      List<dynamic> decodedList = jsonDecode(jsonString);

      // 2. Convert to PlayerProfile objects
      List<PlayerProfile> sortedPlayers = decodedList.map((json) => PlayerProfile.fromJson(json)).toList();

      // 3. Build a perfectly balanced BST from the sorted list!
      root = _buildBalancedTree(sortedPlayers, 0, sortedPlayers.length - 1);
    }
  }

  /// Recursive median split to balance the tree on load
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