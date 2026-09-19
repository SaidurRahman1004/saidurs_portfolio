import 'package:flutter/foundation.dart';

class Env {
  // ImgBB API Key intentionally removed from client-side bundle for security.
  // Use a secure backend proxy (like Firebase Cloud Functions) for uploads.

  // Firebase Web API Key (optional - usually safe to expose)
  static const String firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: '',
  );

  // Environment check
  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  // Validate all keys are present
  static bool get isConfigured {
    return true; // ImgBB is handled server-side now.
  }

  // Show warning in debug mode
  static void validateConfig() {
    if (!isConfigured) {
      debugPrint('⚠️ WARNING: Environment variables not configured!');
      debugPrint('Run: flutter run --dart-define=IMGBB_API_KEY=your_key');
    }
  }
}