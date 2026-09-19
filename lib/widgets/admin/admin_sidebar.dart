import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/admin/auth/login_screen.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final Function(int) onItemSelected;

  @override
  Widget build(BuildContext context) {
    final sidebarBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final unreadInquiries = context.watch<PortfolioProvider>().unreadInquiriesCount;
    final openErrors = context.watch<PortfolioProvider>().openErrorsCount;

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // User Profile Card at the top
          _buildUserProfile(context),

          const SizedBox(height: 12),

          // Scrollable navigation items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'OVERVIEW'),
                  _buildMenuItem(
                    context,
                    index: 0,
                    icon: Icons.grid_view_rounded,
                    selectedIcon: Icons.grid_view_rounded,
                    title: 'Dashboard',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 1,
                    icon: Icons.mark_email_unread_outlined,
                    selectedIcon: Icons.mark_email_unread_rounded,
                    title: 'Messages & Inquiries',
                    badgeText: unreadInquiries > 0 ? '$unreadInquiries' : null,
                    badgeColor: Colors.orange,
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 2,
                    icon: Icons.insights_rounded,
                    selectedIcon: Icons.insights_rounded,
                    title: 'Analytics',
                  ),

                  const SizedBox(height: 18),
                  _buildSectionHeader(context, 'PORTFOLIO CONTENT'),
                  _buildMenuItem(
                    context,
                    index: 3,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    title: 'Profile',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 4,
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description_rounded,
                    title: 'Resume',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 5,
                    icon: Icons.contact_mail_outlined,
                    selectedIcon: Icons.contact_mail_rounded,
                    title: 'Contact Config',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 6,
                    icon: Icons.image_outlined,
                    selectedIcon: Icons.image_rounded,
                    title: 'Media & SEO',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 7,
                    icon: Icons.layers_outlined,
                    selectedIcon: Icons.layers_rounded,
                    title: 'Projects',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 8,
                    icon: Icons.bolt_outlined,
                    selectedIcon: Icons.bolt_rounded,
                    title: 'Skills',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 9,
                    icon: Icons.work_outline_rounded,
                    selectedIcon: Icons.work_rounded,
                    title: 'Experience',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 10,
                    icon: Icons.school_outlined,
                    selectedIcon: Icons.school_rounded,
                    title: 'Education',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 11,
                    icon: Icons.military_tech_outlined,
                    selectedIcon: Icons.military_tech_rounded,
                    title: 'Certifications',
                  ),

                  const SizedBox(height: 18),
                  _buildSectionHeader(context, 'SYSTEM'),
                  _buildMenuItem(
                    context,
                    index: 12,
                    icon: Icons.tune_rounded,
                    selectedIcon: Icons.tune_rounded,
                    title: 'Settings',
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 13,
                    icon: Icons.bug_report_outlined,
                    selectedIcon: Icons.bug_report_rounded,
                    title: 'Errors & Crashes',
                    badgeText: openErrors > 0 ? '$openErrors' : null,
                    badgeColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context,
                    index: 14,
                    icon: Icons.history_rounded,
                    selectedIcon: Icons.history_rounded,
                    title: 'Audit Logs',
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Divider(color: borderColor, height: 1),

          // Theme Switcher & Logout at bottom
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildThemeToggleRow(context),
                const SizedBox(height: 8),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppTheme.getTextHint(context),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final borderColor = AppTheme.getBorderColor(context);

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 16, 14, 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppTheme.primaryGradient
                      : AppTheme.lightPrimaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(isDark ? 70 : 40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    adminProvider.userInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Name and Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminProvider.userDisplayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Online • Admin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    String? badgeText,
    Color? badgeColor,
  }) {
    final isSelected = selectedIndex == index;
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return InkWell(
      onTap: () => onItemSelected(index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withAlpha(isDark ? 40 : 25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? primaryColor.withAlpha(isDark ? 80 : 50)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? primaryColor : textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? primaryColor : textPrimary,
                ),
              ),
            ),
            if (badgeText != null && badgeText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleRow(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final borderColor = AppTheme.getBorderColor(context);
        return InkWell(
          onTap: () => themeProvider.toggleTheme(),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  size: 18,
                  color: isDark ? Colors.amber : const Color(0xFF4F46E5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isDark ? 'Switch to Light' : 'Switch to Dark',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                Text(
                  isDark ? '🌙' : '☀️',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleLogout(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFEF4444).withAlpha(50),
            width: 1,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out from the Admin Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      if (!context.mounted) return;
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
