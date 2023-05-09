import 'package:flutter/material.dart';
import 'package:furdle/exports.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/game_state.dart';
import 'package:furdle/models/puzzle.dart';

enum KeyState {
  /// letter is present in the right spot
  exists,

  /// letter is not present in any spot
  notExists,

  /// letter is present in the wrong spot
  misplaced,

  /// letter is empty
  isDefault
}

class Furdle extends StatefulWidget {
  Furdle({Key? key, required this.gameState, this.onGameOver})
      : super(key: key);

  /// state of the game
  GameState gameState;

  /// callback when the game is over with the puzzle
  /// details as the parameter
  final Function(Puzzle)? onGameOver;

  @override
  State<Furdle> createState() => _FurdleState();
}

class _FurdleState extends State<Furdle> {
  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  @override
  void didUpdateWidget(covariant Furdle oldWidget) {
    if (oldWidget.gameState != widget.gameState) {
      super.didUpdateWidget(oldWidget);
    }
  }

  void _initGrid() {
    Puzzle lastFurdle = settingsController.stats.puzzle;
    if (lastFurdle.moves > 0) {
      widget.gameState.cells.clear();
      widget.gameState.cells = lastFurdle.cells;
      widget.gameState.puzzle = lastFurdle;
    } else {
      final _gridSize = widget.gameState.puzzle.size;
      for (int i = 0; i < _gridSize.height; i++) {
        List<FCellState> row = [];
        for (int j = 0; j < _gridSize.width; j++) {
          row.add(FCellState.defaultState());
        }
        widget.gameState.cells.add(row);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FurdleGrid(
      state: widget.gameState,
    );
  }
}

class FurdleGrid extends StatelessWidget {
  FurdleGrid({Key? key, required this.state}) : super(key: key);

  final GameState state;
  double cellSize = 80;

  Size? gridSize;
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    gridSize = state.puzzle.size;
    bool isPlayed = state.puzzle.moves > 0;
    bool isGameOver = state.puzzle.result != PuzzleResult.inprogress;
    cellSize = _size.width < 600 ? 65 : 80;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            for (int i = 0; i < gridSize!.height; i++)
              Row(
                children: [
                  for (int j = 0; j < gridSize!.width; j++)
                    FurdleCell(
                      i: i,
                      j: j,
                      cellSize: cellSize,
                      cellState: state.cells[i][j],
                      isSubmitted: isGameOver ? i <= state.row : i < state.row,
                      isAlreadyPlayed: isPlayed,
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class FurdleCell extends StatefulWidget {
  final int i;
  final int j;
  final double cellSize;
  FCellState? cellState;

  /// whether or not a word is submitted
  /// if true it will show the colors
  /// of the submitted word
  bool isSubmitted = false;
  bool isAlreadyPlayed = false;

  FurdleCell(
      {Key? key,
      required this.i,
      required this.j,
      this.cellState,
      this.isSubmitted = false,
      this.isAlreadyPlayed = false,
      this.cellSize = 80})
      : super(key: key);

  @override
  State<FurdleCell> createState() => _FurdleCellState();
}

class _FurdleCellState extends State<FurdleCell>
    with SingleTickerProviderStateMixin {
  Color stateToColor(KeyState state, bool isSubmitted) {
    if (!isSubmitted) {
      return Colors.grey;
    }
    switch (state) {
      case KeyState.exists:
        return green;
      case KeyState.notExists:
        return black;
      case KeyState.misplaced:
        return yellow;
      case KeyState.isDefault:
        return grey;
    }
  }

  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceIn,
    ));
    if (widget.isAlreadyPlayed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant FurdleCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cellState != oldWidget.cellState) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.cellState ??= FCellState.defaultState();
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Container(
              width: widget.cellSize,
              height: widget.cellSize,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color:
                      stateToColor(widget.cellState!.state, widget.isSubmitted),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(
                widget.cellState!.character.toUpperCase(),
                style: TextStyle(
                    fontSize: widget.cellSize * 0.4 * _animation.value,
                    color: Colors.white),
              ));
        });
  }
}