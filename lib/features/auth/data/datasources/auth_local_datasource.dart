import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/last_login_credentials.dart';
import '../models/auth_session_model.dart';
import '../models/user_profile_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthSessionModel?> getSession();

  Future<void> saveSession(AuthSessionModel session);

  Future<UserProfileModel?> getCachedProfile();

  Future<void> saveCachedProfile(UserProfileModel profile);

  Future<LastLoginCredentials> getLastLoginCredentials();

  Future<void> saveLastLoginCredentials({
    String? email,
    String? phone,
    LastLoginMethod? method,
  });

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  static const _sessionKey = 'auth_session';
  static const _cachedProfileKey = 'auth_cached_profile';
  static const _lastLoginEmailKey = 'auth_last_login_email';
  static const _lastLoginPhoneKey = 'auth_last_login_phone';
  static const _lastLoginMethodKey = 'auth_last_login_method';

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
  Future<LastLoginCredentials> getLastLoginCredentials() async {
    final email = _prefs.getString(_lastLoginEmailKey);
    final phone = _prefs.getString(_lastLoginPhoneKey);
    final methodRaw = _prefs.getString(_lastLoginMethodKey);
    LastLoginMethod? method;
    if (methodRaw == LastLoginMethod.email.name) {
      method = LastLoginMethod.email;
    } else if (methodRaw == LastLoginMethod.phone.name) {
      method = LastLoginMethod.phone;
    } else if (methodRaw == LastLoginMethod.linkedin.name) {
      method = LastLoginMethod.linkedin;
    }

    return LastLoginCredentials(
      email: email?.trim().isNotEmpty == true ? email!.trim() : null,
      phone: phone?.trim().isNotEmpty == true ? phone!.trim() : null,
      lastMethod: method,
    );
  }

  @override
  Future<void> saveLastLoginCredentials({
    String? email,
    String? phone,
    LastLoginMethod? method,
  }) async {
    if (email != null && email.isNotEmpty) {
      await _prefs.setString(_lastLoginEmailKey, email);
    }
    if (phone != null && phone.isNotEmpty) {
      await _prefs.setString(_lastLoginPhoneKey, phone);
    }
    if (method != null) {
      await _prefs.setString(_lastLoginMethodKey, method.name);
    }
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_cachedProfileKey);
  }
}
