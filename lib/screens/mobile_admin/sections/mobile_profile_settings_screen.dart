import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/theme_provider.dart';
import '../auth/mobile_login_screen.dart';

class MobileProfileSettingsScreen extends StatefulWidget {
  const MobileProfileSettingsScreen({super.key});

  @override
  State<MobileProfileSettingsScreen> createState() => _MobileProfileSettingsScreenState();
}

class _MobileProfileSettingsScreenState extends State<MobileProfileSettingsScreen> {
  Future<void> _toggleBiometrics(bool enable) async {
    final provider = Provider.of<AdminProvider>(context, listen: false);

    if (enable) {
      final passwordController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable Biometric Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your admin password to securely register biometric access.'),
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Admin Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true && passwordController.text.isNotEmpty) {
        final success = await provider.enableBiometricLogin(password: passwordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Biometric login enabled!' : 'Failed to enable biometrics.'),
              backgroundColor: success ? const Color(0xFF10B981) : Colors.redAccent,
            ),
          );
        }
      }
    } else {
      await provider.disableBiometricLogin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric login disabled.')),
        );
      }
    }
  }

  Future<void> _logout() async {
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

    if (confirmed == true && mounted) {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      await admin.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MobileLoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final email = admin.userEmail;
    if (email.isEmpty) return;

    final sent = await admin.sendPasswordReset(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sent ? 'Password reset link sent to $email' : (admin.errorMessage ?? 'Failed to send reset link.')),
          backgroundColor: sent ? const Color(0xFF10B981) : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminProvider = Provider.of<AdminProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile & Security'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          adminProvider.userInitials,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminProvider.userDisplayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          adminProvider.userEmail,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Super Administrator',
                            style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security Settings Section
            Text(
              'SECURITY & BIOMETRICS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Biometric / Fingerprint Login', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      adminProvider.biometricAvailable
                          ? (adminProvider.biometricEnabled ? 'Enabled on this phone' : 'Hardware supported • Not enabled')
                          : 'Biometrics unavailable on this hardware',
                      style: const TextStyle(fontSize: 12),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fingerprint_rounded, color: AppTheme.primaryColor),
                    ),
                    value: adminProvider.biometricEnabled,
                    activeColor: const Color(0xFF10B981),
                    onChanged: adminProvider.biometricAvailable ? (v) => _toggleBiometrics(v) : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF3B82F6)),
                    ),
                    title: const Text('Send Password Reset Email', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Receive a secure reset link to your email', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _sendPasswordReset,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Preferences
            Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(themeProvider.isDarkMode ? 'Night theme enabled' : 'Light theme enabled', style: const TextStyle(fontSize: 12)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: Colors.amber,
                      ),
                    ),
                    value: themeProvider.isDarkMode,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log Out of Saidur Admin', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),

            // App Version Info
            Center(
              child: Text(
                'Saidur Admin v1.0.0 (Production Build)\nConnected to Firebase Cloud Firestore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
