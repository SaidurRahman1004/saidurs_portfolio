import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../sections/mobile_analytics_screen.dart';
import '../sections/mobile_audit_logs_screen.dart';
import '../sections/mobile_contact_config_screen.dart';
import '../sections/mobile_errors_screen.dart';
import '../sections/mobile_media_gallery_screen.dart';
import '../sections/mobile_profile_settings_screen.dart';
import '../sections/mobile_skills_screen.dart';
import '../tabs/mobile_inquiries_tab.dart';
import '../tabs/mobile_more_hub_tab.dart';
import '../tabs/mobile_overview_tab.dart';
import '../tabs/mobile_projects_tab.dart';
import '../tabs/mobile_resume_tab.dart';
import 'mobile_app_bar.dart';

class MobileAdminShell extends StatefulWidget {
  const MobileAdminShell({super.key});

  @override
  State<MobileAdminShell> createState() => _MobileAdminShellState();
}

class _MobileAdminShellState extends State<MobileAdminShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _tabTitles = [
    'Dashboard Overview',
    'Projects',
    'Visitor Messages',
    'Resume & Career',
    'More & Control Center',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<PortfolioProvider>(context, listen: false);
      p.loadAllData();
      p.loadInquiries();
      p.loadAllProjects();
      p.loadAllSkills();
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDrawerItemSelect(VoidCallback action) {
    Navigator.pop(context); // Close drawer
    action();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    final unreadInquiries = portfolioProvider.inquiries.where((i) => !i.isRead).length;

    final List<Widget> tabs = [
      MobileOverviewTab(onNavigateTab: _onTabSelected),
      const MobileProjectsTab(),
      const MobileInquiriesTab(),
      const MobileResumeTab(),
      const MobileMoreHubTab(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: MobileAppBar(
        title: _tabTitles[_currentIndex],
        onRefresh: () {
          portfolioProvider.loadAllData();
          portfolioProvider.loadInquiries();
          portfolioProvider.loadAllProjects();
          portfolioProvider.loadAllSkills();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dashboard refreshed!'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MobileProfileSettingsScreen()),
          );
        },
      ),

      // Navigation Drawer
      drawer: _buildDrawer(context, isDark, adminProvider),

      // Body
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.primaryColor.withOpacity(0.15),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF3B82F6)),
              label: 'Overview',
            ),
            const NavigationDestination(
              icon: Icon(Icons.layers_outlined),
              selectedIcon: Icon(Icons.layers_rounded, color: Color(0xFF3B82F6)),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unreadInquiries > 0,
                label: Text(unreadInquiries.toString()),
                child: const Icon(Icons.mail_outline_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: unreadInquiries > 0,
                label: Text(unreadInquiries.toString()),
                child: const Icon(Icons.mail_rounded, color: Color(0xFF3B82F6)),
              ),
              label: 'Inquiries',
            ),
            const NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded, color: Color(0xFF3B82F6)),
              label: 'Resume',
            ),
            const NavigationDestination(
              icon: Icon(Icons.more_horiz_rounded),
              selectedIcon: Icon(Icons.more_horiz_rounded, color: Color(0xFF3B82F6)),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark, AdminProvider admin) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                          admin.userInitials,
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
                          admin.userDisplayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Saidur Admin Panel',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Overview',
                    selected: _currentIndex == 0,
                    onTap: () => _onDrawerItemSelect(() => _onTabSelected(0)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.layers_rounded,
                    label: 'Projects Management',
                    selected: _currentIndex == 1,
                    onTap: () => _onDrawerItemSelect(() => _onTabSelected(1)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.mail_rounded,
                    label: 'Messages & Inquiries',
                    selected: _currentIndex == 2,
                    onTap: () => _onDrawerItemSelect(() => _onTabSelected(2)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.school_rounded,
                    label: 'Resume & Career',
                    selected: _currentIndex == 3,
                    onTap: () => _onDrawerItemSelect(() => _onTabSelected(3)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.code_rounded,
                    label: 'Skills Management',
                    onTap: () => _onDrawerItemSelect(() {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileSkillsScreen()));
                    }),
                  ),
                  _buildDrawerItem(
                    icon: Icons.contact_phone_outlined,
                    label: 'Contact & Social Config',
                    onTap: () => _onDrawerItemSelect(() {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileContactConfigScreen()));
                    }),
                  ),
                  _buildDrawerItem(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Media & CDN Storage',
                    onTap: () => _onDrawerItemSelect(() {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileMediaGalleryScreen()));
                    }),
                  ),
                  _buildDrawerItem(
                    icon: Icons.insights_rounded,
                    label: 'Visitor Analytics',
                    onTap: () => _onDrawerItemSelect(() {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileAnalyticsScreen()));
                    }),
                  ),
                  _buildDrawerItem(
                    icon: Icons.bug_report_outlined,
                    label: 'Errors & Crashlytics',
                    onTap: () => _onDrawerItemSelect(() {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileErrorsScreen()));
                    }),
                  ),
                  _buildDrawerItem(
                    icon: Icons.history_rounded,
                    label: 'Security Audit Logs',
                    onTap: () => _onDrawerItemSelect(() {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileAuditLogsScreen()));
                    }),
                  ),
                  _buildDrawerItem(
                    icon: Icons.security_rounded,
                    label: 'Profile & Security',
                    onTap: () => _onDrawerItemSelect(() {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileProfileSettingsScreen()));
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.primaryColor : null, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          color: selected ? AppTheme.primaryColor : null,
          fontSize: 14,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}
