import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to continue shopping.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    mainTabIndex.value = AppTab.home;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shopping_bag_rounded, size: 40, color: AppColors.secondary),
      children: const [
        SizedBox(height: 12),
        Text(
          'Built for the Sankar Group Flutter internship assignment.\n\n'
          'Products come from the FakeStore API. Login, cart and wishlist are stored '
          'on this device only (demo).',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final wishlistCount = context.select<WishlistProvider, int>((w) => w.items.length);
    final cartCount = context.select<CartProvider, int>((c) => c.totalItems);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Guest',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      if (user != null && user.phone.isNotEmpty)
                        Text(
                          user.phone,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CustomButton(
            label: 'Edit profile',
            icon: Icons.edit_outlined,
            outlined: true,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          const SizedBox(height: 20),
          _ProfileTile(
            icon: Icons.receipt_long_outlined,
            title: 'My orders',
            subtitle: 'Demo placeholder',
            onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
          ),
          _ProfileTile(
            icon: Icons.favorite_border,
            title: 'Wishlist',
            subtitle: '$wishlistCount saved',
            onTap: () => mainTabIndex.value = AppTab.wishlist,
          ),
          _ProfileTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Cart',
            subtitle: '$cartCount items',
            onTap: () => mainTabIndex.value = AppTab.cart,
          ),
          _ProfileTile(
            icon: Icons.info_outline,
            title: 'About ShopEase',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.logout,
            title: 'Log out',
            color: AppColors.error,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color == AppColors.error ? color : AppColors.secondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
