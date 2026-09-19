import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static SecureStorageService get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const String _keyBiometricEnabled = 'saidur_admin_biometric_enabled';
  static const String _keySavedEmail = 'saidur_admin_saved_email';
  static const String _keySavedPassword = 'saidur_admin_saved_password';
  static const String _keyLastLoginTimestamp = 'saidur_admin_last_login_ts';

  /// Check if user has opted into biometric login
  Future<bool> isBiometricEnabled() async {
    try {
      final val = await _storage.read(key: _keyBiometricEnabled);
      return val == 'true';
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading biometric status: $e');
      return false;
    }
  }

  /// Toggle biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _keyBiometricEnabled,
        value: enabled ? 'true' : 'false',
      );
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing biometric status: $e');
    }
  }

  /// Securely save credentials for biometric auto-login
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await _storage.write(key: _keySavedEmail, value: email.trim());
      await _storage.write(key: _keySavedPassword, value: password);
      await _storage.write(
        key: _keyLastLoginTimestamp,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      debugPrint('[SecureStorageService] Error saving credentials: $e');
    }
  }

  /// Retrieve saved credentials after biometric validation
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final email = await _storage.read(key: _keySavedEmail);
      final password = await _storage.read(key: _keySavedPassword);

      if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
        return {
          'email': email,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      debugPrint('[SecureStorageService] Error retrieving credentials: $e');
      return null;
    }
  }

  /// Get the saved email for convenience prefill
  Future<String?> getSavedEmail() async {
    try {
      return await _storage.read(key: _keySavedEmail);
    } catch (_) {
      return null;
    }
  }

  /// Clear stored credentials (e.g. on manual logout or credentials change)
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _keySavedPassword);
      await _storage.delete(key: _keyLastLoginTimestamp);
    } catch (e) {
      debugPrint('[SecureStorageService] Error clearing credentials: $e');
    }
  }

  /// Complete reset (e.g. factory reset or full logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[SecureStorageService] Error clearing all storage: $e');
    }
  }
}
