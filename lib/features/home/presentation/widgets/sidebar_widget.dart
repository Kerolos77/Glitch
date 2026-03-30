import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_games/core/providers/navigation_provider.dart';
import '../../../../core/providers/theme_provider.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: InkWell(
              onTap: () {
                navProvider.selectGame(null);
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }
              },
              child: Column(
                children: [
                  // Logo Placeholder (Expecting assets/images/logo.png)
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80.h,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.electric_bolt, // Glitch/Flash icon
                      size: 60.r,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'app_name'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.w,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30.h),
          _buildSearchField(context),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              children: [
                _buildSectionTitle(context, 'games'.tr()),
                _buildNavItem(
                  context,
                  Icons.home,
                  'Home',
                  isSelected: navProvider.selectedGame == null,
                  onTap: () {
                    navProvider.selectGame(null);
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  Icons.grid_on,
                  'Minesweeper',
                  isSelected: navProvider.selectedGame == 'minesweeper',
                  onTap: () {
                    navProvider.selectGame('minesweeper');
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSettingsSection(context, themeProvider),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: TextStyle(fontSize: 13.sp),
          prefixIcon: Icon(Icons.search, size: 20.r),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title, {bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, 
          size: 20.r,
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7)),
      title: Text(title, style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Theme.of(context).colorScheme.primary : null)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      tileColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
      hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'settings'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SwitchListTile(
            title: Text('dark_mode'.tr(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text('${'language'.tr()} (العربية)', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
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
