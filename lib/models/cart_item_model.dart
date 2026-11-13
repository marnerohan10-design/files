import 'product_model.dart';

/// A cart line. It keeps a snapshot of the product so the cart can be shown
/// (and restored after a restart) without calling the API again.
class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    required this.quantity,
  });

  final int productId;
  final String title;
  final double price;
  final String image;
  final String category;
  final int quantity;

  double get subtotal => price * quantity;

  factory CartItemModel.fromProduct(ProductModel product, int quantity) {
    return CartItemModel(
      productId: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      category: product.category,
      quantity: quantity,
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      title: title,
      price: price,
      image: image,
      category: category,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: (json['productId'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      price: (json['price'] as num).toDouble(),
      image: (json['image'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'price': price,
        'image': image,
        'category': category,
        'quantity': quantity,
      };
}
