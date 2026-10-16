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
  // so each component has a root. The rank of the root means the level of 'weight' that component has...
  // in short, if the rank is higher for the root/component, then it has more nodes within it's component
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
    int rootI = find(i); // find the root from where 'i' lives, also apply Path Compression
    int rootJ = find(j); // find the root from where 'j' lives, also apply Path Compression

    // If the two elements are within different sets (different Graphs):
    // We connect the two sets/graphs, and decrement the counter of connected components
    if (rootI != rootJ) {
      if (rank[rootI] < rank[rootJ]) { // if rank greater in root of graph 'j'
        parent[rootI] = rootJ; // the root of graph of 'j' becomes direct parent for root of graph of 'i'
      } else if (rank[rootI] > rank[rootJ]) { // if rank greater in root of graph 'i'
        parent[rootJ] = rootI; // the root of graph of 'i' becomes direct parent for root of graph of 'j'
      } else { // if ranks are equal
        parent[rootJ] = rootI; // the root of graph of 'i' becomes direct parent for root of graph of 'j'
        rank[rootI]++; // increase rank if trees were the same height
      }
    }
  }

  //Side Note: If two merging components have the same rank, the root node of the resulted component will always be the mark
  // that initiates the connection/union
}