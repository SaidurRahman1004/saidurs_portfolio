import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';

class BiometricSetupSheet extends StatefulWidget {
  final String password;
  final VoidCallback onDismiss;

  const BiometricSetupSheet({
    super.key,
    required this.password,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String password,
    required VoidCallback onDismiss,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BiometricSetupSheet(
        password: password,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<BiometricSetupSheet> createState() => _BiometricSetupSheetState();
}

class _BiometricSetupSheetState extends State<BiometricSetupSheet> {
  bool _isSaving = false;

  Future<void> _enableBiometrics() async {
    setState(() => _isSaving = true);
    final provider = Provider.of<AdminProvider>(context, listen: false);

    final success = await provider.enableBiometricLogin(password: widget.password);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Row(
              children: [
                Icon(Icons.fingerprint, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Biometric Login Enabled! You can now sign in with your fingerprint.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131B2E) : Colors.white;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Fingerprint Icon with glow circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            'Enable Biometric Login',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Explanation
          Text(
            'Log into your admin dashboard quickly and securely using your phone\'s fingerprint or biometric sensor. Stored securely with Android Keystore encryption.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Enable Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _enableBiometrics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(
                _isSaving ? 'Enabling...' : 'Enable Fingerprint Login',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Skip Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDismiss();
              },
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
