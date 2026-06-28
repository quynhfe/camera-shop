import '../database/database_service.dart';
import '../models/app_notification.dart';
import '../models/cart_item.dart';
import '../models/chat_message.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/store_location.dart';
import '../models/user.dart';

/// Local API facade mirroring a REST backend structure.
///
/// Endpoint map (would map to HTTP in production):
/// - POST   /auth/login
/// - POST   /auth/register
/// - GET    /products
/// - GET    /products/:id
/// - GET    /cart
/// - POST   /cart/items
/// - POST   /orders
/// - GET    /orders
/// - GET    /notifications
/// - PATCH  /notifications/:id/read
/// - GET    /stores
/// - GET    /messages
/// - POST   /messages
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _db = DatabaseService.instance;

  // POST /auth/login
  Future<UserModel?> login(String email, String password) =>
      _db.getUserByEmail(email).then((user) {
        if (user == null || user.password != password) return null;
        return user;
      });

  // POST /auth/register
  Future<UserModel> register(String name, String email, String password) =>
      _db.createUser(name, email, password);

  // GET /products
  Future<List<Product>> getProducts() => _db.getAllProducts();

  // GET /products/:id
  Future<Product?> getProduct(int id) => _db.getProductById(id);

  // GET /cart
  Future<List<CartItem>> getCart(int userId) => _db.getCartByUser(userId);

  // POST /orders
  Future<int> createOrder({
    required int userId,
    required double subtotal,
    required double shipping,
    required double tax,
    required double total,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) =>
      _db.createOrder(
        userId: userId,
        subtotal: subtotal,
        shipping: shipping,
        tax: tax,
        total: total,
        address: address,
        paymentMethod: paymentMethod,
        items: items,
      );

  // GET /orders
  Future<List<Order>> getOrders(int userId) => _db.getOrdersByUser(userId);

  // PATCH /orders/:id/status
  Future<void> updateOrderStatus(int orderId, String status) =>
      _db.updateOrderStatus(orderId, status);

  // GET /notifications
  Future<List<AppNotification>> getNotifications(int userId) =>
      _db.getNotificationsByUser(userId);

  // PATCH /notifications/:id/read
  Future<void> markNotificationRead(int id) => _db.markNotificationRead(id);

  // PATCH /notifications/read-all
  Future<void> markAllNotificationsRead(int userId) =>
      _db.markAllNotificationsRead(userId);

  // GET /stores
  Future<List<StoreLocation>> getStores() => _db.getAllStores();

  // GET /messages
  Future<List<ChatMessage>> getMessages(int userId) =>
      _db.getMessagesByUser(userId);

  // POST /messages
  Future<ChatMessage> sendMessage({
    required int userId,
    required String content,
    bool isFromUser = true,
  }) =>
      _db.sendMessage(
        userId: userId,
        content: content,
        isFromUser: isFromUser,
      );
}
