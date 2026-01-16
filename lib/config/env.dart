// 📁 lib/config/env. dart - NEW FILE
class Env {
  // ImgBB API Key
  static const String imgbbApiKey = String.fromEnvironment(
    'IMGBB_API_KEY',
    defaultValue:  '', // Empty in production, fail safely
  );

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
    return imgbbApiKey. isNotEmpty;
  }

  // Show warning in debug mode
  static void validateConfig() {
    if (!isConfigured) {
      print('⚠️ WARNING: Environment variables not configured!');
      print('Run: flutter run --dart-define=IMGBB_API_KEY=your_key');
    }
  }
}