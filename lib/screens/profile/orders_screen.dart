import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';

/// Placeholder screen: ShopEase has no order backend, so checkout is a demo.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Demo feature: FakeStore has no orders or payment API, so checkout in this app '
              'only clears the cart. In a real product, orders would be saved on a backend '
              'and listed here.',
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
            ),
          ),
          const Expanded(
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Orders you place will appear here once a backend is connected.',
            ),
          ),
        ],
      ),
    );
  }
}
