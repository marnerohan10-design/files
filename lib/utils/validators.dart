import 'package:flutter/widgets.dart';

class Validators {
  static String? fullName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your full name';
    if (text.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email address';
    final pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  /// Used on the login form: we only check that something was typed.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  /// Used on the signup form: minimum length plus a letter and a number.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please create a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (!hasLetter || !hasDigit) return 'Use at least one letter and one number';
    return null;
  }

  static String? Function(String?) confirmPassword(TextEditingController original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original.text) return 'Passwords do not match';
      return null;
    };
  }

  /// Phone is optional; if it is filled in, it must be 10 digits.
  static String? optionalPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{10}$').hasMatch(text)) return 'Enter a 10 digit phone number';
    return null;
  }
}
