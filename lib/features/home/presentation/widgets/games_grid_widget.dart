import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:online_games/core/providers/navigation_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GamesGridWidget extends StatelessWidget {
  final bool isMobile;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const GamesGridWidget({
    super.key,
    required this.isMobile,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    double scaleW(double val) => isMobile ? val.w : val;
    double scaleH(double val) => isMobile ? val.h : val;
    double scaleSp(double val) => isMobile ? val.sp : val;
    double scaleR(double val) => isMobile ? val.r : val;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            if (isMobile) {
              scaffoldKey.currentState?.openDrawer();
            } else {
              context.read<NavigationProvider>().toggleSidebar();
            }
          },
        ),
        title: Text('app_name'.tr(), style: TextStyle(fontSize: scaleSp(18))),
      ),
      body: Container(
        padding: EdgeInsets.all(scaleW(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: 1, // Only Minesweeper for now
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobile ? 160.w : 250.0,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: scaleW(16),
                  mainAxisSpacing: scaleW(16),
                ),
                itemBuilder: (context, index) {
                  return _buildGameCard(context, 'Minesweeper', 'minesweeper', scaleW, scaleH, scaleSp, scaleR);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, String gameId, Function w, Function h, Function sp, Function r) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(r(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(r(12))),
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.grid_on,
                size: r(48),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(w(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: sp(14)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: h(32),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<NavigationProvider>().selectGame(gameId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r(8)),
                        ),
                      ),
                      child: Text('play_now'.tr(), style: TextStyle(fontSize: sp(12))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
