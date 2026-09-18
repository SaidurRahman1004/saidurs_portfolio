import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Service managing Firebase App Check integration.
/// Protects Firebase backends (Firestore, Functions, Storage) from abuse, scraping,
/// and automated attacks while guaranteeing zero downtime or lockouts for legitimate users.
class AppCheckService {
  static final AppCheckService _instance = AppCheckService._internal();
  factory AppCheckService() => _instance;
  AppCheckService._internal();

  static AppCheckService get instance => _instance;

  bool _isActivated = false;
  bool get isActivated => _isActivated;

  /// Safely initializes Firebase App Check.
  /// Uses [ReCaptchaV3Provider] on Web and Play Integrity on Android.
  /// When unconfigured or running on local dev without a site key, gracefully logs
  /// an informational note and continues without throwing exceptions.
  Future<void> initialize({
    String? webRecaptchaV3SiteKey,
    bool isDebug = kDebugMode,
  }) async {
    if (_isActivated) return;

    try {
      // In web development or when site key is not supplied via --dart-define,
      // we utilize the debug provider or bypass to guarantee local development continuity.
      final siteKey = webRecaptchaV3SiteKey ?? const String.fromEnvironment('RECAPTCHA_V3_SITE_KEY', defaultValue: '');

      if (kIsWeb && siteKey.isEmpty && !isDebug) {
        debugPrint('[AppCheckService] Note: RECAPTCHA_V3_SITE_KEY not supplied. App Check running in observation mode.');
        _isActivated = false;
        return;
      }

      await FirebaseAppCheck.instance.activate(
        webProvider: siteKey.isNotEmpty
            ? ReCaptchaV3Provider(siteKey)
            : ReCaptchaV3Provider('dummy_dev_key_fallback'),
        androidProvider: isDebug
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        appleProvider: isDebug
            ? AppleProvider.debug
            : AppleProvider.deviceCheck,
      );

      _isActivated = true;
      debugPrint('[AppCheckService] Firebase App Check activated successfully.');
    } catch (e) {
      debugPrint('[AppCheckService] App Check activation skipped (gracefully degraded): $e');
      _isActivated = false;
    }
  }

  /// Retrieves current App Check token if available
  Future<String?> getToken({bool forceRefresh = false}) async {
    if (!_isActivated) return null;
    try {
      final token = await FirebaseAppCheck.instance.getToken(forceRefresh);
      return token;
    } catch (e) {
      debugPrint('[AppCheckService] Failed to retrieve App Check token: $e');
      return null;
    }
  }
}
