import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';
import '../auth/mobile_login_screen.dart';
import '../sections/mobile_analytics_screen.dart';
import '../sections/mobile_audit_logs_screen.dart';
import '../sections/mobile_contact_config_screen.dart';
import '../sections/mobile_errors_screen.dart';
import '../sections/mobile_media_gallery_screen.dart';
import '../sections/mobile_profile_settings_screen.dart';
import '../sections/mobile_skills_screen.dart';

class MobileMoreHubTab extends StatelessWidget {
  const MobileMoreHubTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminProvider = Provider.of<AdminProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Mini Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        adminProvider.userInitials,
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminProvider.userDisplayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        adminProvider.userEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MobileProfileSettingsScreen()),
                    );
                  },
                  child: const Text('Profile'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'CONTENT & PORTFOLIO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),

          _buildHubTile(
            context,
            icon: Icons.code_rounded,
            color: const Color(0xFF3B82F6),
            title: 'Skills Management',
            subtitle: 'Add, categorize, and reorder technical skills',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileSkillsScreen())),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildHubTile(
            context,
            icon: Icons.contact_phone_outlined,
            color: const Color(0xFF10B981),
            title: 'Contact & Social Config',
            subtitle: 'Phone, email, WhatsApp, GitHub, LinkedIn links',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileContactConfigScreen())),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildHubTile(
            context,
            icon: Icons.cloud_upload_outlined,
            color: const Color(0xFFF59E0B),
            title: 'Media & CDN Storage',
            subtitle: 'Upload images from camera/gallery to ImgBB',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileMediaGalleryScreen())),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          Text(
            'METRICS & MONITORING',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),

          _buildHubTile(
            context,
            icon: Icons.insights_rounded,
            color: const Color(0xFF8B5CF6),
            title: 'Visitor Analytics',
            subtitle: 'Real-time telemetry, daily trends, device breakdown',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileAnalyticsScreen())),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildHubTile(
            context,
            icon: Icons.bug_report_outlined,
            color: const Color(0xFFEF4444),
            title: 'Errors & Crashlytics',
            subtitle: 'Inspect application runtime errors and triage',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileErrorsScreen())),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildHubTile(
            context,
            icon: Icons.history_rounded,
            color: const Color(0xFF06B6D4),
            title: 'Audit Logs',
            subtitle: 'Immutable record of admin operations and mutations',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileAuditLogsScreen())),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          Text(
            'SYSTEM & SECURITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),

          _buildHubTile(
            context,
            icon: Icons.fingerprint_rounded,
            color: const Color(0xFF10B981),
            title: 'Security & Biometrics',
            subtitle: 'Fingerprint unlock, session management, reset password',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileProfileSettingsScreen())),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildHubTile(
            context,
            icon: Icons.sync_rounded,
            color: const Color(0xFFF59E0B),
            title: 'Seed / Sync Resume Data',
            subtitle: 'Sync default experience and education to Firestore',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sync Resume Data'),
                  content: const Text('This will sync default experience, education, and skills data to Firestore.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sync Now')),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                try {
                  await FirebaseService.instance.seedResumeData();
                  if (context.mounted) {
                    Provider.of<PortfolioProvider>(context, listen: false).loadAllData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data synced successfully!'), backgroundColor: Color(0xFF10B981)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              }
            },
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildHubTile(
            context,
            icon: Icons.logout_rounded,
            color: Colors.redAccent,
            title: 'Log Out',
            subtitle: 'Securely terminate admin session and clear credentials',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out of Saidur Admin?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await Provider.of<AdminProvider>(context, listen: false).logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MobileLoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            isDark: isDark,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHubTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      ),
    );
  }
}
