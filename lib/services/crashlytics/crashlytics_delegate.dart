import 'package:flutter/foundation.dart';

/// Abstract contract for platform-specific crash reporting delegates.
/// Mobile implementations interface with Firebase Crashlytics natively,
/// while Web implementations gracefully degrade to safe no-ops (preparing
/// for Phase 4 Web Error Monitoring).
abstract class CrashlyticsDelegate {
  /// Whether Crashlytics is natively supported on the current platform.
  bool get isSupported;

  /// Initializes the underlying crash reporting engine.
  Future<void> initialize({bool enableInDebug = false});

  /// Records an uncaught or caught exception with stack trace.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  });

  /// Records a Flutter framework error details instance.
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  });

  /// Logs a breadcrumb message in the crash report timeline.
  Future<void> log(String message);

  /// Sets a custom key-value pair for diagnostic context.
  Future<void> setCustomKey(String key, Object value);

  /// Sets an anonymous user identifier.
  Future<void> setUserId(String identifier);

  /// Enables or disables crashlytics data collection.
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
}
