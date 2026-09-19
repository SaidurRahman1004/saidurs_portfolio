import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../auth/mobile_login_screen.dart';
import '../layout/mobile_admin_shell.dart';

class MobileSplashScreen extends StatefulWidget {
  const MobileSplashScreen({super.key});

  @override
  State<MobileSplashScreen> createState() => _MobileSplashScreenState();
}

class _MobileSplashScreenState extends State<MobileSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Give smooth entrance animation a moment to display
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final portfolioProvider = Provider.of<PortfolioProvider>(context, listen: false);

    // Preload basic portfolio data in background
    portfolioProvider.loadAllData();

    // Check biometric and credentials state
    await adminProvider.checkBiometricStatus();

    if (!mounted) return;

    // If user is already authenticated & admin
    if (adminProvider.isAuthenticate && adminProvider.isAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MobileAdminShell()),
      );
      return;
    }

    // If biometric login is enabled, attempt auto-prompt or route to login screen
    if (adminProvider.biometricEnabled && adminProvider.biometricAvailable) {
      final success = await adminProvider.loginWithBiometrics();
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MobileAdminShell()),
        );
        return;
      }
    }

    // Otherwise route to Login Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MobileLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon with glow ring
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.primaryColor,
                      child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                    );
                  },
                ),
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .fade(duration: 500.ms),

            const SizedBox(height: 24),

            // App Title
            Text(
              'Saidur Admin',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            )
            .animate(delay: 200.ms)
            .fade(duration: 500.ms)
            .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Portfolio Command Center',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            )
            .animate(delay: 350.ms)
            .fade(duration: 500.ms),

            const SizedBox(height: 48),

            // Progress Indicator
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
            .animate(delay: 500.ms)
            .fade(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
