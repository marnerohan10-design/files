import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'scale_tap.dart';

/// Heart button with a pop animation. Rebuilds only when this product's
/// wishlist state changes.
class WishlistButton extends StatelessWidget {
  const WishlistButton({super.key, required this.product, this.size = 34});

  final ProductModel product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<WishlistProvider, bool>((w) => w.contains(product.id));

    return ScaleTap(
      scale: 0.85,
      onTap: () {
        final nowSaved = context.read<WishlistProvider>().toggle(product);
        showAppSnackBar(context, nowSaved ? 'Added to wishlist' : 'Removed from wishlist');
      },
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: child,
          ),
          child: Icon(
            saved ? Icons.favorite : Icons.favorite_border,
            key: ValueKey<bool>(saved),
            size: size * 0.55,
            color: saved ? AppColors.error : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
