// [Documentation State: FINISHED]

/// This class represents the array representation of a group of disjoint sets with '[size]' number of nodes.
class DisjointSet {
  // this is the parent array: [4] [6] [0] [8] ... [42] where each node is represented by its index
  // and the value at that index position represents the parent of that node.
  // EX: Parent of node:  0 is 4
  //                      1 is 6
  //                      3 is 0
  //                      4 is 8
  //                      .......
  //                      n is 42
  final List<int> parent;
  // the rank is refering only to root nodes. For other notes than root, the rank is not valid
  // the rank means how many times an other component has been appended to the component which corresponds to the root in question
  final List<int> rank;

  /// Constructor. Also initializes the:
  ///
  /// [parent] array, with the given [size]. It is generated as a [List] of [int] types, where
  /// each element at given index represents the value of the index itself. Ex: parent[4] == 4.
  ///
  /// [rank] array. the rank is referring only to root nodes. For other nodes than root, the rank is not valid.
  /// The rank means how many times an other component has been appended to the component which corresponds to the root in question.
  DisjointSet(int size)
      : parent = List<int>.generate(size, (index) => index),
        rank = List<int>.filled(size, 0);

  /// If we pass element 'i', we will get the root of the set/tree from where 'i' belongs
  /// As a side effect of the implementation:
  /// Eventually, this will make it so all elements on that one-parent path will point
  /// to the root of the path/tree
  int find(int i) {
    if (parent[i] == i) {
      return i;
    }
    parent[i] = find(parent[i]);
    return parent[i];
  }

  /// Unite the sets containing 'i' and 'j', using Union by Rank
  void union(int i, int j) {
    int root_i = find(i); // find the root from where 'i' lives, also apply Path Compression
    int root_j = find(j); // find the root from where 'j' lives, also apply Path Compression

    // If the two elements are within different sets (different Graphs):
    // We connect the two sets/graphs, and decrement the counter of connected components
    if (root_i != root_j) {
      if (rank[root_i] < rank[root_j]) { // if rank greater in root of graph 'j'
        parent[root_i] = root_j; // the root of graph of 'j' becomes direct parent for root of graph of 'i'
      } else if (rank[root_i] > rank[root_j]) { // if rank greater in root of graph 'i'
        parent[root_j] = root_i; // the root of graph of 'i' becomes direct parent for root of graph of 'j'
      } else { // if ranks are equal
        parent[root_j] = root_i; // the root of graph of 'i' becomes direct parent for root of graph of 'j'
        rank[root_i]++; // increase rank if trees were the same height
      }
    }
  }
}