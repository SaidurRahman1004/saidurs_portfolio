import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/screens/admin/dashboard/settings/admin_settings.dart';
import 'package:futter_portfileo_website/screens/admin/dashboard/skills/skills_management.dart';
import '../../../widgets/admin/admin_sidebar.dart';
import '../../../widgets/admin/admin_app_bar.dart';
import 'contact/contact_management.dart';
import 'content_management.dart';
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
    'Profile',
    'Professional Experience',
    'Projects Management',
    'Skills Management',
    'Education',
    'Certifications',
    'Resume',
    'Contact Information',
    'Settings',
  ];

  //  Get current page widget based on selected index
  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardHome();
      case 1:
        return const ContactManagement();
      case 2:
        return const PortfolioContentManagement(type: AdminContentType.experience);
      case 3:
        return const ProjectsManagement();
      case 4:
        return const SkillsManagement();
      case 5:
        return const PortfolioContentManagement(type: AdminContentType.education);
      case 6:
        return const PortfolioContentManagement(type: AdminContentType.certification);
      case 7:
        return const ContactManagement();
      case 8:
        return const ContactManagement();
      case 9:
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
