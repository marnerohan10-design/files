import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/product_card.dart';
import '../../widgets/quantity_selector.dart';
import '../../widgets/wishlist_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductModel _product;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product; // shown immediately, then refreshed from the API
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final fresh = await context.read<ProductProvider>().fetchProductDetails(_product.id);
      if (mounted) setState(() => _product = fresh);
    } on ApiException {
      // Keep showing the product we already have; no need to bother the user.
    }
  }

  void _addToCart() {
    context.read<CartProvider>().add(_product, quantity: _quantity);
    showAppSnackBar(
      context,
      'Added $_quantity ${_quantity == 1 ? 'item' : 'items'} to cart',
      actionLabel: 'VIEW',
      onAction: () => openMainTab(context, AppTab.cart),
    );
  }

  void _buyNow() {
    context.read<CartProvider>().add(_product, quantity: _quantity);
    openMainTab(context, AppTab.cart);
  }

  @override
  Widget build(BuildContext context) {
    final total = _product.price * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: WishlistButton(product: _product, size: 40)),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              FadeSlideIn(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 8))],
                  ),
                  child: AppNetworkImage(url: _product.image),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _product.category.capitalized,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _product.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    RatingRow(rating: _product.rating, count: _product.ratingCount, fontSize: 14),
                    const SizedBox(height: 14),
                    Text(
                      formatPrice(_product.price),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      _product.description.isEmpty
                          ? 'No description available for this product.'
                          : _product.description,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        QuantitySelector(
                          quantity: _quantity,
                          onDecrease: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          onIncrease: _quantity < AppConstants.maxQuantity
                              ? () => setState(() => _quantity++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('Total', style: TextStyle(color: AppColors.textSecondary)),
                        const Spacer(),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Add to cart',
                  icon: Icons.add_shopping_cart_rounded,
                  outlined: true,
                  onPressed: _addToCart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: CustomButton(label: 'Buy now', onPressed: _buyNow)),
            ],
          ),
        ),
      ),
    );
  }
}
