import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_games/core/providers/navigation_provider.dart';
import '../cubit/minesweeper_cubit.dart';
import '../cubit/minesweeper_state.dart';
import '../widgets/minesweeper_cell.dart';

class MinesweeperPage extends StatefulWidget {
  final bool isMobile;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MinesweeperPage({
    super.key,
    required this.isMobile,
    required this.scaffoldKey,
  });

  @override
  State<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends State<MinesweeperPage> {
  int _tempRows = 10;
  int _tempCols = 10;
  int _tempMines = 10;

  @override
  void initState() {
    super.initState();
    // Disable context menu on web when entering the game
    SystemChannels.platform.invokeMethod('BrowserContextMenu.disableNotifications');
  }

  @override
  void dispose() {
    // Re-enable context menu when leaving the game
    SystemChannels.platform.invokeMethod('BrowserContextMenu.enableNotifications');
    super.dispose();
  }

  void _updateMaxMines() {
    int maxMines = ((_tempRows * _tempCols) * 0.8).floor();
    if (_tempMines > maxMines) {
      _tempMines = maxMines;
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isMobile;
    double scaleW(double val) => isMobile ? val.w : val;
    double scaleH(double val) => isMobile ? val.h : val;
    double scaleSp(double val) => isMobile ? val.sp : val;
    double scaleR(double val) => isMobile ? val.r : val;

    return BlocProvider(
      create: (_) => MinesweeperCubit()..initGame(),
      child: Builder(builder: (context) {
        return BlocListener<MinesweeperCubit, MinesweeperState>(
          listener: (context, state) {
            if (state is MinesweeperGameOver) {
              _showGameOverDialog(context, state.isWon);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  if (widget.isMobile) {
                    widget.scaffoldKey.currentState?.openDrawer();
                  } else {
                    context.read<NavigationProvider>().toggleSidebar();
                  }
                },
              ),
              title: BlocBuilder<MinesweeperCubit, MinesweeperState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Minesweeper', style: TextStyle(fontSize: scaleSp(18))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, size: scaleSp(14)),
                          SizedBox(width: scaleW(4)),
                          Text(_formatTime(state.secondsElapsed), style: TextStyle(fontSize: scaleSp(12))),
                          if (state.bestTime != null) ...[
                            SizedBox(width: scaleW(12)),
                            Icon(Icons.emoji_events, size: scaleSp(14), color: Colors.amber),
                            SizedBox(width: scaleW(4)),
                            Text('${'best'.tr()}: ${_formatTime(state.bestTime!)}',
                                style: TextStyle(fontSize: scaleSp(12), fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Restart Game',
                  onPressed: () {
                    context.read<MinesweeperCubit>().initGame();
                  },
                ),
                Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                }),
              ],
            ),
            endDrawer: Drawer(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20.w : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'settings'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: scaleSp(20),
                            ),
                      ),
                      SizedBox(height: scaleH(30)),
                      _buildSettingItem(
                        label: 'Rows',
                        value: _tempRows,
                        min: 5,
                        max: 20,
                        scaleW: scaleW,
                        scaleH: scaleH,
                        scaleSp: scaleSp,
                        onChanged: (val) {
                          setState(() {
                            _tempRows = val.toInt();
                            _updateMaxMines();
                          });
                        },
                      ),
                      _buildSettingItem(
                        label: 'Columns',
                        value: _tempCols,
                        min: 5,
                        max: 20,
                        scaleW: scaleW,
                        scaleH: scaleH,
                        scaleSp: scaleSp,
                        onChanged: (val) {
                          setState(() {
                            _tempCols = val.toInt();
                            _updateMaxMines();
                          });
                        },
                      ),
                      _buildSettingItem(
                        label: 'Mines',
                        value: _tempMines,
                        min: 1,
                        max: ((_tempRows * _tempCols) * 0.5).floor(),
                        scaleW: scaleW,
                        scaleH: scaleH,
                        scaleSp: scaleSp,
                        onChanged: (val) {
                          setState(() {
                            _tempMines = val.toInt();
                          });
                        },
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: scaleH(50),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<MinesweeperCubit>().initGame(
                                  rows: _tempRows,
                                  columns: _tempCols,
                                  mines: _tempMines,
                                );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(scaleR(12))),
                          ),
                          child: Text('Save & Restart',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: scaleSp(16))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(scaleW(12)),
                child: BlocBuilder<MinesweeperCubit, MinesweeperState>(
                  builder: (context, state) {
                    if (state is MinesweeperInitial || state is MinesweeperGameOver) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final board = state is MinesweeperInitial ? state.board : (state as MinesweeperGameOver).board;
                      final rows = board.length;
                      final cols = board.isNotEmpty ? board[0].length : 0;

                      return AspectRatio(
                        aspectRatio: cols / rows,
                        child: Container(
                          padding: EdgeInsets.all(scaleW(4)),
                          decoration: BoxDecoration(
                            color: isDark ? Theme.of(context).cardColor : Colors.grey[100],
                            borderRadius: BorderRadius.circular(scaleR(12)),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: scaleW(2),
                              mainAxisSpacing: scaleW(2),
                            ),
                            itemCount: rows * cols,
                            itemBuilder: (context, index) {
                              final x = index % cols;
                              final y = index ~/ cols;
                              final cell = board[y][x];

                              return MinesweeperCell(
                                cell: cell,
                                onReveal: () => context.read<MinesweeperCubit>().revealCell(x, y),
                                onFlag: () => context.read<MinesweeperCubit>().toggleFlag(x, y),
                              );
                            },
                          ),
                        ),
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSettingItem({
    required String label,
    required int value,
    required int min,
    required int max,
    required Function scaleW,
    required Function scaleH,
    required Function scaleSp,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: scaleSp(14))),
            Text(value.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: scaleSp(14))),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          activeColor: Theme.of(context).colorScheme.primary,
          divisions: max - min > 0 ? max - min : 1,
          onChanged: onChanged,
        ),
        SizedBox(height: scaleH(10)),
      ],
    );
  }

  void _showGameOverDialog(BuildContext context, bool isWon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(isWon ? 'Congratulations!' : 'Game Over'),
        content: Text(isWon ? 'You cleared the field!' : 'You hit a mine!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MinesweeperCubit>().initGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NavigationProvider>().selectGame(null);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
