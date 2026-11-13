import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/product_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/loading_widget.dart';
import '../products/product_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: _body(context, products),
    );
  }

  Widget _body(BuildContext context, ProductProvider products) {
    switch (products.homeStatus) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 164,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const ShimmerBox(radius: 18),
        );

      case LoadStatus.error:
        return ErrorState(
          message: products.homeError ?? 'Please try again.',
          onRetry: () => context.read<ProductProvider>().loadHome(),
        );

      case LoadStatus.loaded:
        if (products.categories.isEmpty) {
          return const EmptyState(
            icon: Icons.category_outlined,
            title: 'No categories yet',
            message: 'Categories will appear here once the store has products.',
          );
        }
        // First tile is "All products", then one tile per category from the API.
        final tiles = [ProductProvider.allCategories, ...products.categories];
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 164,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, i) {
            final category = tiles[i];
            final isAll = category == ProductProvider.allCategories;
            final count = isAll ? products.allProducts.length : products.countForCategory(category);
            return FadeSlideIn(
              delay: Duration(milliseconds: 50 * i),
              child: CategoryCard(
                large: true,
                label: isAll ? 'All products' : category,
                icon: isAll ? Icons.apps_rounded : categoryIcon(category),
                subtitle: '$count items',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.productList,
                  arguments: ProductListArgs(category: isAll ? null : category),
                ),
              ),
            );
          },
        );
    }
  }
}
