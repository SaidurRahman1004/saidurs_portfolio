import 'package:flutter/material.dart';
import '../../../widgets/admin/admin_sidebar.dart';
import '../../../widgets/admin/admin_app_bar.dart';
import 'dashboard_home.dart';

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
        return const Center(child: Text('Skill Sections - Coming Soon'));
      case 2:
        return const Center(child: Text('Projects Management - Coming Soon'));
      case 3:
        return const Center(child: Text('Contact Info - Coming Soon'));
      case 4:
        return const Center(child: Text('Analytics - Coming Soon'));
      case 5:
        return const Center(child: Text('Settings - Coming Soon'));
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

  /*
  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close drawer if open For Mobile
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

 */

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
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
    );
  }
}
