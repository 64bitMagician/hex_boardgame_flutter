// [Documentation State: ___]

class DisjointSet {
  final List<int> parent;
  final List<int> rank;

  DisjointSet(int size)
      : parent = List<int>.generate(size, (index) => index),
        rank = List<int>.filled(size, 0);

  int find(int i) {
    if (parent[i] == i) {
      return i;
    }
    parent[i] = find(parent[i]);
    return parent[i];
  }

  void union(int i, int j) {
    int rootI = find(i);
    int rootJ = find(j);

    if (rootI != rootJ) {
      if (rank[rootI] < rank[rootJ]) {
        parent[rootI] = rootJ;
      } else if (rank[rootI] > rank[rootJ]) {
        parent[rootJ] = rootI;
      } else {
        parent[rootJ] = rootI;
        rank[rootI]++;
      }
    }
  }
}