import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_session.dart';

class LocalStorageService {
  static const String _sessionKey = 'app_session';

  Future<void> saveSession(AppSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<AppSession?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRole() async {
    final session = await getSession();
    return session?.flutterRole;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
