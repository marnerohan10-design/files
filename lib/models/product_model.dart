class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  /// Parses one FakeStore product. Missing optional fields get safe defaults;
  /// a missing id is treated as an invalid response.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! num) {
      throw const FormatException('Product is missing an id');
    }
    final rating = json['rating'];
    return ProductModel(
      id: id.toInt(),
      title: (json['title'] ?? 'Untitled product').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'other').toString(),
      image: (json['image'] ?? '').toString(),
      rating: rating is Map ? ((rating['rate'] as num?)?.toDouble() ?? 0) : 0,
      ratingCount: rating is Map ? ((rating['count'] as num?)?.toInt() ?? 0) : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
        'rating': {'rate': rating, 'count': ratingCount},
      };
}
