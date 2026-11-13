import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/product_card.dart';

/// Options passed to the listing screen through the route.
class ProductListArgs {
  const ProductListArgs({this.category, this.focusSearch = false});

  final String? category;
  final bool focusSearch;
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.args = const ProductListArgs()});

  final ProductListArgs args;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().openListing(category: widget.args.category);
      if (widget.args.focusSearch) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<ProductProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final title = products.selectedCategory == ProductProvider.allCategories
        ? 'All products'
        : products.selectedCategory.capitalized;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<SortOption>(
            tooltip: 'Sort',
            icon: const Icon(Icons.swap_vert_rounded),
            onSelected: products.setSort,
            itemBuilder: (_) => [
              for (final option in SortOption.values)
                CheckedPopupMenuItem<SortOption>(
                  value: option,
                  checked: products.sort == option,
                  child: Text(option.label),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              textInputAction: TextInputAction.search,
              onChanged: context.read<ProductProvider>().setQuery,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: products.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().setQuery('');
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final category =
                    i == 0 ? ProductProvider.allCategories : products.categories[i - 1];
                final selected = products.selectedCategory == category;
                return ChoiceChip(
                  label: Text(category.capitalized),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (_) => context.read<ProductProvider>().selectCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _body(products)),
        ],
      ),
    );
  }

  Widget _body(ProductProvider products) {
    switch (products.listStatus) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const ProductGridShimmer();

      case LoadStatus.error:
        return ErrorState(
          message: products.listError ?? 'Please try again.',
          onRetry: () => context.read<ProductProvider>().retryList(),
        );

      case LoadStatus.loaded:
        final items = products.visibleProducts;
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            message: 'Try a different search word or category.',
            actionLabel: 'Clear filters',
            onAction: _clearFilters,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                '${items.length} ${items.length == 1 ? 'product' : 'products'}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                gridDelegate: productGridDelegate,
                itemCount: items.length,
                itemBuilder: (_, i) => FadeSlideIn(
                  key: ValueKey(items[i].id),
                  delay: Duration(milliseconds: 40 * (i % 6)),
                  child: ProductCard(product: items[i]),
                ),
              ),
            ),
          ],
        );
    }
  }
}
