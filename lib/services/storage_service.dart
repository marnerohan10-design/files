import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences so the rest of the app never deals
/// with raw keys or JSON encoding.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    return StorageService(await SharedPreferences.getInstance());
  }

  static const cartKey = 'cart_items';
  static const wishlistKey = 'wishlist_items';
  static const _usersKey = 'demo_users';
  static const _sessionEmailKey = 'session_email';
  static const _sessionRememberKey = 'session_remember';

  // ---- demo accounts (salted hashes only, never plain passwords) ----
  Map<String, dynamic> readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  Future<void> writeUsers(Map<String, dynamic> users) {
    return _prefs.setString(_usersKey, jsonEncode(users));
  }

  // ---- session ----
  String? get sessionEmail => _prefs.getString(_sessionEmailKey);
  bool get rememberSession => _prefs.getBool(_sessionRememberKey) ?? true;

  Future<void> saveSession(String email, {required bool remember}) async {
    await _prefs.setString(_sessionEmailKey, email);
    await _prefs.setBool(_sessionRememberKey, remember);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_sessionEmailKey);
    await _prefs.remove(_sessionRememberKey);
  }

  // ---- lists stored as JSON (cart, wishlist) ----
  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      // corrupted data: start fresh instead of crashing
    }
    return [];
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> items) {
    return _prefs.setString(key, jsonEncode(items));
  }
}
