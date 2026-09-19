import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../../public/home_screen.dart';
import '../dashboard/admin_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final loginSuccess = await adminProvider.login(
      email: email,
      password: password,
    );

    if (loginSuccess && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AdminLayout()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Authenticated successfully! Welcome back, Admin.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return SelectionArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF070A1E),
        body: Stack(
          children: [
            // 1. Ambient Background Layer with Animated Glowing Orbs
            _buildAmbientBackground(size),

            // 2. High-Tech Dot Matrix Overlay
            _buildDotMatrixGrid(),

            // 3. Main Centered Interactive Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 32,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo & Header
                        _buildHeader(isMobile),
                        const SizedBox(height: 32),

                        // Glassmorphic Login Card
                        _buildLoginCard(isMobile),
                        const SizedBox(height: 28),

                        // Return to Portfolio Button
                        _buildBackButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ambient Animated Gradient Orbs that create dynamic depth behind the UI
  Widget _buildAmbientBackground(Size size) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;

        return Stack(
          children: [
            // Top-Left Cyan Glow
            Positioned(
              top: -80 + (pulse * 30),
              left: -80 + (pulse * 20),
              child: Container(
                width: 380 + (pulse * 40),
                height: 380 + (pulse * 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withAlpha(55),
                      AppTheme.primaryColor.withAlpha(15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Bottom-Right Purple/Violet Glow
            Positioned(
              bottom: -100 + ((1.0 - pulse) * 40),
              right: -100 + ((1.0 - pulse) * 30),
              child: Container(
                width: 440 + ((1.0 - pulse) * 50),
                height: 440 + ((1.0 - pulse) * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondaryColor.withAlpha(60),
                      AppTheme.secondaryColor.withAlpha(20),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Subtle Center Accent Glow
            Positioned(
              top: size.height * 0.35,
              right: size.width * 0.1,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentColor.withAlpha(25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Subtle cyber dot pattern overlay for developer aesthetic
  Widget _buildDotMatrixGrid() {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DotGridPainter(),
      ),
    );
  }

  /// Header with Security Pill Badge, Floating Glowing Icon, and Gradient Title
  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        // Security Status Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withAlpha(25),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF10B981).withAlpha(80),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withAlpha(180),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 1200.ms),
              const SizedBox(width: 8),
              Text(
                'SECURE ACCESS • 256-BIT SSL',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

        const SizedBox(height: 20),

        // Glowing Shield Icon Orb
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glowing Ring
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withAlpha(70),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 2500.ms),

            // Glass Circle with Border
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withAlpha(45),
                    AppTheme.secondaryColor.withAlpha(30),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.primaryColor.withAlpha(140),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(60),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 38,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

        const SizedBox(height: 20),

        // Gradient Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00D9FF), Color(0xFFA78BFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Admin Console',
            style: TextStyle(
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Sign in with administrative privileges to manage portfolio data',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary.withAlpha(210),
            fontSize: isMobile ? 13 : 14.5,
            height: 1.4,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
      ],
    );
  }

  /// Glassmorphic Frosted Login Form Card
  Widget _buildLoginCard(bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 24 : 36),
          decoration: BoxDecoration(
            color: const Color(0xFF131938).withAlpha(180),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.primaryColor.withAlpha(55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 35,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(20),
                blurRadius: 25,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Indicator
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'CREDENTIAL VERIFICATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor.withAlpha(220),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Email Input Field
                _buildModernTextField(
                  controller: _emailController,
                  labelText: 'Admin Email',
                  hintText: 'admin@saidur.dev',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email address is required';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Input Field
                _buildModernTextField(
                  controller: _passwordController,
                  labelText: 'Security Key / Password',
                  hintText: '••••••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    tooltip:
                        _obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _showForgotPasswordDialog,
                    icon: const Icon(Icons.help_outline_rounded, size: 14),
                    label: const Text('Forgot credentials?'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In Action Button
                _buildSubmitButton(),
                const SizedBox(height: 16),

                // Error / Feedback Messages
                _buildMessages(),

                const SizedBox(height: 8),

                // Security Note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 13,
                      color: AppTheme.textHint.withAlpha(160),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Protected by Firebase Enterprise Authentication',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 700.ms, delay: 250.ms).slideY(begin: 0.08, end: 0);
  }

  /// Modern High-Tech Text Field with Smooth Glass Styling
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppTheme.primaryColor,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: AppTheme.textSecondary.withAlpha(200),
          fontSize: 14,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.textHint.withAlpha(120),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AppTheme.primaryColor.withAlpha(200),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF090D26).withAlpha(180),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.surfaceColor.withAlpha(150),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.accentColor.withAlpha(200),
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.accentColor,
            width: 1.8,
          ),
        ),
      ),
      validator: validator,
    );
  }

  /// Modern Glowing Gradient Submit Button
  Widget _buildSubmitButton() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final isLoading = adminProvider.isLoading;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D9FF), Color(0xFF6C63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9FF).withAlpha(isLoading ? 30 : 90),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : _handleLogin,
              hoverColor: Colors.white.withAlpha(25),
              splashColor: Colors.white.withAlpha(40),
              child: Center(
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 14),
                          Text(
                            'Authenticating...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Sign In to Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Error Feedback Alert
  Widget _buildMessages() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.accentColor.withAlpha(120),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    adminProvider.errorMessage!,
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).shake(duration: 400.ms);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Back to Portfolio Button with Modern Pill Styling
  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      },
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: const Text('Back to Public Portfolio'),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: AppTheme.surfaceColor.withAlpha(120),
            width: 1,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  /// Modern Glassmorphic Forgot Password Dialog
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF131938),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppTheme.primaryColor.withAlpha(60),
              width: 1.2,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Reset Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your verified admin email address to receive a secure password recovery link.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Admin Email',
                  prefixIcon: const Icon(
                    Icons.alternate_email_rounded,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF090D26),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  final adminProvider = Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  );
                  final success = await adminProvider.sendPasswordReset(email);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.mark_email_read_outlined,
                                color: Colors.white),
                            SizedBox(width: 10),
                            Text('Password reset link sent! Check your inbox.'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send Reset Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: const Color(0xFF070A1E),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for cyber dot grid pattern
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF).withAlpha(12)
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    const radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
