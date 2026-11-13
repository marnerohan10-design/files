import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/storage_service.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider(this._storage);

  final StorageService _storage;
  final List<ProductModel> _items = [];

  List<ProductModel> get items => List.unmodifiable(_items);

  bool contains(int productId) => _items.any((p) => p.id == productId);

  void load() {
    _items.clear();
    for (final json in _storage.readJsonList(StorageService.wishlistKey)) {
      try {
        _items.add(ProductModel.fromJson(json));
      } catch (_) {
        // skip an entry that can't be read
      }
    }
  }

  /// Adds the product if it is not saved yet, removes it otherwise.
  /// Returns true when the product is now in the wishlist.
  bool toggle(ProductModel product) {
    final index = _items.indexWhere((p) => p.id == product.id);
    final nowSaved = index == -1;
    if (nowSaved) {
      _items.insert(0, product);
    } else {
      _items.removeAt(index);
    }
    _changed();
    return nowSaved;
  }

  void remove(int productId) {
    _items.removeWhere((p) => p.id == productId);
    _changed();
  }

  void _changed() {
    notifyListeners();
    unawaited(
      _storage.writeJsonList(
        StorageService.wishlistKey,
        _items.map((p) => p.toJson()).toList(),
      ),
    );
  }
}
