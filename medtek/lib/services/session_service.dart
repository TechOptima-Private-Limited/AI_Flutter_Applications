// lib/services/session_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'api_service.dart';

class SessionService extends ChangeNotifier {
  static const _tokenKey = 'authToken';
  static const _userKey = 'user';

  // simple singleton
  static final SessionService instance = SessionService._internal();

  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _token != null && _user != null;

  SessionService._internal();

  // optional: call this once at app start to preload token and user
  Future<void> init() async {
    debugPrint('🔧 SessionService: Initializing...');
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    // Load user data from SharedPreferences
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _user = jsonDecode(userJson) as Map<String, dynamic>;
      debugPrint('✅ Session loaded from storage');
      debugPrint('   User: ${_user?['name']} (${_user?['email']})');
      debugPrint('   Role: ${_user?['role']}');
      debugPrint('   Specialization: ${_user?['specialization']}');
      debugPrint('   Experience: ${_user?['experience_years']} years');
      debugPrint('   Hospital: ${_user?['hospital']?['name'] ?? _user?['selected_hospital_name']}');
    } else {
      debugPrint('⚠️ No user data in storage');
    }

    notifyListeners();
  }

  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    debugPrint('💾 SessionService: Saving session...');
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));

    debugPrint('✅ Session saved');
    debugPrint('   User: ${_user?['name']}');
    debugPrint('   Specialization: ${_user?['specialization']}');

    notifyListeners();
  }

  // 🎯 Update user data after profile changes
  Future<void> updateUser(Map<String, dynamic> updatedUser) async {
    debugPrint('📝 SessionService: Updating user...');
    debugPrint('   Previous specialization: ${_user?['specialization']}');
    debugPrint('   Previous experience: ${_user?['experience_years']}');
    debugPrint('   New specialization: ${updatedUser['specialization']}');
    debugPrint('   New experience: ${updatedUser['experience_years']}');
    debugPrint('   New hospital: ${updatedUser['hospital']?['name']}');

    _user = Map<String, dynamic>.from(updatedUser); // ✅ Create new map instance

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_user));

    debugPrint('✅ User updated in session and storage');
    debugPrint('   Current specialization: ${_user?['specialization']}');
    debugPrint('   Current experience: ${_user?['experience_years']}');

    notifyListeners(); // ✅ This should trigger UI rebuild
    debugPrint('✅ Listeners notified (UI should rebuild now)');
  }

  Future<void> clear() async {
    debugPrint('🗑️ SessionService: Clearing session...');
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
    debugPrint('✅ Session cleared');
  }

  Future<void> signOut() async {
    await clear();
  }

  Future<Map<String, dynamic>> fetchMe(ApiService api) async {
    debugPrint('🔄 SessionService: Fetching /users/me...');
    final me = await api.getMe();
    _user = me['user'] as Map<String, dynamic>;

    // Also save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_user!));

    debugPrint('✅ User data fetched and saved');
    debugPrint('   Specialization: ${_user?['specialization']}');
    debugPrint('   Experience: ${_user?['experience_years']}');

    notifyListeners();
    return _user!;
  }

  // used by ApiService interceptor
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }
}
