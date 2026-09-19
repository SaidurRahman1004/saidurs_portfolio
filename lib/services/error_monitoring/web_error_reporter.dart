import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../models/error_report_model.dart';
import 'error_fingerprinter.dart';
import 'error_sanitizer.dart';
import 'error_severity_classifier.dart';

/// Production Web Error Reporter.
///
/// Responsibilities:
/// 1. Sanitizes all error data (guaranteeing Zero-PII).
/// 2. Generates a deterministic SHA-256 fingerprint for deduplication.
/// 3. Throttles repeated identical errors client-side (60-second in-memory window).
/// 4. Protects against recursive monitoring loops using an internal reporting lock.
/// 5. Dispatches payload securely to the `reportWebError` Callable Cloud Function.
/// 6. Degrades gracefully: network, Cloud Function, or Firebase failures will NEVER
///    throw exceptions or impact user interactions.
class WebErrorReporter {
  static final WebErrorReporter _instance = WebErrorReporter._internal();

  factory WebErrorReporter() => _instance;

  WebErrorReporter._internal();

  static WebErrorReporter get instance => _instance;

  // Recursion lock to prevent infinite error loops
  bool _isReporting = false;

  // In-memory client deduplication cache: fingerprint -> last reported timestamp
  final Map<String, DateTime> _fingerprintCache = {};
  static const Duration _deduplicationWindow = Duration(seconds: 60);

  // Testing hook for custom callable handler
  Future<Map<String, dynamic>> Function(Map<String, dynamic> payload)? _testCallableHandler;

  /// Reports an exception with diagnostic context to the backend.
  Future<String?> reportError(
    dynamic exception,
    StackTrace? stack, {
    String? type,
    String? reason,
    bool fatal = false,
    String? route,
    String? feature,
    String? operation,
    Map<String, Object>? customKeys,
  }) async {
    // 1. Guard against recursive error loops
    if (_isReporting) {
      debugPrint('[WebErrorReporter] Recursive error report prevented.');
      return null;
    }

    _isReporting = true;

    try {
      // 2. Sanitize error message and stack trace (Zero PII)
      final rawMessage = reason != null ? '$reason: $exception' : exception.toString();
      final sanitizedMessage = ErrorSanitizer.sanitizeMessage(rawMessage);
      final sanitizedStack = ErrorSanitizer.sanitizeStackTrace(stack);
      final sanitizedRoute = ErrorSanitizer.sanitizeRoute(route);
      final sanitizedOperation = ErrorSanitizer.sanitizeOperation(operation ?? feature);
      final resolvedType = type ?? _resolveErrorType(exception);

      // 3. Compute deterministic fingerprint
      final fingerprint = ErrorFingerprinter.computeFingerprint(
        type: resolvedType,
        message: sanitizedMessage,
        stackTrace: sanitizedStack,
      );

      // 4. Client-side deduplication check
      final now = DateTime.now();
      final lastReported = _fingerprintCache[fingerprint];
      if (lastReported != null && now.difference(lastReported) < _deduplicationWindow) {
        if (kDebugMode) {
          debugPrint('[WebErrorReporter] Throttled duplicate error: #$fingerprint');
        }
        return fingerprint;
      }

      _fingerprintCache[fingerprint] = now;

      // Clean up cache if it grows large
      if (_fingerprintCache.length > 500) {
        _fingerprintCache.removeWhere((_, time) => now.difference(time) > _deduplicationWindow);
      }

      // 5. Classify severity
      final severity = ErrorSeverityClassifier.classify(
        exception: exception,
        fatal: fatal,
        operation: sanitizedOperation,
        route: sanitizedRoute,
      );

      // 6. Construct structured model
      final report = ErrorReportModel(
        fingerprint: fingerprint,
        type: resolvedType,
        severity: severity,
        message: sanitizedMessage,
        route: sanitizedRoute,
        operation: sanitizedOperation,
        platform: 'web',
        browser: kIsWeb ? 'web_browser' : 'unknown',
        appVersion: '1.0.0+1',
        stackTrace: sanitizedStack,
      );

      // 7. Dispatch to Cloud Function
      await _dispatchReport(report);

      return fingerprint;
    } catch (e) {
      // Must NEVER crash the client app if error monitoring fails
      debugPrint('[WebErrorReporter] Non-fatal failure while reporting error: $e');
      return null;
    } finally {
      _isReporting = false;
    }
  }

  /// Reports a Flutter framework error details instance.
  Future<String?> reportFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
    String? route,
    String? feature,
  }) {
    return reportError(
      details.exception,
      details.stack,
      type: 'framework_error',
      reason: details.context?.toString(),
      fatal: fatal,
      route: route,
      feature: feature,
    );
  }

  /// Internal dispatcher: sends payload to the Callable Cloud Function.
  Future<void> _dispatchReport(ErrorReportModel report) async {
    final payload = report.toCallablePayload();

    if (_testCallableHandler != null) {
      await _testCallableHandler!(payload);
      return;
    }

    if (Firebase.apps.isEmpty) {
      debugPrint('[WebErrorReporter] Firebase uninitialized; report cached locally: ${report.referenceCode}');
      return;
    }

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('reportWebError');
      final result = await callable.call<Map<String, dynamic>>(payload);
      if (kDebugMode) {
        debugPrint('[WebErrorReporter] Dispatched error #${report.fingerprint}: ${result.data}');
      }
    } catch (callError) {
      // Gracefully log without re-throwing
      debugPrint('[WebErrorReporter] Callable function unavailable (offline or not deployed): $callError');
    }
  }

  /// Resolves error type category from exception class name.
  String _resolveErrorType(dynamic exception) {
    final str = exception.runtimeType.toString();
    if (str.contains('FlutterError')) return 'framework_error';
    if (str.contains('Firebase')) return 'firebase_error';
    if (str.contains('Socket') || str.contains('Http') || str.contains('ClientException')) {
      return 'network_error';
    }
    if (str.contains('Type') || str.contains('Cast')) return 'type_error';
    if (str.contains('Range') || str.contains('Index')) return 'range_error';
    if (str.contains('State')) return 'state_error';
    return 'application_error';
  }

  // ==========================================
  // Visible for Unit Testing
  // ==========================================

  @visibleForTesting
  void resetForTesting() {
    _isReporting = false;
    _fingerprintCache.clear();
    _testCallableHandler = null;
  }

  @visibleForTesting
  void setCallableHandlerForTesting(
    Future<Map<String, dynamic>> Function(Map<String, dynamic> payload)? handler,
  ) {
    _testCallableHandler = handler;
  }

  @visibleForTesting
  int get cacheSizeForTesting => _fingerprintCache.length;
}
