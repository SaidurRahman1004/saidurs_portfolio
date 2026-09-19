import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'crashlytics_delegate.dart';

/// Factory function returning the mobile Crashlytics delegate for IO platforms.
CrashlyticsDelegate getPlatformCrashlyticsDelegate() => MobileCrashlyticsDelegate();

/// Native mobile implementation using the Firebase Crashlytics SDK.
class MobileCrashlyticsDelegate implements CrashlyticsDelegate {
  @override
  bool get isSupported => true;

  @override
  Future<void> initialize({bool enableInDebug = false}) async {
    if (Firebase.apps.isEmpty) {
      debugPrint('[CrashlyticsMobile] Firebase is not initialized. Crashlytics disabled.');
      return;
    }

    try {
      if (kDebugMode && !enableInDebug) {
        // Prevent debug sessions from polluting production Crashlytics dashboard
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
        debugPrint('[CrashlyticsMobile] Debug mode: Crashlytics collection disabled.');
      } else {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        debugPrint('[CrashlyticsMobile] Production mode: Crashlytics collection enabled.');
      }
    } catch (e) {
      debugPrint('[CrashlyticsMobile] Failed to initialize Crashlytics: $e');
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
    if (Firebase.apps.isEmpty) return;

    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('[CrashlyticsMobile] Error recording crash: $e');
    }
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    if (Firebase.apps.isEmpty) return;

    try {
      if (fatal) {
        await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } else {
        await FirebaseCrashlytics.instance.recordFlutterError(details, fatal: false);
      }
    } catch (e) {
      debugPrint('[CrashlyticsMobile] Error recording Flutter error: $e');
    }
  }

  @override
  Future<void> log(String message) async {
    if (Firebase.apps.isEmpty) return;

    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      debugPrint('[CrashlyticsMobile] Error logging breadcrumb: $e');
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    if (Firebase.apps.isEmpty) return;

    try {
      if (value is String) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is int) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is double) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is bool) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else {
        await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
      }
    } catch (e) {
      debugPrint('[CrashlyticsMobile] Error setting custom key "$key": $e');
    }
  }

  @override
  Future<void> setUserId(String identifier) async {
    if (Firebase.apps.isEmpty) return;

    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
    } catch (e) {
      debugPrint('[CrashlyticsMobile] Error setting user identifier: $e');
    }
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    if (Firebase.apps.isEmpty) return;

    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('[CrashlyticsMobile] Error setting collection enabled: $e');
    }
  }
}
