import 'disjoint_set.dart';

// [Documentation State: FINISHED]

enum Player { none, red, blue }

///
class HexEngine {
  // The board is a 'square' grid. It has as many hexes on vertical edge as it has on horizontal edge.
  // So you can consider 'boardSize' to be = how many hexes are on a row/column
  final int boardSize;
  // 'board' represents each hex indexed in order. For each Hex there is a Player associated with it:
  // It is either 'none', 'red' or 'blue' Player
  late List<Player> board;

  late DisjointSet redSet;
  late DisjointSet blueSet;

  late final int virtualTopRED;
  late final int virtualBottomRED;
  late final int virtualLeftBLUE;
  late final int virtualRightBLUE;

  HexEngine({this.boardSize = 11}) {
    int totalCells = boardSize * boardSize;
    board = List<Player>.filled(totalCells, Player.none);

    // store the index position of the virtual nodes
    // virtual nodes are not used in the List<Player> board object
    // they are used only in the DisjointSet objects (hence the +2 at their instantiation)
    // Red's Set contains the virtual top and bottom nodes
    // Blue's Set contains the virtual Left and Right Nodes
    virtualTopRED = totalCells;
    virtualBottomRED = totalCells + 1;
    virtualLeftBLUE = totalCells;
    virtualRightBLUE = totalCells + 1;

    // We create two separate DisjointSet entities
    // One for red and one for blue
    // + 2 number of nodes because it also includes the virtual nodes here
    redSet = DisjointSet(totalCells + 2);
    blueSet = DisjointSet(totalCells + 2);
  }

  // get the index of the hex at given row and column
  int _getHexIndex(int row, int col) => row * boardSize + col;

  /// Make the move (assign your color to the selected hex) as the given player, on the hex at the given row and column.
  /// EX: makeMove(3,4,Player.blue) will make Player blue mark the hex at row 3 and column 4...
  bool makeMove(int row, int col, Player player) {
    // get the index of the corresponding hex
    int index = _getHexIndex(row, col);

    // check if hex is already assigned. We do not want to overwrite it!!!
    if (board[index] != Player.none) return false; // mark that the move failed

    // associate the hex on the poard with the given player
    board[index] = player;
    //
    _connectNeighbors(row, col, player);
    // mark that the move succedeed
    return true;
  }

  // After placing the marker, connect with any surrouning markers of the same color
  // This means performing Union with the Component of the Neighbor Hex
  void _connectNeighbors(int row, int col, Player player) {
    // Get index of hex at given row and column
    int currentIndex = _getHexIndex(row, col);
    // fetch the DisjointSet corresponding to the given Player
    DisjointSet targetSet = (player == Player.red) ? redSet : blueSet;

    // if the Red Player
    if (player == Player.red) {
      if (row == 0) // if the selected hex is at row 0 (top edge)
        targetSet.union(currentIndex, virtualTopRED); // perform union of current Hex and the virtualTopRED Hex | union with mother component
      if (row == boardSize - 1) // if the selected hex is at last row (bottom edge)
        targetSet.union(currentIndex, virtualBottomRED); // perform union of current Hex and the virtualBottomRED Hex | union with mother component
    } else if (player == Player.blue) { // if the Blue Player
      if (col == 0)  // if the selected hex is at column 0 (leftmost edge)
        targetSet.union(currentIndex, virtualLeftBLUE); // perform union of current Hex and the virtualLeftBLUE Hex | union with mother component
      if (col == boardSize - 1) // if the selected hex is at last column (rightmost edge)
        targetSet.union(currentIndex, virtualRightBLUE); // perform union of current Hex and the virtualRightBLUE Hex | union with mother component
    }

    // Get the coordinates of the neighbors from the surrounding hexes
    List<List<int>> neighbors = [
            [row - 1, col],     [row - 1, col + 1],
      [row, col - 1],                       [row, col + 1],
            [row + 1, col - 1], [row + 1, col]
    ];

    // now we iterate each neighbor of our selected hex
    for (var neighbor in neighbors) {
      int neighbor_row_coordinate = neighbor[0];
      int neighbor_column_coordinate = neighbor[1];

      if (neighbor_row_coordinate >= 0 && neighbor_row_coordinate < boardSize && // if within the row limits of physical board
          neighbor_column_coordinate >= 0 && neighbor_column_coordinate < boardSize) { // if within column limits of physical board
        int neighborHexIndex = _getHexIndex(neighbor_row_coordinate, neighbor_column_coordinate); // get the hex index of the neighbor
        if (board[neighborHexIndex] == player) { // if the neighbor hex already belongs to our player
          // perform union between neighbor and current hex
          // unite components into one
          // Note: In our hex implementation it will be impossible to form cycles because you cannot re-click on an already
          // marked hex, even if it is of the same color. There 'path' is not even stored, all hexes point to a single root node
          // such that it marks that they belong to the same component/are_connected.
          targetSet.union(currentIndex, neighborHexIndex);
        }
      }
    }
  }

  /// Check wether the given player has won by checking their corresponding virtual
  /// nodes to belong to the same component.
  bool checkWin(Player player) {
    if (player == Player.red) {
      return redSet.find(virtualTopRED) == redSet.find(virtualBottomRED); // check if RED virtual nodes belong to the same component ==results==> win
    } else if (player == Player.blue) {
      return blueSet.find(virtualLeftBLUE) == blueSet.find(virtualRightBLUE); // check if BLUE virtual nodes belong to the same component ==results==> win
    }
    return false; // no win
  }
}