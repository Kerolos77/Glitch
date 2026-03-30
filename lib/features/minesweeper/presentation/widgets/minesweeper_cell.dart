import 'package:flutter/material.dart';
import '../cubit/minesweeper_state.dart';

class MinesweeperCell extends StatelessWidget {
  final CellData cell;
  final VoidCallback onReveal;
  final VoidCallback onFlag;

  const MinesweeperCell({
    super.key,
    required this.cell,
    required this.onReveal,
    required this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onReveal,
      onSecondaryTap: onFlag,
      onLongPress: onFlag,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _getCellColor(context),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: cell.isRevealed 
                ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
                : (isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.1)),
            width: 1,
          ),
          boxShadow: cell.isRevealed
              ? null
              : [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black12,
                    offset: const Offset(1, 1),
                    blurRadius: 1,
                  ),
                ],
        ),
        child: Center(
          child: _buildCellContent(context),
        ),
      ),
    );
  }

  Color _getCellColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (cell.isRevealed) {
      if (cell.hasMine) {
        return Colors.red.withValues(alpha: 0.9);
      }
      return isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    }
    
    // Unrevealed state
    if (isDark) {
      return Theme.of(context).cardColor;
    } else {
      return Colors.grey[300]!; // Better depth in light mode
    }
  }

  Widget? _buildCellContent(BuildContext context) {
    if (cell.isFlagged) {
      return const Icon(Icons.flag, color: Colors.orange, size: 18);
    }
    if (cell.isRevealed) {
      if (cell.hasMine) {
        return const Icon(Icons.bolt, color: Colors.white, size: 20);
      }
      if (cell.neighborMines > 0) {
        return Text(
          cell.neighborMines.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _getNumberColor(cell.neighborMines, Theme.of(context).brightness == Brightness.dark),
          ),
        );
      }
    }
    return null;
  }

  Color _getNumberColor(int count, bool isDark) {
    switch (count) {
      case 1:
        return Colors.blue[isDark ? 300 : 700]!;
      case 2:
        return Colors.green[isDark ? 300 : 700]!;
      case 3:
        return Colors.red[isDark ? 300 : 700]!;
      case 4:
        return Colors.purple[isDark ? 300 : 700]!;
      case 5:
        return Colors.orange[isDark ? 300 : 700]!;
      case 6:
        return Colors.teal[isDark ? 300 : 700]!;
      case 7:
        return isDark ? Colors.grey[300]! : Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
