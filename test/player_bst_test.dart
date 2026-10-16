import 'package:flutter_test/flutter_test.dart';
import 'package:hex_boardgame_flutter/player_bst.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns the names in the tree in in-order (alphabetical) order.
List<String> names(PlayerBST bst) =>
    bst.getAllPlayersAlphabetically().map((p) => p.name).toList();

/// Height of the tree; an empty tree has height 0.
int height(BSTNode? node) {
  if (node == null) return 0;
  final l = height(node.left);
  final r = height(node.right);
  return 1 + (l > r ? l : r);
}

PlayerBST bstWith(List<String> playerNames) {
  final bst = PlayerBST();
  for (final name in playerNames) {
    bst.insert(PlayerProfile(name: name));
  }
  return bst;
}

void main() {
  group('PlayerProfile', () {
    test('defaults wins and losses to zero', () {
      final p = PlayerProfile(name: 'Alice');
      expect(p.wins, 0);
      expect(p.losses, 0);
    });

    test('round-trips through JSON', () {
      final original = PlayerProfile(name: 'Bob', wins: 7, losses: 3);
      final copy = PlayerProfile.fromJson(original.toJson());
      expect(copy.name, 'Bob');
      expect(copy.wins, 7);
      expect(copy.losses, 3);
    });
  });

  group('PlayerBST insert and traversal', () {
    test('empty tree returns no players', () {
      expect(PlayerBST().getAllPlayersAlphabetically(), isEmpty);
    });

    test('in-order traversal is alphabetical', () {
      final bst = bstWith(['Mia', 'Charlie', 'Zoe', 'Alice', 'Noah']);
      expect(names(bst), ['Alice', 'Charlie', 'Mia', 'Noah', 'Zoe']);
    });

    test('ordering ignores case', () {
      final bst = bstWith(['bob', 'Alice', 'charlie']);
      expect(names(bst), ['Alice', 'bob', 'charlie']);
    });

    test('duplicate names (any case) are ignored', () {
      final bst = bstWith(['Alice', 'alice', 'ALICE']);
      expect(names(bst), ['Alice']);
    });
  });

  group('PlayerBST search', () {
    final bst = bstWith(['Mia', 'Charlie', 'Zoe', 'Alice', 'Chloe']);

    test('finds an existing player case-insensitively', () {
      expect(bst.search('mia')?.name, 'Mia');
      expect(bst.search('ZOE')?.name, 'Zoe');
    });

    test('returns null for a missing player', () {
      expect(bst.search('Nobody'), isNull);
      expect(PlayerBST().search('Alice'), isNull);
    });

    test('prefix search returns matches alphabetically', () {
      expect(bst.searchByPrefix('ch').map((p) => p.name), ['Charlie', 'Chloe']);
      expect(bst.searchByPrefix('x'), isEmpty);
    });

    test('empty prefix returns every player', () {
      expect(bst.searchByPrefix('').length, 5);
    });
  });

  group('PlayerBST remove', () {
    test('removes a leaf', () {
      final bst = bstWith(['Mia', 'Charlie', 'Zoe']);
      bst.remove('Zoe');
      expect(names(bst), ['Charlie', 'Mia']);
    });

    test('removes a node with one child', () {
      final bst = bstWith(['Mia', 'Charlie', 'Alice']);
      bst.remove('Charlie');
      expect(names(bst), ['Alice', 'Mia']);
      expect(bst.root!.left!.profile.name, 'Alice');
    });

    test('removes a node with two children using the in-order successor', () {
      final bst = bstWith(['Mia', 'Charlie', 'Zoe', 'Noah', 'Zane']);
      bst.remove('Mia');
      expect(bst.root!.profile.name, 'Noah');
      expect(names(bst), ['Charlie', 'Noah', 'Zane', 'Zoe']);
    });

    test('removes the only node', () {
      final bst = bstWith(['Alice']);
      bst.remove('alice');
      expect(bst.root, isNull);
    });

    test('removing a missing name leaves the tree unchanged', () {
      final bst = bstWith(['Mia', 'Charlie', 'Zoe']);
      bst.remove('Nobody');
      expect(names(bst), ['Charlie', 'Mia', 'Zoe']);
    });
  });

  group('PlayerBST persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('save then load restores every profile with stats', () async {
      final bst = PlayerBST()
        ..insert(PlayerProfile(name: 'Mia', wins: 4, losses: 1))
        ..insert(PlayerProfile(name: 'Alice', wins: 2, losses: 9));
      await bst.saveTreeToStorage();

      final loaded = PlayerBST();
      await loaded.loadTreeFromStorage();
      expect(names(loaded), ['Alice', 'Mia']);
      expect(loaded.search('Mia')!.wins, 4);
      expect(loaded.search('Alice')!.losses, 9);
    });

    test('loading rebuilds a height-balanced tree', () async {
      // Inserting in sorted order produces a degenerate, list-like tree
      final degenerate = PlayerBST();
      for (int i = 0; i < 31; i++) {
        degenerate.insert(PlayerProfile(name: 'player${i.toString().padLeft(2, '0')}'));
      }
      expect(height(degenerate.root), 31);
      await degenerate.saveTreeToStorage();

      final loaded = PlayerBST();
      await loaded.loadTreeFromStorage();
      expect(height(loaded.root), 5); // log2(32)
      expect(names(loaded), names(degenerate));
    });

    test('loading with no stored data leaves the tree empty', () async {
      final bst = PlayerBST();
      await bst.loadTreeFromStorage();
      expect(bst.root, isNull);
    });

    for (final corrupted in {
      'invalid JSON': '{not json',
      'not a list': '{"name": "Alice"}',
      'missing fields': '[{"name": "Alice"}]',
      'wrong types': '[{"name": 42, "wins": "lots", "losses": null}]',
    }.entries) {
      test('corrupted data (${corrupted.key}) falls back to an empty tree', () async {
        SharedPreferences.setMockInitialValues({'hex_players_data': corrupted.value});
        final bst = PlayerBST();
        await bst.loadTreeFromStorage();
        expect(bst.root, isNull);
      });
    }

    test('saving after a corrupted load overwrites the bad data', () async {
      SharedPreferences.setMockInitialValues({'hex_players_data': '{not json'});
      final bst = PlayerBST();
      await bst.loadTreeFromStorage();
      bst.insert(PlayerProfile(name: 'Alice', wins: 1));
      await bst.saveTreeToStorage();

      final reloaded = PlayerBST();
      await reloaded.loadTreeFromStorage();
      expect(names(reloaded), ['Alice']);
    });
  });
}
