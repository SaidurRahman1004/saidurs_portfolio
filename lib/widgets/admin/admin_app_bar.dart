import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/public/home_screen.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;

  const AdminAppBar({super.key, required this.title, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              if (isMobile) ...[
                IconButton(
                  onPressed: onMenuPressed,
                  icon: Icon(Icons.menu, color: textPrimary),
                  tooltip: 'Open Menu',
                ),
                const SizedBox(width: 8),
              ],

              // Title Icon Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(isDark ? 40 : 25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Title & Breadcrumb
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isMobile)
                      Text(
                        'Admin Portal • Saidur Rahman',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.getTextHint(context),
                              fontSize: 11,
                            ),
                      ),
                  ],
                ),
              ),

              // Theme Mode Toggle (Sun / Moon)
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final isCurrentlyDark = themeProvider.isDarkMode;
                  return Tooltip(
                    message: isCurrentlyDark
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                    child: InkWell(
                      onTap: () => themeProvider.toggleTheme(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentlyDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: borderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                isCurrentlyDark
                                    ? Icons.wb_sunny_rounded
                                    : Icons.nightlight_round,
                                key: ValueKey(isCurrentlyDark),
                                size: 18,
                                color: isCurrentlyDark
                                    ? Colors.amber
                                    : const Color(0xFF4F46E5),
                              ),
                            ),
                            if (!isMobile) ...[
                              const SizedBox(width: 6),
                              Text(
                                isCurrentlyDark ? 'Dark' : 'Light',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 12),

              // View Public Site Button
              InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(isDark ? 40 : 20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryColor.withAlpha(70),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.launch_rounded, size: 16, color: primaryColor),
                      if (!isMobile) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Public Site',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (!isMobile) ...[
                const SizedBox(width: 14),
                // Admin User Avatar Chip
                Consumer<AdminProvider>(
                  builder: (context, adminProvider, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: primaryColor,
                            child: Text(
                              adminProvider.userInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
