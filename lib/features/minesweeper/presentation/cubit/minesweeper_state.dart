import 'package:equatable/equatable.dart';

class CellData extends Equatable {
  final int x;
  final int y;
  final bool hasMine;
  final bool isRevealed;
  final bool isFlagged;
  final int neighborMines;

  const CellData({
    required this.x,
    required this.y,
    this.hasMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.neighborMines = 0,
  });

  CellData copyWith({
    bool? hasMine,
    bool? isRevealed,
    bool? isFlagged,
    int? neighborMines,
  }) {
    return CellData(
      x: x,
      y: y,
      hasMine: hasMine ?? this.hasMine,
      isRevealed: isRevealed ?? this.isRevealed,
      isFlagged: isFlagged ?? this.isFlagged,
      neighborMines: neighborMines ?? this.neighborMines,
    );
  }

  @override
  List<Object?> get props => [x, y, hasMine, isRevealed, isFlagged, neighborMines];
}

abstract class MinesweeperState extends Equatable {
  final List<List<CellData>> board;
  final int secondsElapsed;
  final int? bestTime;

  const MinesweeperState({
    required this.board,
    this.secondsElapsed = 0,
    this.bestTime,
  });

  @override
  List<Object?> get props => [board, secondsElapsed, bestTime];
}

class MinesweeperInitial extends MinesweeperState {
  final int columns;
  final int rows;
  final int minesCount;

  const MinesweeperInitial({
    required super.board,
    required this.columns,
    required this.rows,
    required this.minesCount,
    super.secondsElapsed,
    super.bestTime,
  });

  MinesweeperInitial copyWith({
    List<List<CellData>>? board,
    int? columns,
    int? rows,
    int? minesCount,
    int? secondsElapsed,
    int? bestTime,
  }) {
    return MinesweeperInitial(
      board: board ?? this.board,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      minesCount: minesCount ?? this.minesCount,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      bestTime: bestTime ?? this.bestTime,
    );
  }

  @override
  List<Object?> get props => [board, columns, rows, minesCount, secondsElapsed, bestTime];
}

class MinesweeperGameOver extends MinesweeperState {
  final bool isWon;

  const MinesweeperGameOver({
    required super.board,
    required this.isWon,
    super.secondsElapsed,
    super.bestTime,
  });

  @override
  List<Object?> get props => [board, isWon, secondsElapsed, bestTime];
}
