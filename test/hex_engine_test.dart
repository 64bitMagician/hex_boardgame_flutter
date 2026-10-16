import 'package:flutter_test/flutter_test.dart';
import 'package:hex_boardgame_flutter/hex_engine.dart';

void main() {
  group('HexEngine moves', () {
    test('new board is empty', () {
      final engine = HexEngine(boardSize: 5);
      expect(engine.board.length, 25);
      expect(engine.board.every((cell) => cell == Player.none), isTrue);
    });

    test('makeMove claims an empty cell', () {
      final engine = HexEngine(boardSize: 5);
      expect(engine.makeMove(2, 3, Player.red), isTrue);
      expect(engine.board[2 * 5 + 3], Player.red);
    });

    test('makeMove rejects an occupied cell', () {
      final engine = HexEngine(boardSize: 5);
      engine.makeMove(1, 1, Player.red);
      expect(engine.makeMove(1, 1, Player.blue), isFalse);
      expect(engine.makeMove(1, 1, Player.red), isFalse);
      expect(engine.board[1 * 5 + 1], Player.red);
    });
  });

  group('HexEngine win detection', () {
    test('nobody has won on an empty board', () {
      final engine = HexEngine(boardSize: 5);
      expect(engine.checkWin(Player.red), isFalse);
      expect(engine.checkWin(Player.blue), isFalse);
      expect(engine.checkWin(Player.none), isFalse);
    });

    test('red wins with a straight top-to-bottom column', () {
      final engine = HexEngine(boardSize: 5);
      for (int r = 0; r < 4; r++) {
        engine.makeMove(r, 2, Player.red);
        expect(engine.checkWin(Player.red), isFalse);
      }
      engine.makeMove(4, 2, Player.red);
      expect(engine.checkWin(Player.red), isTrue);
      expect(engine.checkWin(Player.blue), isFalse);
    });

    test('blue wins with a straight left-to-right row', () {
      final engine = HexEngine(boardSize: 5);
      for (int c = 0; c < 5; c++) {
        engine.makeMove(3, c, Player.blue);
      }
      expect(engine.checkWin(Player.blue), isTrue);
      expect(engine.checkWin(Player.red), isFalse);
    });

    test('red cannot win by connecting left to right', () {
      final engine = HexEngine(boardSize: 5);
      for (int c = 0; c < 5; c++) {
        engine.makeMove(2, c, Player.red);
      }
      expect(engine.checkWin(Player.red), isFalse);
    });

    test('win along the diagonal uses the (r+1, c-1) neighbour', () {
      // On a Hex rhombus, (r, c) and (r+1, c-1) are adjacent
      final engine = HexEngine(boardSize: 4);
      engine.makeMove(0, 3, Player.red);
      engine.makeMove(1, 2, Player.red);
      engine.makeMove(2, 1, Player.red);
      engine.makeMove(3, 0, Player.red);
      expect(engine.checkWin(Player.red), isTrue);
    });

    test('cells on the (r+1, c+1) diagonal are not adjacent', () {
      final engine = HexEngine(boardSize: 4);
      engine.makeMove(0, 0, Player.red);
      engine.makeMove(1, 1, Player.red);
      engine.makeMove(2, 2, Player.red);
      engine.makeMove(3, 3, Player.red);
      expect(engine.checkWin(Player.red), isFalse);
    });

    test('opponent stones break a chain', () {
      final engine = HexEngine(boardSize: 3);
      engine.makeMove(0, 1, Player.red);
      engine.makeMove(1, 1, Player.blue);
      engine.makeMove(2, 1, Player.red);
      expect(engine.checkWin(Player.red), isFalse);
    });

    test('a winning chain can be completed out of order', () {
      final engine = HexEngine(boardSize: 3);
      engine.makeMove(0, 0, Player.blue);
      engine.makeMove(0, 2, Player.blue);
      expect(engine.checkWin(Player.blue), isFalse);
      engine.makeMove(0, 1, Player.blue); // joins two separate components
      expect(engine.checkWin(Player.blue), isTrue);
    });

    test('a winding path counts as a win', () {
      final engine = HexEngine(boardSize: 4);
      // Red snakes right, then down, then left
      for (final move in [
        [0, 0], [1, 0], [1, 1], [1, 2], [2, 2], [2, 1], [3, 0],
      ]) {
        engine.makeMove(move[0], move[1], Player.red);
      }
      expect(engine.checkWin(Player.red), isTrue);
    });
  });
}
