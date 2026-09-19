import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../layout/mobile_admin_shell.dart';
import 'biometric_setup_sheet.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'saidurrahman1004@gmail.com');
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).checkBiometricStatus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final success = await adminProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (!adminProvider.isAdmin) {
        _showErrorSnackBar('Access denied. This account does not have admin permissions.');
        await adminProvider.logout();
        return;
      }

      // Check if biometrics can be offered
      if (adminProvider.biometricAvailable && !adminProvider.biometricEnabled) {
        await BiometricSetupSheet.show(
          context,
          password: _passwordController.text,
          onDismiss: () {
            _navigateToDashboard();
          },
        );
      } else {
        _navigateToDashboard();
      }
    } else {
      _showErrorSnackBar(adminProvider.errorMessage ?? 'Login failed. Please check credentials.');
    }
  }

  Future<void> _handleBiometricLogin() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    setState(() => _isLoading = true);

    final success = await adminProvider.loginWithBiometrics();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (!adminProvider.isAdmin) {
        _showErrorSnackBar('Access denied. Account is not an authorized administrator.');
        await adminProvider.logout();
        return;
      }
      _navigateToDashboard();
    } else {
      if (adminProvider.errorMessage != null &&
          !adminProvider.errorMessage!.toLowerCase().contains('cancelled')) {
        _showErrorSnackBar(adminProvider.errorMessage!);
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MobileAdminShell()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your admin email address to receive a secure password reset link.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final sent = await adminProvider.sendPasswordReset(email);
              if (mounted) {
                if (sent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset link sent to $email'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                } else {
                  _showErrorSnackBar(adminProvider.errorMessage ?? 'Failed to send reset email.');
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Brand Icon & Header
                  Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(43),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.primaryColor,
                              child: const Icon(Icons.admin_panel_settings, size: 44, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 20),

                  // Header Texts
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back, Saidur',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to manage your portfolio and site content',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 150.ms).fade().slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: 'Admin Email',
                      hintText: 'saidurrahman1004@gmail.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF131B2E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF131B2E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Primary Sign In Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePasswordLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In to Dashboard',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  // Biometric Quick Login Section
                  if (adminProvider.biometricAvailable && adminProvider.biometricEnabled) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR FAST UNLOCK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleBiometricLogin,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.06),
                        ),
                        icon: const Icon(Icons.fingerprint_rounded, size: 26),
                        label: const Text(
                          'Login with Fingerprint',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Security Badge
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'End-to-End Encrypted Admin Session',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
