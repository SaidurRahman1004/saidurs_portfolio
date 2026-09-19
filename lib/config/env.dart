import 'package:flutter/foundation.dart';

class Env {
  // ImgBB API Key for media, projects, and certificate uploads
  static const String imgbbApiKey = String.fromEnvironment(
    'IMGBB_API_KEY',
    defaultValue: '87f8708f92a158ed045b4746a14c0ab6',
  );

  // Firebase Web API Key (optional - usually safe to expose)
  static const String firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyBUXmkwPI2wua6Jqit_a7yI5DuYhRrjWC4',
  );

  // Environment check
  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  // Validate all keys are present
  static bool get isConfigured {
    return imgbbApiKey.isNotEmpty;
  }

  // Show warning in debug mode
  static void validateConfig() {
    if (!isConfigured) {
      debugPrint('⚠️ WARNING: Environment variables not configured!');
      debugPrint('Run: flutter run --dart-define=IMGBB_API_KEY=your_key');
    }
  }
}