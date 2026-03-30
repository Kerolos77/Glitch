import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_games/core/providers/navigation_provider.dart';
import '../../../../core/providers/theme_provider.dart';

class SidebarWidget extends StatelessWidget {
  final bool isMobile;
  const SidebarWidget({super.key, this.isMobile = true});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);

    double scaleW(double val) => isMobile ? val.w : val;
    double scaleH(double val) => isMobile ? val.h : val;
    double scaleSp(double val) => isMobile ? val.sp : val;
    double scaleR(double val) => isMobile ? val.r : val;

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: scaleH(40)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleW(20)),
            child: InkWell(
              onTap: () {
                navProvider.selectGame(null);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }
              },
              child: Column(
                children: [
                  // Logo Placeholder
                  Image.asset(
                    'assets/images/logo.png',
                    height: scaleH(80),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.electric_bolt,
                      size: scaleR(60),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: scaleH(10)),
                  Text(
                    'app_name'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: scaleSp(28),
                          fontWeight: FontWeight.w900,
                          letterSpacing: scaleW(2),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: scaleH(30)),
          _buildSearchField(context, scaleW, scaleH, scaleSp, scaleR),
          SizedBox(height: scaleH(20)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: scaleW(10)),
              children: [
                _buildSectionTitle(context, 'games'.tr(), scaleW, scaleH, scaleSp),
                _buildNavItem(
                  context,
                  Icons.home,
                  'Home',
                  scaleSp: scaleSp,
                  scaleR: scaleR,
                  isSelected: navProvider.selectedGame == null,
                  onTap: () {
                    navProvider.selectGame(null);
                    if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  Icons.grid_on,
                  'Minesweeper',
                  scaleSp: scaleSp,
                  scaleR: scaleR,
                  isSelected: navProvider.selectedGame == 'minesweeper',
                  onTap: () {
                    navProvider.selectGame('minesweeper');
                    if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSettingsSection(context, themeProvider, scaleW, scaleH, scaleSp),
          SizedBox(height: scaleH(20)),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, Function w, Function h, Function sp, Function r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(16)),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: TextStyle(fontSize: sp(13)),
          prefixIcon: Icon(Icons.search, size: r(20)),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: EdgeInsets.symmetric(vertical: h(10)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(12)),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: sp(14)),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Function w, Function h, Function sp) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(10), vertical: h(10)),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: sp(11),
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title,
      {required Function scaleSp, required Function scaleR, bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon,
          size: scaleR(20),
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7)),
      title: Text(title,
          style: TextStyle(
              fontSize: scaleSp(14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Theme.of(context).colorScheme.primary : null)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
      hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider, Function w, Function h, Function sp) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: h(8)),
            child: Text(
              'settings'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: sp(11),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SwitchListTile(
            title: Text('dark_mode'.tr(), style: TextStyle(fontSize: sp(12), fontWeight: FontWeight.w600)),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text('${'language'.tr()} (العربية)', style: TextStyle(fontSize: sp(12), fontWeight: FontWeight.w600)),
            value: isArabic,
            onChanged: (value) {
              if (value) {
                context.setLocale(const Locale('ar'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
