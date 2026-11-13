import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/models/product_model.dart';

void main() {
  test('parses a FakeStore product', () {
    final product = ProductModel.fromJson({
      'id': 5,
      'title': 'Ring',
      'price': 695,
      'description': 'Nice ring',
      'category': 'jewelery',
      'image': 'https://example.com/a.png',
      'rating': {'rate': 4.6, 'count': 400},
    });

    expect(product.id, 5);
    expect(product.price, 695.0);
    expect(product.rating, 4.6);
    expect(product.ratingCount, 400);
  });

  test('missing optional fields fall back to defaults', () {
    final product = ProductModel.fromJson({'id': 1});
    expect(product.title, 'Untitled product');
    expect(product.image, isEmpty);
    expect(product.rating, 0);
  });

  test('a product without an id is rejected', () {
    expect(() => ProductModel.fromJson({'title': 'x'}), throwsFormatException);
  });

  test('toJson and fromJson round-trip', () {
    const original = ProductModel(
      id: 3,
      title: 'Bag',
      price: 55.5,
      description: 'd',
      category: 'c',
      image: 'i',
      rating: 3.9,
      ratingCount: 12,
    );
    final copy = ProductModel.fromJson(original.toJson());
    expect(copy.id, original.id);
    expect(copy.price, original.price);
    expect(copy.ratingCount, original.ratingCount);
  });
}
