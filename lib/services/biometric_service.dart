import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  static BiometricService get instance => _instance;

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if hardware supports biometrics and device security is configured
  Future<bool> canAuthenticate() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Error checking support: $e');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] Unknown error checking support: $e');
      return false;
    }
  }

  /// Retrieve list of enrolled biometrics (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Error getting available biometrics: $e');
      return <BiometricType>[];
    }
  }

  /// Prompt native biometric authentication dialog
  Future<bool> authenticate({
    String reason = 'Authenticate to access Saidur Admin Dashboard',
  }) async {
    try {
      final bool isSupported = await canAuthenticate();
      if (!isSupported) {
        debugPrint('[BiometricService] Biometrics not supported or configured on this device.');
        return false;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Authentication PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] Unexpected biometric error: $e');
      return false;
    }
  }

  /// Cancel any pending biometric authentication
  Future<void> cancelAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (_) {}
  }
}
