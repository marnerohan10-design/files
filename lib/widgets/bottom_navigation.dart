import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartProvider, int>((c) => c.totalItems);
    final wishlistCount = context.select<WishlistProvider, int>((w) => w.items.length);

    Widget badged(IconData icon, int count) {
      return Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: Icon(icon),
      );
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Categories',
        ),
        NavigationDestination(
          icon: badged(Icons.favorite_border, wishlistCount),
          selectedIcon: badged(Icons.favorite, wishlistCount),
          label: 'Wishlist',
        ),
        NavigationDestination(
          icon: badged(Icons.shopping_bag_outlined, cartCount),
          selectedIcon: badged(Icons.shopping_bag, cartCount),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
