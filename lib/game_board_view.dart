import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'hex_engine.dart';
import 'hexagon_widget.dart';

class GameBoardView extends StatelessWidget {
  final HexEngine engine;
  final double hexRadius;
  final Function(TapDownDetails) onBoardTap;

  const GameBoardView({
    Key? key,
    required this.engine,
    required this.hexRadius,
    required this.onBoardTap,
  }) : super(key: key);

  Color _getCellColor(Player player) {
    switch (player) {
      case Player.red: return Colors.red.withOpacity(0.8);
      case Player.blue: return Colors.blue.withOpacity(0.8);
      case Player.none: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = hexRadius;
    final double w = math.sqrt(3) * h;
    final double boardWidth = (engine.boardSize * w) + ((engine.boardSize - 1) * w / 2) + w;
    final double boardHeight = ((engine.boardSize - 1) * 1.5 * h) + (2 * h);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: boardWidth,
            height: boardHeight,
            color: Colors.transparent,
            child: GestureDetector(
              onTapDown: onBoardTap,
              child: Stack(
                children: List.generate(engine.boardSize * engine.boardSize, (i) {
                  final int row = i ~/ engine.boardSize;
                  final int col = i % engine.boardSize;

                  final double xPos = (col * w) + (row * w / 2) + w / 2;
                  final double yPos = (row * 1.5 * h) + h;

                  return Positioned(
                    left: xPos - w / 2,
                    top: yPos - h,
                    child: HexagonWidget(
                        size: hexRadius,
                        color: _getCellColor(engine.board[i]),
                        child: null
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}