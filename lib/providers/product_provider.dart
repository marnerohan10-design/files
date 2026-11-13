import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

enum LoadStatus { idle, loading, loaded, error }

enum SortOption {
  none('Relevance'),
  priceLowHigh('Price: low to high'),
  priceHighLow('Price: high to low'),
  topRated('Top rated');

  const SortOption(this.label);
  final String label;
}

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._api);

  final ApiService _api;

  static const allCategories = 'All';

  // Home dashboard data
  LoadStatus _homeStatus = LoadStatus.idle;
  String? _homeError;
  List<ProductModel> _allProducts = const [];
  List<String> _categories = const [];

  // Listing screen data
  LoadStatus _listStatus = LoadStatus.idle;
  String? _listError;
  List<ProductModel> _categoryProducts = const [];
  String _selectedCategory = allCategories;
  String _query = '';
  SortOption _sort = SortOption.none;
  int _listRequestId = 0;

  LoadStatus get homeStatus => _homeStatus;
  String? get homeError => _homeError;
  List<ProductModel> get allProducts => _allProducts;
  List<String> get categories => _categories;

  LoadStatus get listStatus => _listStatus;
  String? get listError => _listError;
  String get selectedCategory => _selectedCategory;
  String get query => _query;
  SortOption get sort => _sort;

  /// Products on the listing screen after category (API), search and sort.
  List<ProductModel> get visibleProducts {
    final q = _query.trim().toLowerCase();
    final items = _categoryProducts.where((p) {
      return q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case SortOption.priceLowHigh:
        items.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHighLow:
        items.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.topRated:
        items.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.none:
        break;
    }
    return items;
  }

  List<ProductModel> get featured {
    final sorted = [..._allProducts]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  }

  List<ProductModel> get popular {
    final featuredIds = featured.map((p) => p.id).toSet();
    final sorted = _allProducts.where((p) => !featuredIds.contains(p.id)).toList()
      ..sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
    return sorted.take(6).toList();
  }

  int countForCategory(String category) {
    return _allProducts.where((p) => p.category == category).length;
  }

  /// Loads products and categories for the home and categories screens.
  Future<void> loadHome() async {
    _homeStatus = LoadStatus.loading;
    _homeError = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        _api.getProducts(),
        _api.getCategories(),
      ]);
      _allProducts = results[0] as List<ProductModel>;
      _categories = results[1] as List<String>;
      _homeStatus = LoadStatus.loaded;

      if (_selectedCategory == allCategories) {
        _categoryProducts = _allProducts;
        _listStatus = LoadStatus.loaded;
        _listError = null;
      }
    } on ApiException catch (e) {
      _homeStatus = LoadStatus.error;
      _homeError = e.message;
    } catch (_) {
      _homeStatus = LoadStatus.error;
      _homeError = 'Something went wrong. Please try again.';
    }
    notifyListeners();
  }

  /// Called when the listing screen opens: clears search/sort and applies a category.
  Future<void> openListing({String? category}) {
    _query = '';
    _sort = SortOption.none;
    return selectCategory(category ?? allCategories);
  }

  Future<void> selectCategory(String category) async {
    _selectedCategory = category;
    final requestId = ++_listRequestId;

    if (category == allCategories && _allProducts.isNotEmpty) {
      _categoryProducts = _allProducts;
      _listStatus = LoadStatus.loaded;
      _listError = null;
      notifyListeners();
      return;
    }

    _listStatus = LoadStatus.loading;
    _listError = null;
    notifyListeners();

    try {
      final products = category == allCategories
          ? await _api.getProducts()
          : await _api.getByCategory(category);
      if (requestId != _listRequestId) return; // a newer request replaced this one
      _categoryProducts = products;
      if (category == allCategories) _allProducts = products;
      _listStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      if (requestId != _listRequestId) return;
      _listStatus = LoadStatus.error;
      _listError = e.message;
    } catch (_) {
      if (requestId != _listRequestId) return;
      _listStatus = LoadStatus.error;
      _listError = 'Something went wrong. Please try again.';
    }
    notifyListeners();
  }

  Future<void> retryList() => selectCategory(_selectedCategory);

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setSort(SortOption option) {
    _sort = option;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _sort = SortOption.none;
    selectCategory(allCategories);
  }

  Future<ProductModel> fetchProductDetails(int id) => _api.getProduct(id);
}
