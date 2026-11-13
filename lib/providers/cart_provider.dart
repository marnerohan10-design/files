import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._storage);

  final StorageService _storage;
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  int quantityOf(int productId) {
    final index = _items.indexWhere((i) => i.productId == productId);
    return index == -1 ? 0 : _items[index].quantity;
  }

  /// Restores the saved cart. Called once at startup.
  void load() {
    _items.clear();
    for (final json in _storage.readJsonList(StorageService.cartKey)) {
      try {
        _items.add(CartItemModel.fromJson(json));
      } catch (_) {
        // skip an entry that can't be read
      }
    }
  }

  void add(ProductModel product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.productId == product.id);
    if (index == -1) {
      _items.add(CartItemModel.fromProduct(product, quantity));
    } else {
      final newQuantity = (_items[index].quantity + quantity).clamp(1, AppConstants.maxQuantity).toInt();
      _items[index] = _items[index].copyWith(quantity: newQuantity);
    }
    _changed();
  }

  void increase(int productId) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index == -1 || _items[index].quantity >= AppConstants.maxQuantity) return;
    _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    _changed();
  }

  void decrease(int productId) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index == -1 || _items[index].quantity <= 1) return;
    _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
    _changed();
  }

  void remove(int productId) {
    _items.removeWhere((i) => i.productId == productId);
    _changed();
  }

  void clear() {
    _items.clear();
    _changed();
  }

  void _changed() {
    notifyListeners();
    unawaited(
      _storage.writeJsonList(
        StorageService.cartKey,
        _items.map((i) => i.toJson()).toList(),
      ),
    );
  }
}
