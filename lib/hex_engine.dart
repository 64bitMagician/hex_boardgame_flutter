import 'disjoint_set.dart';

// [Documentation State: ___]

enum Player { none, red, blue }

class HexEngine {
  final int boardSize;
  late List<Player> board;

  late DisjointSet redSet;
  late DisjointSet blueSet;

  late final int virtualTop;
  late final int virtualBottom;
  late final int virtualLeft;
  late final int virtualRight;

  HexEngine({this.boardSize = 11}) {
    int totalCells = boardSize * boardSize;
    board = List<Player>.filled(totalCells, Player.none);

    virtualTop = totalCells;
    virtualBottom = totalCells + 1;
    virtualLeft = totalCells;
    virtualRight = totalCells + 1;

    redSet = DisjointSet(totalCells + 2);
    blueSet = DisjointSet(totalCells + 2);
  }

  int _get1DIndex(int row, int col) => row * boardSize + col;

  bool makeMove(int row, int col, Player player) {
    int index = _get1DIndex(row, col);
    if (board[index] != Player.none) return false;

    board[index] = player;
    _connectNeighbors(row, col, player);
    return true;
  }

  void _connectNeighbors(int row, int col, Player player) {
    int currentIndex = _get1DIndex(row, col);
    DisjointSet targetSet = (player == Player.red) ? redSet : blueSet;

    if (player == Player.red) {
      if (row == 0) targetSet.union(currentIndex, virtualTop);
      if (row == boardSize - 1) targetSet.union(currentIndex, virtualBottom);
    } else if (player == Player.blue) {
      if (col == 0) targetSet.union(currentIndex, virtualLeft);
      if (col == boardSize - 1) targetSet.union(currentIndex, virtualRight);
    }

    List<List<int>> neighbors = [
      [row - 1, col], [row - 1, col + 1],
      [row, col - 1],                 [row, col + 1],
      [row + 1, col - 1], [row + 1, col]
    ];

    for (var neighbor in neighbors) {
      int nRow = neighbor[0];
      int nCol = neighbor[1];

      if (nRow >= 0 && nRow < boardSize && nCol >= 0 && nCol < boardSize) {
        int neighborIndex = _get1DIndex(nRow, nCol);
        if (board[neighborIndex] == player) {
          targetSet.union(currentIndex, neighborIndex);
        }
      }
    }
  }

  bool checkWin(Player player) {
    if (player == Player.red) {
      return redSet.find(virtualTop) == redSet.find(virtualBottom);
    } else if (player == Player.blue) {
      return blueSet.find(virtualLeft) == blueSet.find(virtualRight);
    }
    return false;
  }
}