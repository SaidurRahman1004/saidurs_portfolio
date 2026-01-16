import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/screens/admin/dashboard/settings/admin_settings.dart';
import 'package:futter_portfileo_website/screens/admin/dashboard/skills/skills_management.dart';
import '../../../widgets/admin/admin_sidebar.dart';
import '../../../widgets/admin/admin_app_bar.dart';
import 'analytics/analytics_screen.dart';
import 'contact/contact_management.dart';
import 'dashboard_home.dart';
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
    'Skills Management',
    'Projects Management',
    'Contact Information',
    'Analytics',
    'Settings',
  ];

  //  Get current page widget based on selected index
  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardHome();
      case 1:
        return const SkillsManagement();
      case 2:
        return const ProjectsManagement();
      case 3:
        return const ContactManagement();
      case 4:
        return const AnalyticsScreen();
      case 5:
        return const AdminSettings();
      default:
        return const DashboardHome();
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
      child: Scaffold(
        key: _scaffoldKey,
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
            //Desktop Sidebar always Open
            if (isDesktop)
              AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: _onMenuItemSelected,
              ),
            Expanded(child: _getCurrentPage()),
          ],
        ),
      ),
    );
  }
}
