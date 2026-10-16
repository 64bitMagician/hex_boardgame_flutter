import 'dart:convert';
import 'package:hex_boardgame_flutter/hex_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

// [Documentation State: FINISHED]

/// The Player Profile holds data such as [name] [wins] and [losses].
class PlayerProfile {
  String name;
  int wins;
  int losses;

  /// It only requires the name at instantiation. If only name is provided, wins and losses = 0.
  /// You can also provide the count for wins and losses...
  PlayerProfile({required this.name, this.wins = 0, this.losses = 0});

  /// This method translates .this [PlayerProfile] instance's member data to JSON format in the form of a [Map].
  Map<String, dynamic> toJson() => {
    'name': name,
    'wins': wins,
    'losses': losses,
  };

  /// Factory Constructor. Used for creating [PlayerProfile] objects from data
  /// retrieved from JSONs. You just need to call this factory constructor [PlayerProfile.fromJson]
  /// and feed it the Map<String, dynamic>
  /// From there it will simply return you the PlayerProfile based on the provided [Map]
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'],
      wins: json['wins'],
      losses: json['losses'],
    );
  }

}

/// The Binary Search Tree Node Structure. Holds data for [PlayerProfile], reference to [BSTNode] on the left,
/// and reference to [BSTNode] on the right.
class BSTNode {
  PlayerProfile profile;
  BSTNode? left; // (nullable) automatically initialized with null
  BSTNode? right; // (nullable) automatically initialized with null

  /// The construction of a [BSTNode] only requires a [PlayerProfile] to be passed.
  BSTNode(this.profile);
}

/// The Binary Search Tree Structure that holds [BSTNode] references ([PlayerProfile] objects).
/// [PlayerBST] actually holds reference to the [root] node. From there you can cascade to access all nodes.
class PlayerBST {
  BSTNode? root;

  /// Method to insert a [PlayerProfile] node.
  void insert(PlayerProfile newProfile) {
    root = _insertRec(root, newProfile);
  }

  // This method wraps a PlayerProfile into a Node object such that it can be inserted in the tree.
  // It requires a node from where to start the navigation, and the
  // PlayerProfile instance to be wrapped into a node.
  BSTNode _insertRec(BSTNode? node, PlayerProfile newProfile) {
    // If root/leaf_node is null, we simply return the BSTNode wrapping the newProfile
    if (node == null) {
      return BSTNode(newProfile);
    }

    // If the root/leaf_node exists, we need to traverse it up to a leaf place.
    // We also need to define the comparison between nodes, which in our case is
    // alphabetically based: a < z

    // We use compareTo for this. It returns
    //  - negative if x < y
    //  - 0 if x == y
    //  - positive if x > y

    // we compare the new profile's to insert name <--to--> the currently iterating node's name
    int cmp = newProfile.name.toLowerCase().compareTo(node.profile.name.toLowerCase());

    if (cmp < 0) { // new name is lower
      node.left = _insertRec(node.left, newProfile); // recursive call | we assign currently iterating node | we go left node
    } else if (cmp > 0) { // new name is bigger
      node.right = _insertRec(node.right, newProfile); // recursive call | we assign currently iterating node | we go right node
    }

    // if reaching this: we return an already existing node to be assigned to itself
    return node;
  }

  /// This method returns the PlayerProfile that holds the corresponding passed name passed as argument to the method
  PlayerProfile? search(String name) {
    BSTNode? result = _searchRec(root, name.toLowerCase()); // we search for the node instance
    return result?.profile; // we return the PlayerProfile object inside the node
  }

  // This method performs the search within the BSTree.
  BSTNode? _searchRec(BSTNode? node, String targetName) {
    // Name could not be found in the tree so we return null
    // It may also be the case that the tree is empty. No Player Profiles.
    if (node == null) return null;

    // If the node exists, we need to start traversing.
    // We also need to define the comparison between nodes, which in our case is
    // alphabetically based: a < z

    // We use compareTo for this. It returns
    //  - negative if x < y
    //  - 0 if x == y
    //  - positive if x > y

    // we compare the targetName to the name of the currently iterated node
    int cmp = targetName.compareTo(node.profile.name.toLowerCase());

    if (cmp == 0) { // we found the node and return it (the currently iterated node)
      return node;
    } else if (cmp < 0) { // node is on the left
      return _searchRec(node.left, targetName); // recursive call | we go left
    } else { // node is on the right
      return _searchRec(node.right, targetName); // recursive call | we go right
    }
  }


  /// Get a full list with the player profiles in alphabetical order.
  /// The tree is already structure to be in an alphabetical order in relation
  /// to the inOrder Traversal
  List<PlayerProfile> getAllPlayersAlphabetically() {
    List<PlayerProfile> list = [];
    _inOrder(root, list); // we perform the in order traversal
    return list;
  }

  // InOrder Traversal [Left - Root - Right]
  void _inOrder(BSTNode? node, List<PlayerProfile> list) {
    // We perform until reaching the last null node empty space.
    if (node != null) {
      _inOrder(node.left, list); // go left
      list.add(node.profile); // add current node's profile to list
      _inOrder(node.right, list); // go right
    }
  }

  /// This method returns a list of all [PlayerProfile] instances that start with the given [prefix]
  List<PlayerProfile> searchByPrefix(String prefix) {
    String lowerPrefix = prefix.toLowerCase(); // to lower case
    List<PlayerProfile> allPlayers = getAllPlayersAlphabetically(); // get list of all players
    // now we return a list of all PlayerProfile objects that start with the given prefix
    return allPlayers.where((p) => p.name.toLowerCase().startsWith(lowerPrefix)).toList();
  }

