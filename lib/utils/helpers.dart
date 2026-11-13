import 'package:flutter/material.dart';

import 'constants.dart';

extension StringCasing on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'electronics':
      return Icons.devices_other_outlined;
    case 'jewelery':
    case 'jewelry':
      return Icons.diamond_outlined;
    case "men's clothing":
      return Icons.checkroom_outlined;
    case "women's clothing":
      return Icons.local_mall_outlined;
    default:
      return Icons.category_outlined;
  }
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 2),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              ),
      ),
    );
}
