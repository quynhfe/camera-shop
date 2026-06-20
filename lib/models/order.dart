class Order {
  final int id;
  final int userId;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  String status;
  final String address;
  final String paymentMethod;
  final String createdAt;
  List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    this.items = const [],
  });

  String get orderId => 'ORD-${id.toString().padLeft(4, '0')}';

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      subtotal: (map['subtotal'] as num).toDouble(),
      shipping: (map['shipping'] as num?)?.toDouble() ?? 10.0,
      tax: (map['tax'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      status: (map['status'] as String?) ?? 'Pending',
      address: (map['address'] as String?) ?? '',
      paymentMethod: (map['payment_method'] as String?) ?? '',
      createdAt: (map['created_at'] as String?) ?? '',
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  String? productName;
  String? productImage;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.productImage,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int,
      orderId: map['order_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      productName: map['product_name'] as String?,
      productImage: map['image_url'] as String?,
    );
  }
}