  /// Save the BST PlayerProfile data into the local storage of the browser.
  /// The data is stored as a value in JSON Format.
  /// The JSON data is sorted alphabetically.
  Future<void> saveTreeToStorage() async {
    // get instance of shared preferences
    final prefs = await SharedPreferences.getInstance();

    // we get the list of all players sorted alphabetically
    List<PlayerProfile> sortedPlayers = getAllPlayersAlphabetically();

    // We create list containing Map/JSON format representations of all PlayerProfiles
    // The conversion takes place through the PlayerProfile.toJson method, which returns
    // a Map<String, dynamic>
    List<Map<String, dynamic>> jsonList = sortedPlayers.map((p) => p.toJson()).toList();

    // Convert the list to a JSON String such that it can be inserted into a JSON File
    String jsonString = jsonEncode(jsonList);
    // through our shared preferences instance, we save a key-value pair on browser's local storage
    // where the key is 'hex_players_data' and the value is our jsonString containing
    // the list of all our PlayerProfile instances
    await prefs.setString('hex_players_data', jsonString);
  }

  /// Fetch the PlayerProfile Instances data from the local storage of browser
  /// It also triggers the creation of the BST tree starting from the root node.
  Future<void> loadTreeFromStorage() async {
    // get shared preferences instance
    final prefs = await SharedPreferences.getInstance();

    // get the jsonString back from the stored value under the key: 'hex_players_data'
    String? jsonString = prefs.getString('hex_players_data');

    // get back the list of PlayerProfiles from the jsonString
    if (jsonString != null && jsonString.isNotEmpty) {
      // The stored data may be corrupted (invalid JSON, wrong types, missing fields).
      // jsonDecode throws a FormatException, and fromJson throws a TypeError, so we
      // catch everything and fall back to an empty database instead of crashing the app.
      // The corrupted value is overwritten the next time the tree is saved.
      try {
        // get each PlayerProfile Map Data
        List<dynamic> decodedList = jsonDecode(jsonString);

        // create list of PlayerProfile instances from the decodedList
        List<PlayerProfile> sortedPlayers = decodedList.map((json) => PlayerProfile.fromJson(json)).toList();

        // build the BST from the list of PlayerProfiles
        root = _buildBalancedTree(sortedPlayers, 0, sortedPlayers.length - 1);
      } catch (e) {
        root = null; // empty database
      }
    }
  }

  // This method is responsible for building the BST tree from the alphabetically sorted list
  // of PlayerProfile Instances
  // This method is actually responsible for cutting the list of PlayerProfile from the middle
  // Thus making the BST balanced
  // And because the list is already sorted alphabetically
  // The BST tree will also be in alphabetical form when traversed inOrder (Left - Node - Right)
  BSTNode? _buildBalancedTree(List<PlayerProfile> list, int start, int end) {
    // we stop once we process all nodes
    if (start > end) {
      return null;
    }

    // get the index of the middle element from the list
    int mid = start + (end - start) ~/ 2;
    // Instantiate that node
    BSTNode node = BSTNode(list[mid]);

    // we cut into sublists recursivelly:
    node.left = _buildBalancedTree(list, start, mid - 1); // sublist to the left of middle
    node.right = _buildBalancedTree(list, mid + 1, end); // sublist to the right of middle

    return node; // return the current node
    // first call it is the root node itself
    // all other calls are for assigning the children nodes
    // each time we pass to the left child the middle node from the sublist on the left of the current node
    //               and to the right child, the middle node from the sublist on the right of the current node
  }

  /// Public method to remove a player by name
  void remove(String name) {
    root = _removeRec(root, name.toLowerCase());
  }

  // This method removes a node from the BST Player tree.
  // It removes the node that matches the targetName
  // It starts removing from the passed node (root of tree or not)
  BSTNode? _removeRec(BSTNode? node, String targetName) {
    // if no tree return nothing
    if (node == null) return null;

    // compare given name to current node's name
    int cmp = targetName.compareTo(node.profile.name.toLowerCase());

    // if smaller alphabetically > go left
    if (cmp < 0) {
      node.left = _removeRec(node.left, targetName);
    } else if (cmp > 0) { // if bigger alphabetically > go right
      node.right = _removeRec(node.right, targetName);
    } else {
      // Node found!

      // Case 1 and 2: No child or only one child
      if (node.left == null) return node.right; // if right is also null, it means current node is leaf anyway, so we can return null directly instead of current node
                                                // if right is not null, it is safe to return right node because it is the only child node and we can directly connect it to the parent of current node we want to delete
      if (node.right == null) return node.left; // if there is something on the left, but not on the right, there is only one child, and we can directly return the left child

      // Case 3: Two children
      // Find the in-order successor | find the smallest node after current node
      // assign the profile of that node to our current node
      node.profile = _findMin(node.right!).profile;

      // Now we need to delete the node we found in _findMin
      // so we start looking from right subtree, the node with the name with the same name as our current node
      node.right = _removeRec(node.right, node.profile.name.toLowerCase());
    }
    return node;
  }

  // Helper to find the smallest node in a subtree
  BSTNode _findMin(BSTNode node) {
    BSTNode current = node;
    // You simply go as left as possible til before hitting null
    while (current.left != null) {
      current = current.left!;
    }
    // return the current node which is the minimum
    return current;
  }
}