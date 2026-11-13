import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<WishlistProvider>().items;

    return Scaffold(
      appBar: AppBar(title: Text(items.isEmpty ? 'Wishlist' : 'Wishlist (${items.length})')),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: 'Your wishlist is empty',
              message: 'Tap the heart on any product to save it here.',
              actionLabel: 'Browse products',
              onAction: () => Navigator.pushNamed(context, AppRoutes.productList),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              gridDelegate: productGridDelegate,
              itemCount: items.length,
              itemBuilder: (_, i) => FadeSlideIn(
                key: ValueKey(items[i].id),
                child: ProductCard(product: items[i]),
              ),
            ),
    );
  }
}
