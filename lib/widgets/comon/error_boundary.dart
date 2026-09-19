import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/crashlytics/crashlytics_service.dart';
import '../../services/error_monitoring/error_fingerprinter.dart';

/// A production-safe Error Boundary that catches widget-level crashes,
/// logs them securely to the centralized error monitoring system,
/// and presents a polished, user-friendly fallback state without
/// ever exposing raw stack traces to visitors.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _lastErrorDetails;
  String? _referenceCode;

  @override
  void initState() {
    super.initState();
    _configureErrorWidget();
  }

  void _configureErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Record caught build-time widget error as non-fatal to Crashlytics/WebErrorReporter
      CrashlyticsService.instance.recordFlutterError(
        details,
        fatal: false,
        feature: 'error_boundary_widget',
      );

      final fingerprint = ErrorFingerprinter.computeFingerprint(
        type: 'widget_build_error',
        message: details.exception.toString(),
        stackTrace: details.stack?.toString() ?? '',
      );

      final ref = '#${fingerprint.length >= 6 ? fingerprint.substring(0, 6) : fingerprint}';

      return widget.fallback ?? _buildUserFriendlyErrorView(context, details, ref);
    };
  }

  void _resetErrorState() {
    setState(() {
      _lastErrorDetails = null;
      _referenceCode = null;
    });
  }

  Widget _buildUserFriendlyErrorView(
    BuildContext context,
    FlutterErrorDetails details,
    String referenceCode,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Friendly Title
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Reassuring explanation
                Text(
                  'An unexpected display issue occurred while loading this section. Our monitoring system has automatically logged this incident.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: subtextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Incident Reference Code Badge
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referenceCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error reference copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Incident Ref: $referenceCode',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: subtextColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Actions: Retry and Home
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      icon: const Icon(Icons.home_outlined, size: 18),
                      label: const Text('Home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _resetErrorState,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),

                // Debug-only diagnostics disclosure (hidden in release builds)
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  ExpansionTile(
                    title: const Text(
                      'Debug Diagnostics (Local Dev Only)',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          details.exception.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lastErrorDetails != null) {
      return widget.fallback ??
          _buildUserFriendlyErrorView(
            context,
            _lastErrorDetails!,
            _referenceCode ?? '#unknown',
          );
    }
    return widget.child;
  }
}
