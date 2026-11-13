import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/products/product_details_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/orders_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const main = '/main';
  static const productList = '/products';
  static const productDetails = '/product';
  static const editProfile = '/edit-profile';
  static const orders = '/orders';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case login:
        page = LoginScreen(prefillEmail: settings.arguments as String?);
        break;
      case signup:
        page = const SignupScreen();
        break;
      case main:
        page = const MainShell();
        break;
      case productList:
        final args = settings.arguments;
        page = ProductListScreen(
          args: args is ProductListArgs ? args : const ProductListArgs(),
        );
        break;
      case productDetails:
        page = ProductDetailsScreen(product: settings.arguments as ProductModel);
        break;
      case editProfile:
        page = const EditProfileScreen();
        break;
      case orders:
        page = const OrdersScreen();
        break;
      case splash:
      default:
        page = const SplashScreen();
    }
    return _route(page, settings);
  }

  /// Shared page transition: a soft fade combined with a small slide.
  static Route<dynamic> _route(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
