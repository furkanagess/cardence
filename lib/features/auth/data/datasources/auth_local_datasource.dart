import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session_model.dart';
import '../models/user_profile_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthSessionModel?> getSession();

  Future<void> saveSession(AuthSessionModel session);

  Future<UserProfileModel?> getCachedProfile();

  Future<void> saveCachedProfile(UserProfileModel profile);

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  static const _sessionKey = 'auth_session';
  static const _cachedProfileKey = 'auth_cached_profile';

  final SharedPreferences _prefs;

  @override
  Future<AuthSessionModel?> getSession() async {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    await _prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<UserProfileModel?> getCachedProfile() async {
    final raw = _prefs.getString(_cachedProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCachedProfile(UserProfileModel profile) async {
    await _prefs.setString(
      _cachedProfileKey,
      jsonEncode(profile.toCacheJson()),
    );
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_cachedProfileKey);
  }
}
