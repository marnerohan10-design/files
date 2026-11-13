import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/navigation.dart';
import '../app/routes.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'app_network_image.dart';
import 'scale_tap.dart';
import 'wishlist_button.dart';

/// Two columns on phones, more on tablets / landscape.
const SliverGridDelegate productGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,
  mainAxisExtent: 276,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
);

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetails, arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: AppNetworkImage(url: product.image),
                    ),
                  ),
                  Positioned(top: 8, right: 8, child: WishlistButton(product: product)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.capitalized,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  RatingRow(rating: product.rating, count: product.ratingCount),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatPrice(product.price),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _AddToCartButton(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.rating, required this.count, this.fontSize = 12});

  final double rating;
  final int count;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: fontSize + 3, color: AppColors.star),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton({required this.product});

  final ProductModel product;

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _justAdded = false;

  Future<void> _addToCart() async {
    context.read<CartProvider>().add(widget.product);
    showAppSnackBar(
      context,
      'Added to cart',
      actionLabel: 'VIEW',
      onAction: () => openMainTab(context, AppTab.cart),
    );
    setState(() => _justAdded = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _justAdded = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      scale: 0.88,
      onTap: _addToCart,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _justAdded ? AppColors.success : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _justAdded ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
            key: ValueKey<bool>(_justAdded),
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
