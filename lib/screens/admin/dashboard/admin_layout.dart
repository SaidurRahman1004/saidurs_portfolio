import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/screens/admin/dashboard/settings/admin_settings.dart';
import 'package:futter_portfileo_website/screens/admin/dashboard/skills/skills_management.dart';
import '../../../widgets/admin/admin_sidebar.dart';
import '../../../widgets/admin/admin_app_bar.dart';
import 'analytics/analytics_screen.dart';
import 'contact/contact_management.dart';
import 'profile/profile_management.dart';
import 'resume/resume_management.dart';
import 'media/media_management.dart';
import 'content_management.dart';
import 'dashboard_home.dart';
import 'errors/errors_dashboard_screen.dart';
import 'audit_logs/audit_logs_screen.dart';
import 'inquiries/inquiries_management.dart';
import 'projects/projects_management.dart';
import '../../../widgets/admin/auth_guard.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  //Drawer Controller For Mobile
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Page Title List Dynamically Show in Appbar
  final List<String> _pageTitles = [
    'Dashboard',
    'Messages & Inquiries',
    'Analytics',
    'Profile',
    'Resume',
    'Contact Config',
    'Media & SEO',
    'Projects Management',
    'Skills Management',
    'Professional Experience',
    'Education',
    'Certifications',
    'Settings',
    'Errors & Crashes',
    'Audit Logs',
  ];

  //  Get current page widget based on selected index
  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardHome(onNavigate: _onMenuItemSelected);
      case 1:
        return const InquiriesManagement();
      case 2:
        return const AnalyticsScreen();
      case 3:
        return const ProfileManagement();
      case 4:
        return const ResumeManagement();
      case 5:
        return const ContactManagement();
      case 6:
        return const MediaManagement();
      case 7:
        return const ProjectsManagement();
      case 8:
        return const SkillsManagement();
      case 9:
        return const PortfolioContentManagement(type: AdminContentType.experience);
      case 10:
        return const PortfolioContentManagement(type: AdminContentType.education);
      case 11:
        return const PortfolioContentManagement(type: AdminContentType.certification);
      case 12:
        return const AdminSettings();
      case 13:
        return const ErrorsDashboardScreen();
      case 14:
        return const AuditLogsScreen();
      default:
        return DashboardHome(onNavigate: _onMenuItemSelected);
    }
  }

  // Handle menu item selection
  void _onMenuItemSelected(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
        });
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return AuthGuard(
      child: SelectionArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AdminAppBar(
            title: _pageTitles[_selectedIndex],
            onMenuPressed: isDesktop
                ? null
                : () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
          ),
          drawer: !isDesktop
              ? Drawer(
                  child: AdminSidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: _onMenuItemSelected,
                  ),
                )
              : null,
          body: Row(
            children: [
              if (isDesktop)
                AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onMenuItemSelected,
                ),
              Expanded(child: _getCurrentPage()),
            ],
          ),
        ),
      ),
    );
  }
}
