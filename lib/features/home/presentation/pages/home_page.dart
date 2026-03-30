import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:online_games/core/providers/navigation_provider.dart';
import 'package:online_games/features/minesweeper/presentation/pages/minesweeper_page.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/games_grid_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 900;
            
            return Scaffold(
              key: _scaffoldKey,
              // Use Sidebar as a Drawer on mobile
              drawer: isMobile ? SizedBox(
                width: 280.w,
                child: const SidebarWidget(isMobile: true),
              ) : null,
              body: Row(
                children: [
                  // Side panel on Desktop
                  if (!isMobile)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: navProvider.isSidebarVisible ? 280.0 : 0.0,
                      child: const ClipRect(
                        child: OverflowBox(
                          minWidth: 280.0,
                          maxWidth: 280.0,
                          alignment: Alignment.centerLeft,
                          child: SidebarWidget(isMobile: false),
                        ),
                      ),
                    ),
                  
                  // Main Content
                  Expanded(
                    child: _buildBody(navProvider.selectedGame, isMobile),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(String? selectedGame, bool isMobile) {
    switch (selectedGame) {
      case 'minesweeper':
        return MinesweeperPage(isMobile: isMobile, scaffoldKey: _scaffoldKey);
      default:
        return GamesGridWidget(isMobile: isMobile, scaffoldKey: _scaffoldKey);
    }
  }
}
