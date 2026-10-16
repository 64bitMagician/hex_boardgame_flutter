import 'package:flutter_test/flutter_test.dart';
import 'package:hex_boardgame_flutter/disjoint_set.dart';

void main() {
  group('DisjointSet', () {
    test('every element starts as its own root', () {
      final ds = DisjointSet(5);
      for (int i = 0; i < 5; i++) {
        expect(ds.find(i), i);
      }
    });

    test('union connects two elements', () {
      final ds = DisjointSet(5);
      ds.union(0, 1);
      expect(ds.find(0), ds.find(1));
      expect(ds.find(2), isNot(ds.find(0)));
    });

    test('connectivity is transitive across unions', () {
      final ds = DisjointSet(6);
      ds.union(0, 1);
      ds.union(2, 3);
      expect(ds.find(1), isNot(ds.find(2)));

      ds.union(1, 2);
      expect(ds.find(0), ds.find(3));
    });

    test('union of already connected elements is a no-op', () {
      final ds = DisjointSet(3);
      ds.union(0, 1);
      final rootBefore = ds.find(0);
      final rankBefore = ds.rank[rootBefore];

      ds.union(1, 0);
      expect(ds.find(0), rootBefore);
      expect(ds.rank[rootBefore], rankBefore);
    });

    test('union by rank attaches the shorter tree under the taller one', () {
      final ds = DisjointSet(4);
      ds.union(0, 1); // root 0, rank 1
      ds.union(0, 2); // 2 (rank 0) goes under 0
      expect(ds.find(2), 0);
      expect(ds.rank[0], 1);

      ds.union(3, 0); // 3 (rank 0) goes under 0, even though it initiated
      expect(ds.find(3), 0);
    });

    test('find applies path compression', () {
      final ds = DisjointSet(4);
      // Build the chain 3 -> 2 -> 0 by hand to force a deep path
      ds.parent[3] = 2;
      ds.parent[2] = 0;

      expect(ds.find(3), 0);
      expect(ds.parent[3], 0);
    });
  });
}
