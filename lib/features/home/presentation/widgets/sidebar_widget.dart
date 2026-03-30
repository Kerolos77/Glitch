import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
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
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: InkWell(
              onTap: () => navProvider.selectGame(null),
              child: Column(
                children: [
                  // Logo Placeholder (Expecting assets/images/logo.png)
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.electric_bolt, // Glitch/Flash icon
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'app_name'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildSearchField(context),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildSectionTitle(context, 'games'.tr()),
                _buildNavItem(
                  context,
                  Icons.home,
                  'Home',
                  isSelected: navProvider.selectedGame == null,
                  onTap: () => navProvider.selectGame(null),
                ),
                _buildNavItem(
                  context,
                  Icons.grid_on,
                  'Minesweeper',
                  isSelected: navProvider.selectedGame == 'minesweeper',
                  onTap: () => navProvider.selectGame('minesweeper'),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSettingsSection(context, themeProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title, {bool isSelected = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7)),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Theme.of(context).colorScheme.primary : null)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
      hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'settings'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SwitchListTile(
            title: Text('dark_mode'.tr(), style: const TextStyle(fontSize: 14)),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text('${'language'.tr()} (العربية)', style: const TextStyle(fontSize: 14)),
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
