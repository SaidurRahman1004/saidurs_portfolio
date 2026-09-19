import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/theme_provider.dart';

class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onRefresh;
  final VoidCallback? onProfileTap;

  const MobileAppBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        tooltip: 'Navigation Menu',
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saidur Admin',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      actions: [
        // Refresh Button
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh Data',
            onPressed: onRefresh,
          ),

        // Dark / Light Theme Toggle
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 22,
          ),
          tooltip: 'Toggle Theme',
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),

        // Profile Avatar Button
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      adminProvider.userInitials,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
