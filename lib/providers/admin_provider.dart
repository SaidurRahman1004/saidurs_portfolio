import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/security/audit_service.dart';

class AdminProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  // Current logged in User
  User? _currentUser;

  bool _isCheckingAdmin = true;
  bool _isAdmin = false;

  User? get currentUser => _currentUser;

  bool get isCheckingAdmin => _isCheckingAdmin;
  bool get isAdmin => _isAdmin;

  // Auth status, check user logged in or not
  bool get isAuthenticate => currentUser != null;

  /// Loading state login/logout process
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message login failed
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Success message logout successful etc
  String? _successMessage;
  String? get successMessage => _successMessage;

  // Check auth state when provider created
  AdminProvider() {
    _initializeAuthListener();
  }

  // Listen Auth State Changes
  void _initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _isCheckingAdmin = true;
      _isAdmin = false;
      notifyListeners();
      _refreshAdminClaim(user);
      if (user != null) {
        debugPrint(' User logged in: ${user.email}');
      } else {
        debugPrint(' User logged out');
      }
    });
  }

  Future<void> _refreshAdminClaim(User? user) async {
    if (user == null) {
      _isCheckingAdmin = false;
      notifyListeners();
      return;
    }

    try {
      final tokenResult = await user.getIdTokenResult(true);
      final hasAdminClaim = tokenResult.claims?['admin'] == true;
      final isApprovedAdminEmail =
          user.email == 'saidurrahman1004@gmail.com';
      _isAdmin = hasAdminClaim || isApprovedAdminEmail;
    } catch (error) {
      debugPrint('Failed to verify admin claim: $error');
      _isAdmin = false;
    } finally {
      _isCheckingAdmin = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearMassege();

      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      _setLoading(false);
      if (user != null) {
        _currentUser = user;
        await _refreshAdminClaim(user);
        _successMessage = 'Login successful';
        _setLoading(false);

        // Record successful admin login in audit logs
        AuditService.instance.logAction(
          action: 'admin_login',
          resourceType: 'auth',
          resourceId: user.uid,
          result: 'success',
        );

        return true;
      } else {
        _errorMessage = 'Login failed';
        _setLoading(false);

        // Record failed login attempt
        AuditService.instance.logAction(
          action: 'admin_login',
          resourceType: 'auth',
          resourceId: email,
          result: 'failure',
          metadata: {'reason': 'Invalid credentials'},
        );

        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');

      AuditService.instance.logAction(
        action: 'admin_login',
        resourceType: 'auth',
        resourceId: email,
        result: 'failure',
        metadata: {'error': _errorMessage ?? 'error'},
      );

      return false;
    }
  }

  /// Log out
  Future<void> logout() async {
    try {
      final uid = _currentUser?.uid ?? 'unknown';
      _setLoading(true);

      // Record logout audit log
      AuditService.instance.logAction(
        action: 'admin_logout',
        resourceType: 'auth',
        resourceId: uid,
        result: 'success',
      );

      await _authService.signOut();
      _currentUser = null;
      _isAdmin = false;
      _isCheckingAdmin = false;
      _successMessage = 'Logged out successfully';
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Reset Password
  Future<bool> sendPasswordReset(String email) async {
    try {
      _setLoading(true);
      _clearMassege();
      await _authService.sendPasswordResetEmail(email);
      _successMessage = 'Password reset email sent';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// User Info Getters
  String get userEmail => _currentUser?.email ?? "";
  String? get userId => _currentUser?.uid;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  String get userDisplayName {
    if (_currentUser?.displayName != null &&
        _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    }
    return _currentUser?.email?.split('@').first ?? 'Admin';
  }

  /// Profile initials (Avatar SR)
  String get userInitials {
    final name = userDisplayName.trim();
    if (name.isEmpty) return 'AD';

    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      if (parts[0].length >= 2) {
        return parts[0].substring(0, 2).toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return 'AD';
  }

  /// Helper Methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMassege() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
