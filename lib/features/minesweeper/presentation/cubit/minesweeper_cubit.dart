import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'minesweeper_state.dart';

class MinesweeperCubit extends Cubit<MinesweeperState> {
  int _currentRows = 10;
  int _currentColumns = 10;
  int _currentMines = 10;
  Timer? _timer;
  bool _isFirstClick = true;

  MinesweeperCubit()
      : super(MinesweeperInitial(
          board: _generateEmptyBoard(10, 10),
          columns: 10,
          rows: 10,
          minesCount: 10,
        )) {
    _loadBestTime();
  }

  Future<void> _loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'minesweeper_best_${_currentRows}_${_currentColumns}_$_currentMines';
    final best = prefs.getInt(key);
    if (state is MinesweeperInitial) {
      emit((state as MinesweeperInitial).copyWith(bestTime: best));
    }
  }

  Future<void> _saveBestTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'minesweeper_best_${_currentRows}_${_currentColumns}_$_currentMines';
    final currentBest = prefs.getInt(key);
    if (currentBest == null || time < currentBest) {
      await prefs.setInt(key, time);
      if (state is MinesweeperGameOver) {
        emit(MinesweeperGameOver(
          board: state.board,
          isWon: true,
          secondsElapsed: state.secondsElapsed,
          bestTime: time,
        ));
      }
    }
  }

  void initGame({int? rows, int? columns, int? mines}) {
    _stopTimer();
    _isFirstClick = true;
    
    if (rows != null) _currentRows = rows;
    if (columns != null) _currentColumns = columns;
    
    // Constraint: Mines cannot exceed 50% of total cells
    final int totalCells = _currentRows * _currentColumns;
    final int maxMines = (totalCells * 0.5).floor();
    
    if (mines != null) {
      _currentMines = mines > maxMines ? maxMines : mines;
    } else if (_currentMines > maxMines) {
      _currentMines = maxMines;
    }

    final board = _generateEmptyBoard(_currentRows, _currentColumns);
    _placeMines(board, _currentRows, _currentColumns, _currentMines);
    _calculateNeighborMines(board, _currentRows, _currentColumns);
    
    emit(MinesweeperInitial(
      board: board,
      columns: _currentColumns,
      rows: _currentRows,
      minesCount: _currentMines,
      secondsElapsed: 0,
    ));
    _loadBestTime();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is MinesweeperInitial) {
        final s = state as MinesweeperInitial;
        emit(s.copyWith(secondsElapsed: s.secondsElapsed + 1));
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void toggleFlag(int x, int y) {
    if (state is! MinesweeperInitial) return;
    final currentState = state as MinesweeperInitial;
    final board = _cloneBoard(currentState.board);
    
    if (board[y][x].isRevealed) return;
    
    board[y][x] = board[y][x].copyWith(isFlagged: !board[y][x].isFlagged);
    
    emit(currentState.copyWith(board: board));
  }

  void revealCell(int x, int y) {
    if (state is! MinesweeperInitial) return;
    final currentState = state as MinesweeperInitial;
    final board = _cloneBoard(currentState.board);
    final cell = board[y][x];

    if (cell.isRevealed || cell.isFlagged) return;

    if (_isFirstClick) {
      _isFirstClick = false;
      _startTimer();
    }

    if (cell.hasMine) {
      _stopTimer();
      _revealAllMines(board);
      emit(MinesweeperGameOver(
        board: board,
        isWon: false,
        secondsElapsed: currentState.secondsElapsed,
        bestTime: currentState.bestTime,
      ));
      return;
    }

    _revealRecursive(board, x, y);

    if (_checkWin(board)) {
      _stopTimer();
      _revealAllMines(board);
      _saveBestTime(currentState.secondsElapsed);
      emit(MinesweeperGameOver(
        board: board,
        isWon: true,
        secondsElapsed: currentState.secondsElapsed,
        bestTime: currentState.bestTime,
      ));
    } else {
      emit(currentState.copyWith(board: board));
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }

  void _revealRecursive(List<List<CellData>> board, int x, int y) {
    if (x < 0 || x >= _currentColumns || y < 0 || y >= _currentRows) return;
    final cell = board[y][x];
    if (cell.isRevealed || cell.isFlagged || cell.hasMine) return;

    board[y][x] = board[y][x].copyWith(isRevealed: true);

    if (cell.neighborMines == 0) {
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          if (dx == 0 && dy == 0) continue;
          _revealRecursive(board, x + dx, y + dy);
        }
      }
    }
  }

  void _placeMines(List<List<CellData>> board, int r, int c, int m) {
    final random = Random();
    int placed = 0;
    while (placed < m) {
      int x = random.nextInt(c);
      int y = random.nextInt(r);
      if (!board[y][x].hasMine) {
        board[y][x] = board[y][x].copyWith(hasMine: true);
        placed++;
      }
    }
  }

  void _calculateNeighborMines(List<List<CellData>> board, int r, int c) {
    for (int y = 0; y < r; y++) {
      for (int x = 0; x < c; x++) {
        if (board[y][x].hasMine) continue;
        int count = 0;
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            int nx = x + dx;
            int ny = y + dy;
            if (nx >= 0 && nx < c && ny >= 0 && ny < r) {
              if (board[ny][nx].hasMine) count++;
            }
          }
        }
        board[y][x] = board[y][x].copyWith(neighborMines: count);
      }
    }
  }

  bool _checkWin(List<List<CellData>> board) {
    int unrevealedCount = 0;
    for (var row in board) {
      for (var cell in row) {
        if (!cell.isRevealed) unrevealedCount++;
      }
    }
    return unrevealedCount == _currentMines;
  }

  void _revealAllMines(List<List<CellData>> board) {
    for (int y = 0; y < _currentRows; y++) {
      for (int x = 0; x < _currentColumns; x++) {
        if (board[y][x].hasMine) {
          board[y][x] = board[y][x].copyWith(isRevealed: true);
        }
      }
    }
  }

  List<List<CellData>> _cloneBoard(List<List<CellData>> original) {
    return original.map((row) => List<CellData>.from(row)).toList();
  }

  static List<List<CellData>> _generateEmptyBoard(int r, int c) {
    return List.generate(
      r,
      (y) => List.generate(
        c,
        (x) => CellData(x: x, y: y),
      ),
    );
  }
}
