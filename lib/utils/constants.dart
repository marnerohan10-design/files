import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF172554); // deep navy
  static const secondary = Color(0xFF2563EB); // royal blue
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF64748B);
  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);

  static const border = Color(0xFFE2E8F0);
  static const primarySoft = Color(0xFFE8EEFF);
  static const star = Color(0xFFF59E0B);
  // Navy at roughly 8% opacity, written as a constant so no opacity helper is needed.
  static const shadow = Color(0x14172554);
}

class AppConstants {
  static const appName = 'ShopEase';
  static const tagline = 'Your Style, Your Store.';
  static const apiBaseUrl = 'https://fakestoreapi.com';
  static const requestTimeout = Duration(seconds: 15);
  static const maxQuantity = 10;
}
