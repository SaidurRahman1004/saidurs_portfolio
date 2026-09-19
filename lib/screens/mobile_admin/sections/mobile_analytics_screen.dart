import 'package:flutter/material.dart';
import '../../admin/dashboard/analytics/analytics_screen.dart';

class MobileAnalyticsScreen extends StatelessWidget {
  const MobileAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Visitor Analytics'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
      ),
      body: const AnalyticsScreen(),
    );
  }
}
