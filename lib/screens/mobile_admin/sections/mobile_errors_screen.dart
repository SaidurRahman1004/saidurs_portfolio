import 'package:flutter/material.dart';
import '../../admin/dashboard/errors/errors_dashboard_screen.dart';

class MobileErrorsScreen extends StatelessWidget {
  const MobileErrorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Errors & Crashlytics'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
      ),
      body: const ErrorsDashboardScreen(),
    );
  }
}
