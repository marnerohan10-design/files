import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopease/models/product_model.dart';
import 'package:shopease/providers/cart_provider.dart';
import 'package:shopease/providers/wishlist_provider.dart';
import 'package:shopease/services/storage_service.dart';

const _pen = ProductModel(
  id: 1,
  title: 'Pen',
  price: 10.5,
  description: 'A pen',
  category: 'stationery',
  image: '',
  rating: 4.2,
  ratingCount: 10,
);

const _book = ProductModel(
  id: 2,
  title: 'Book',
  price: 20,
  description: 'A book',
  category: 'stationery',
  image: '',
  rating: 4.8,
  ratingCount: 99,
);

void main() {
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await StorageService.create();
  });

  group('CartProvider', () {
    test('adding the same product twice merges into one line', () {
      final cart = CartProvider(storage)..load();
      cart.add(_pen);
      cart.add(_pen);

      expect(cart.items.length, 1);
      expect(cart.quantityOf(1), 2);
      expect(cart.totalItems, 2);
      expect(cart.totalPrice, closeTo(21.0, 0.001));
    });

    test('total is calculated across several products', () {
      final cart = CartProvider(storage)..load();
      cart.add(_pen, quantity: 2); // 21.0
      cart.add(_book); // 20.0

      expect(cart.totalPrice, closeTo(41.0, 0.001));
      expect(cart.totalItems, 3);
    });

    test('increase, decrease (never below 1) and remove', () {
      final cart = CartProvider(storage)..load();
      cart.add(_pen);
      cart.increase(1);
      expect(cart.quantityOf(1), 2);

      cart.decrease(1);
      cart.decrease(1);
      expect(cart.quantityOf(1), 1);

      cart.remove(1);
      expect(cart.isEmpty, isTrue);
    });

    test('cart is restored from storage after a restart', () async {
      final first = CartProvider(storage)..load();
      first.add(_pen, quantity: 3);
      await Future<void>.delayed(Duration.zero);

      final restarted = CartProvider(storage)..load();
      expect(restarted.items.length, 1);
      expect(restarted.quantityOf(1), 3);
    });

    test('clear empties the cart', () {
      final cart = CartProvider(storage)..load();
      cart.add(_pen);
      cart.clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.totalPrice, 0);
    });
  });

  group('WishlistProvider', () {
    test('toggle adds then removes a product', () {
      final wishlist = WishlistProvider(storage)..load();
      expect(wishlist.toggle(_book), isTrue);
      expect(wishlist.contains(2), isTrue);
      expect(wishlist.toggle(_book), isFalse);
      expect(wishlist.contains(2), isFalse);
    });

    test('wishlist is restored from storage after a restart', () async {
      final first = WishlistProvider(storage)..load();
      first.toggle(_book);
      await Future<void>.delayed(Duration.zero);

      final restarted = WishlistProvider(storage)..load();
      expect(restarted.contains(2), isTrue);
      expect(restarted.items.first.title, 'Book');
    });
  });
}
