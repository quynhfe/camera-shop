class Product {
  final int id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final double? salePrice;
  final int stock;
  final String imageUrl;
  final double rating;
  final int reviews;
  final bool isActive;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    this.salePrice,
    required this.stock,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.isActive,
    required this.createdAt,
  });

  double get displayPrice => salePrice ?? price;
  bool get onSale => salePrice != null && salePrice! > 0;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      name: map['name'] as String,
      brand: (map['brand'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      price: (map['price'] as num).toDouble(),
      salePrice: map['sale_price'] != null ? (map['sale_price'] as num).toDouble() : null,
      stock: (map['stock'] as int?) ?? 0,
      imageUrl: (map['image_url'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (map['reviews'] as int?) ?? 0,
      isActive: ((map['is_active'] as int?) ?? 1) == 1,
      createdAt: (map['created_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'price': price,
      'sale_price': salePrice,
      'stock': stock,
      'image_url': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }
}
