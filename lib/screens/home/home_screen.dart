import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/product_card.dart';
import '../../widgets/scale_tap.dart';
import '../../widgets/section_header.dart';
import '../products/product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().loadHome(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _HomeHeader()),
            const SliverToBoxAdapter(child: _SearchBar()),
            const SliverToBoxAdapter(child: _PromoBanner()),
            ..._content(context, products),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, ProductProvider products) {
    switch (products.homeStatus) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const [SliverToBoxAdapter(child: _HomeSkeleton())];

      case LoadStatus.error:
        return [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 360,
              child: ErrorState(
                message: products.homeError ?? 'Please try again.',
                onRetry: () => context.read<ProductProvider>().loadHome(),
              ),
            ),
          ),
        ];

      case LoadStatus.loaded:
        if (products.allProducts.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 320,
                child: EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No products available',
                  message: 'The store has no products right now. Pull down to refresh.',
                ),
              ),
            ),
          ];
        }
        return _loadedSlivers(context, products);
    }
  }

  List<Widget> _loadedSlivers(BuildContext context, ProductProvider products) {
    final popular = products.popular;

    return [
      if (products.categories.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Shop by category',
            onSeeAll: () => openMainTab(context, AppTab.categories),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final category = products.categories[i];
                return SizedBox(
                  width: 92,
                  child: CategoryCard(
                    label: category,
                    icon: categoryIcon(category),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productList,
                      arguments: ProductListArgs(category: category),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      SliverToBoxAdapter(
        child: SectionHeader(
          title: 'Featured products',
          onSeeAll: () => Navigator.pushNamed(context, AppRoutes.productList),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 284,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            itemCount: products.featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 172,
              child: ProductCard(product: products.featured[i]),
            ),
          ),
        ),
      ),
      if (popular.isNotEmpty) ...[
        const SliverToBoxAdapter(child: SectionHeader(title: 'Popular right now')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: productGridDelegate,
            delegate: SliverChildBuilderDelegate(
              (_, i) => FadeSlideIn(
                key: ValueKey(popular[i].id),
                delay: Duration(milliseconds: 60 * (i % 4)),
                child: ProductCard(product: popular[i]),
              ),
              childCount: popular.length,
            ),
          ),
        ),
      ],
    ];
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final firstName = context.select<AuthProvider, String>((a) => a.user?.firstName ?? '');
    final wishlistCount = context.select<WishlistProvider, int>((w) => w.items.length);
    final cartCount = context.select<CartProvider, int>((c) => c.totalItems);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${firstName.isEmpty ? 'there' : firstName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                const Text(
                  'What are you shopping for today?',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          _HeaderIcon(
            icon: Icons.favorite_border,
            count: wishlistCount,
            tooltip: 'Wishlist',
            onTap: () => mainTabIndex.value = AppTab.wishlist,
          ),
          const SizedBox(width: 10),
          _HeaderIcon(
            icon: Icons.shopping_bag_outlined,
            count: cartCount,
            tooltip: 'Cart',
            onTap: () => mainTabIndex.value = AppTab.cart,
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.count,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ScaleTap(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: ScaleTap(
        scale: 0.98,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.productList,
          arguments: const ProductListArgs(focusSearch: true),
        ),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.textSecondary),
              SizedBox(width: 12),
              Text('Search products', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEW SEASON',
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Discover your next favourite find',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.productList),
                    child: const Text('Shop now'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.shopping_bag_outlined, size: 84, color: Color(0x40FFFFFF)),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 150, height: 20),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Padding(padding: EdgeInsets.only(right: 12), child: ShimmerBox(height: 100, radius: 18))),
              Expanded(child: Padding(padding: EdgeInsets.only(right: 12), child: ShimmerBox(height: 100, radius: 18))),
              Expanded(child: Padding(padding: EdgeInsets.only(right: 12), child: ShimmerBox(height: 100, radius: 18))),
              Expanded(child: ShimmerBox(height: 100, radius: 18)),
            ],
          ),
          SizedBox(height: 28),
          ShimmerBox(width: 170, height: 20),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Padding(padding: EdgeInsets.only(right: 12), child: SizedBox(height: 250, child: ShimmerBox(radius: 18)))),
              Expanded(child: SizedBox(height: 250, child: ShimmerBox(radius: 18))),
            ],
          ),
        ],
      ),
    );
  }
}
