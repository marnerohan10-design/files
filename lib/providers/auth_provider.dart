import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;

  UserModel? _user;
  bool _isBusy = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isBusy => _isBusy;

  Future<void> restoreSession() async {
    _user = _service.restoreSession();
    notifyListeners();
  }

  /// Every action below returns an error message, or null on success.
  Future<String?> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    _setBusy(true);
    try {
      _user = await _service.login(email: email, password: password, remember: remember);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _setBusy(false);
    }
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      await _service.register(name: name, email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _setBusy(false);
    }
  }

  Future<String?> updateProfile({required String name, required String phone}) async {
    final current = _user;
    if (current == null) return 'You are not logged in.';
    _setBusy(true);
    try {
      _user = await _service.updateProfile(current.copyWith(name: name, phone: phone));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not save your profile. Please try again.';
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
