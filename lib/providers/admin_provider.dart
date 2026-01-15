import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AdminProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  //CUrrent logeed User
  User? _currentUser;

  User? get currentUser => _currentUser;

  //Auth status,cheak User Log in or not
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

  //Cheak Auth state when Provider Created
  AdminProvider() {
    _initializeAuthListener();
  }

  //Listen Auth State Changes,if auth state changes (log in /log out,app start,session expired etc) then Firebase call this Methode for auto session management etc
  void _initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      //store Firebase object user into local variable _currentUser
      _currentUser = user;
      notifyListeners();
      if (user != null) {
        debugPrint(' User logged in: ${user.email}');
      } else {
        debugPrint(' User logged out');
      }
    });
  }

  //login methode call //ui call this through provider
  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearMassege(); //clear previous MAssege

      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      _setLoading(false);
      if (user != null) {
        _currentUser = user;
        _successMessage = 'Login successful';
        _setLoading(false);
        return true; //login success go to dashboard
      } else {
        _errorMessage = 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false; //login failed
    }
  }

  ///Log Out Methode handle Provider //Current Session end and Go to Login Page
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _successMessage = 'Logged out successfully';
      _setLoading(false);
      //Auth state listener automatically update UI
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
  }

  ///ResetPassword MEthode
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

  ///USER INFO GETTERS
  String get userEmail => _currentUser?.email ?? ""; //current User Email
  String? get userId => _currentUser?.uid; //current User Id
  bool get isEmailVerified =>
      _currentUser?.emailVerified ?? false; //current User Email Verified
  //current User Display Name
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

  ///HElper Methode
  //helper Methode Set Loading state and Notify Ui
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //Error or Success Message Clear
  void _clearMassege() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  //clear Error Message when Ui dismiss
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Manually success message clear
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  //all messages clear
  void clearAllMessages() {
    _clearMassege();
  }
}
