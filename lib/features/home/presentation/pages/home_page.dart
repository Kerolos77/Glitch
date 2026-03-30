import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_games/core/providers/navigation_provider.dart';
import 'package:online_games/features/minesweeper/presentation/pages/minesweeper_page.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/games_grid_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: Row(
            children: [
              // Animated Sidebar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: navProvider.isSidebarVisible ? 280.0 : 0.0,
                child: const ClipRect(
                  child: OverflowBox(
                    minWidth: 280.0,
                    maxWidth: 280.0,
                    alignment: Alignment.centerLeft,
                    child: const SidebarWidget(),
                  ),
                ),
              ),
              
              // Main Content
              Expanded(
                child: _buildBody(navProvider.selectedGame),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(String? selectedGame) {
    switch (selectedGame) {
      case 'minesweeper':
        return const MinesweeperPage();
      default:
        return const GamesGridWidget();
    }
  }
}
