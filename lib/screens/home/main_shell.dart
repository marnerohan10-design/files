import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../providers/product_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'home_screen.dart';

/// Hosts the five bottom-navigation tabs. An IndexedStack keeps every tab
/// alive, so scroll positions and loaded data are preserved when switching.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  static const _pages = <Widget>[
    HomeScreen(),
    CategoriesScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    mainTabIndex.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final products = context.read<ProductProvider>();
      if (products.homeStatus == LoadStatus.idle) products.loadHome();
    });
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {});
    _fade.forward(from: 0);
  }

  @override
  void dispose() {
    mainTabIndex.removeListener(_onTabChanged);
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = mainTabIndex.value;

    // Back from any tab other than Home returns to Home first.
    return PopScope(
      canPop: index == AppTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) mainTabIndex.value = AppTab.home;
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _fade,
          child: IndexedStack(index: index, children: _pages),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: index,
          onSelected: (i) => mainTabIndex.value = i,
        ),
      ),
    );
  }
}
