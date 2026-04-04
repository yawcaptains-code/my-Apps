import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const _userLoggedInKey = 'is_logged_in';
  static const _sessionExpiresAtKey = 'user_session_expires_at';

  bool _isReady = false;
  bool _isLoggedIn = false;
  bool _isAdminSessionActive = false;

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdminSessionActive => _isAdminSessionActive;

  Future<void> restoreUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt(_sessionExpiresAtKey);
    final hasValidSession =
        prefs.getBool(_userLoggedInKey) == true &&
        expiresAt != null &&
        DateTime.now().millisecondsSinceEpoch < expiresAt;

    if (!hasValidSession) {
      await prefs.setBool(_userLoggedInKey, false);
      await prefs.remove(_sessionExpiresAtKey);
      _isLoggedIn = false;
    } else {
      _isLoggedIn = true;
    }

    _isAdminSessionActive = false;
    _isReady = true;
    notifyListeners();
  }

  Future<void> signInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = DateTime.now()
        .add(const Duration(days: 7))
        .millisecondsSinceEpoch;

    await prefs.setBool(_userLoggedInKey, true);
    await prefs.setInt(_sessionExpiresAtKey, expiresAt);

    _isLoggedIn = true;
    _isAdminSessionActive = false;
    _isReady = true;
    notifyListeners();
  }

  Future<void> signOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userLoggedInKey, false);
    await prefs.remove(_sessionExpiresAtKey);

    _isLoggedIn = false;
    _isAdminSessionActive = false;
    notifyListeners();
  }

  Future<void> signInAdmin() async {
    _isLoggedIn = true;
    _isAdminSessionActive = true;
    _isReady = true;
    notifyListeners();
  }

  Future<void> signOutAdmin() async {
    _isAdminSessionActive = false;
    notifyListeners();
  }
}
