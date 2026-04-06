import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/supabase_bootstrap.dart';

class AuthProvider extends ChangeNotifier {
  static const _userLoggedInKey = 'is_logged_in';
  static const _sessionExpiresAtKey = 'user_session_expires_at';

  bool _isReady = false;
  bool _isLoggedIn = false;
  bool _isAdminSessionActive = false;

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdminSessionActive => _isAdminSessionActive;

  Future<void> _persistLocalSession(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    if (loggedIn) {
      final expiresAt = DateTime.now()
          .add(const Duration(days: 7))
          .millisecondsSinceEpoch;
      await prefs.setBool(_userLoggedInKey, true);
      await prefs.setInt(_sessionExpiresAtKey, expiresAt);
    } else {
      await prefs.setBool(_userLoggedInKey, false);
      await prefs.remove(_sessionExpiresAtKey);
    }
  }

  Future<void> restoreUserSession() async {
    if (SupabaseBootstrap.isInitialized) {
      final session = Supabase.instance.client.auth.currentSession;
      _isLoggedIn = session != null;
      if (_isLoggedIn) {
        await _persistLocalSession(true);
      } else {
        await _persistLocalSession(false);
      }
      _isAdminSessionActive = false;
      _isReady = true;
      notifyListeners();
      return;
    }

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

  Future<void> signInUser({String? email, String? password}) async {
    if (SupabaseBootstrap.isInitialized &&
        email != null &&
        password != null &&
        email.contains('@')) {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _persistLocalSession(true);
    } else {
      await _persistLocalSession(true);
    }

    _isLoggedIn = true;
    _isAdminSessionActive = false;
    _isReady = true;
    notifyListeners();
  }

  Future<bool> signUpUser({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    if (!SupabaseBootstrap.isInitialized) return false;

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': displayName,
        'phone': phone,
      },
    );

    final user = response.user;
    final session = response.session;

    if (user != null && session != null) {
      await Supabase.instance.client.from('app_profiles').upsert({
        'user_id': user.id,
        'display_name': displayName,
        'phone': phone,
      });
      await _persistLocalSession(true);
      _isLoggedIn = true;
      _isAdminSessionActive = false;
      _isReady = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> signOutUser() async {
    if (SupabaseBootstrap.isInitialized &&
        Supabase.instance.client.auth.currentSession != null) {
      await Supabase.instance.client.auth.signOut();
    }

    await _persistLocalSession(false);

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
