import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/user_model.dart';
import 'storage_service.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// DEMO AUTHENTICATION ONLY.
///
/// FakeStore has no secure user system, so accounts are created and checked on
/// the device. Passwords are never stored in plain text: each one is salted and
/// hashed (SHA-256, 2000 rounds) before it is written. This protects against
/// casual reading of the stored data but is NOT a replacement for real
/// server-side authentication (bcrypt/argon2 + tokens over HTTPS).
class AuthService {
  AuthService(this._storage);

  final StorageService _storage;

  static const _hashRounds = 2000;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    final users = _storage.readUsers();
    if (users.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }

    final salt = _generateSalt();
    users[key] = {
      'name': name.trim(),
      'email': key,
      'phone': '',
      'salt': salt,
      'hash': _hash(password, salt),
    };
    await _storage.writeUsers(users);
  }

  Future<UserModel> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    final key = email.trim().toLowerCase();
    final record = _storage.readUsers()[key];
    if (record is! Map<String, dynamic>) {
      throw const AuthException('No account found for this email. Please sign up first.');
    }
    final expected = record['hash'];
    final salt = record['salt'];
    if (expected is! String || salt is! String || _hash(password, salt) != expected) {
      throw const AuthException('Incorrect password. Please try again.');
    }

    await _storage.saveSession(key, remember: remember);
    return UserModel.fromJson(record);
  }

  /// Returns the saved user if a session exists (and "remember me" was on).
  UserModel? restoreSession() {
    final email = _storage.sessionEmail;
    if (email == null) return null;

    if (!_storage.rememberSession) {
      _storage.clearSession();
      return null;
    }
    final record = _storage.readUsers()[email];
    if (record is! Map<String, dynamic>) return null;
    return UserModel.fromJson(record);
  }

  Future<UserModel> updateProfile(UserModel user) async {
    final users = _storage.readUsers();
    final record = users[user.email];
    if (record is! Map<String, dynamic>) {
      throw const AuthException('Account not found.');
    }
    record['name'] = user.name.trim();
    record['phone'] = user.phone.trim();
    users[user.email] = record;
    await _storage.writeUsers(users);
    return UserModel.fromJson(record);
  }

  Future<void> logout() => _storage.clearSession();

  String _generateSalt() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  String _hash(String password, String salt) {
    var digest = sha256.convert(utf8.encode('$salt:$password'));
    for (var i = 1; i < _hashRounds; i++) {
      digest = sha256.convert([...digest.bytes, ...utf8.encode(salt)]);
    }
    return digest.toString();
  }
}
