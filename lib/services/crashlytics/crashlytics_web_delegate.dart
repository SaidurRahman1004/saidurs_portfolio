import 'package:flutter/foundation.dart';
import '../error_monitoring/web_error_reporter.dart';
import 'crashlytics_delegate.dart';

/// Factory function returning the web delegate for web/unsupported platforms.
CrashlyticsDelegate getPlatformCrashlyticsDelegate() => WebCrashlyticsDelegate();

/// Web implementation of [CrashlyticsDelegate].
///
/// Firebase Crashlytics does NOT support Flutter Web.
/// This delegate intercepts web errors and delegates to [WebErrorReporter],
/// ensuring structured error tracking, deduplication, and zero native plugin issues.
class WebCrashlyticsDelegate implements CrashlyticsDelegate {
  final Map<String, Object> _contextKeys = {};

  @override
  bool get isSupported => false;

  @override
  Future<void> initialize({bool enableInDebug = false}) async {
    if (kDebugMode) {
      debugPrint('[CrashlyticsWeb] Web platform detected. Initialized WebErrorReporter pipeline.');
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[CrashlyticsWeb] ${fatal ? "[FATAL] " : ""}$reason: $exception');
    }

    final route = _contextKeys['current_route'] as String?;
    final feature = _contextKeys['feature'] as String?;
    final operation = _contextKeys['operation'] as String?;

    await WebErrorReporter.instance.reportError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
      route: route,
      feature: feature,
      operation: operation,
      customKeys: _contextKeys,
    );
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[CrashlyticsWeb] Flutter framework error (${fatal ? "fatal" : "non-fatal"}): ${details.exception}');
    }

    final route = _contextKeys['current_route'] as String?;
    final feature = _contextKeys['feature'] as String?;

    await WebErrorReporter.instance.reportFlutterError(
      details,
      fatal: fatal,
      route: route,
      feature: feature,
    );
  }

  @override
  Future<void> log(String message) async {
    if (kDebugMode) {
      debugPrint('[CrashlyticsWeb Breadcrumb] $message');
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    _contextKeys[key] = value;
  }

  @override
  Future<void> setUserId(String identifier) async {
    _contextKeys['user_id'] = identifier;
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    // Web collection state toggle
  }
}
