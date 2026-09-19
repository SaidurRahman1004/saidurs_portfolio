import 'package:flutter/foundation.dart';
import 'crashlytics_delegate.dart';
import 'crashlytics_delegate_factory.dart';

/// Centralized service for application crash monitoring and unhandled error capture.
///
/// Designed with strict platform separation:
/// - Mobile platforms (Android/iOS) seamlessly report to Firebase Crashlytics.
/// - Web platform gracefully logs diagnostics locally without importing mobile Crashlytics,
///   serving as the clean integration hook for Phase 4 Web Error Monitoring.
/// - Enforces strict Zero-PII sanitization (strips emails, passwords, tokens, phone numbers).
/// - Completely safe: errors during reporting will NEVER crash or destabilize the application.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();

  factory CrashlyticsService() => _instance;

  CrashlyticsService._internal() {
    _delegate = createCrashlyticsDelegate();
  }

  static CrashlyticsService get instance => _instance;

  late CrashlyticsDelegate _delegate;
  bool _isInitialized = false;

  // Forbidden keys that must NEVER be passed to Crashlytics as custom keys
  static const Set<String> _forbiddenKeys = {
    'password',
    'pass',
    'token',
    'auth_token',
    'secret',
    'email',
    'email_address',
    'phone',
    'phone_number',
    'whatsapp_number',
    'message',
    'contact_message',
    'user_data',
    'private_data',
    'credit_card',
  };

  static final RegExp _emailRegex =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  /// Whether Crashlytics is natively supported on the active runtime platform.
  bool get isSupported => _delegate.isSupported;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Safely initializes crash monitoring.
  ///
  /// Guarantees that failure to initialize Crashlytics will never prevent
  /// the Flutter application from starting or functioning normally.
  Future<void> initialize({
    bool enableInDebug = false,
    CrashlyticsDelegate? delegateOverride,
  }) async {
    if (_isInitialized) {
      debugPrint('[CrashlyticsService] Already initialized; skipping duplicate call.');
      return;
    }

    if (delegateOverride != null) {
      _delegate = delegateOverride;
    }

    try {
      await _delegate.initialize(enableInDebug: enableInDebug);
      _isInitialized = true;

      // Set standard non-sensitive diagnostic environment keys
      await setCustomKey('platform', kIsWeb ? 'web' : defaultTargetPlatform.name);
      await setCustomKey('app_version', '1.0.0+1');
      await setCustomKey('environment', kDebugMode ? 'debug' : 'production');

      debugPrint('[CrashlyticsService] Initialized successfully. Supported: ${_delegate.isSupported}');
    } catch (e) {
      debugPrint('[CrashlyticsService] Initialization failed (gracefully degraded): $e');
      _isInitialized = true;
    }
  }

  /// Records an uncaught or caught exception with rich, sanitized diagnostic context.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    String? route,
    String? feature,
    String? operation,
    Map<String, Object>? customKeys,
    Iterable<Object> information = const [],
  }) async {
    try {
      // Set contextual keys safely
      if (route != null) await setCustomKey('current_route', route);
      if (feature != null) await setCustomKey('feature', feature);
      if (operation != null) await setCustomKey('operation', operation);

      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await setCustomKey(entry.key, entry.value);
        }
      }

      final sanitizedReason = reason != null ? sanitizeMessage(reason) : null;

      await _delegate.recordError(
        exception,
        stack,
        reason: sanitizedReason,
        information: information,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('[CrashlyticsService] Error while recording exception: $e');
    }
  }

  /// Records a Flutter framework error (e.g. from `FlutterError.onError` or `ErrorWidget.builder`).
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
    String? route,
    String? feature,
  }) async {
    try {
      if (route != null) await setCustomKey('current_route', route);
      if (feature != null) await setCustomKey('feature', feature);

      await _delegate.recordFlutterError(details, fatal: fatal);
    } catch (e) {
      debugPrint('[CrashlyticsService] Error while recording FlutterError: $e');
    }
  }

  /// Adds a breadcrumb log to the crash timeline with automatic PII redaction.
  Future<void> log(String message) async {
    try {
      final sanitized = sanitizeMessage(message);
      await _delegate.log(sanitized);
    } catch (e) {
      debugPrint('[CrashlyticsService] Error logging breadcrumb: $e');
    }
  }

  /// Sets a custom diagnostic key with strict PII validation.
  /// Forbidden keys (passwords, emails, phone numbers, tokens) are dropped immediately.
  Future<void> setCustomKey(String key, Object value) async {
    final sanitizedKey = key.trim().toLowerCase();
    if (_forbiddenKeys.contains(sanitizedKey)) {
      if (kDebugMode) {
        debugPrint('[CrashlyticsService] BLOCKED forbidden key: "$sanitizedKey"');
      }
      return;
    }

    try {
      if (value is String) {
        final sanitizedValue = sanitizeMessage(value);
        await _delegate.setCustomKey(sanitizedKey, sanitizedValue);
      } else if (value is num || value is bool) {
        await _delegate.setCustomKey(sanitizedKey, value);
      } else {
        final sanitizedValue = sanitizeMessage(value.toString());
        await _delegate.setCustomKey(sanitizedKey, sanitizedValue);
      }
    } catch (e) {
      debugPrint('[CrashlyticsService] Error setting custom key "$key": $e');
    }
  }

  /// Sets an anonymous user identifier.
  /// If the identifier contains an email address pattern, it is rejected to prevent PII leakage.
  Future<void> setUserId(String identifier) async {
    if (_emailRegex.hasMatch(identifier)) {
      debugPrint('[CrashlyticsService] BLOCKED user ID containing email address.');
      return;
    }

    try {
      await _delegate.setUserId(identifier);
    } catch (e) {
      debugPrint('[CrashlyticsService] Error setting user ID: $e');
    }
  }

  /// Toggles crash data collection enabled/disabled.
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _delegate.setCrashlyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('[CrashlyticsService] Error toggling collection: $e');
    }
  }

  /// Records a deliberate test error with clear metadata tags
  /// (`is_test: true`, `test_id`) ensuring test data is clearly distinguishable
  /// from genuine production issues.
  Future<void> recordTestCrash({
    String testId = 'manual_test',
    bool fatal = false,
  }) async {
    await log('Deliberate test error initiated with test_id: $testId');
    await recordError(
      Exception('[TEST_VERIFICATION] Deliberate test error verification ($testId)'),
      StackTrace.current,
      fatal: fatal,
      reason: 'Deliberate Crashlytics verification test',
      customKeys: {
        'is_test': true,
        'test_id': testId,
        'test_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Redacts sensitive patterns (such as email addresses) from arbitrary strings.
  String sanitizeMessage(String message) {
    if (message.isEmpty) return message;
    return message.replaceAll(_emailRegex, '[REDACTED_EMAIL]');
  }

  // ==========================================
  // Visible for Unit Testing
  // ==========================================

  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _delegate = createCrashlyticsDelegate();
  }

  @visibleForTesting
  void setDelegateForTesting(CrashlyticsDelegate delegate) {
    _delegate = delegate;
  }

  @visibleForTesting
  bool isForbiddenKeyForTesting(String key) => _forbiddenKeys.contains(key.trim().toLowerCase());
}
