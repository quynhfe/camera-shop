import 'product.dart';

class CartItem {
  final int id;
  final int userId;
  final int productId;
  int quantity;
  Product? product;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  double get price => product?.displayPrice ?? 0.0;
  double get totalPrice => price * quantity;

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
    );
  }
}
