import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/cart_item.dart';
import '../models/app_notification.dart';
import '../models/store_location.dart';
import '../models/chat_message.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _db;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path;
    if (kIsWeb) {
      databaseFactory = createDatabaseFactoryFfiWeb(
        options: SqfliteFfiWebOptions(inMemory: true),
      );
      path = 'popishop.db';
    } else {
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      path = join(await getDatabasesPath(), 'popishop.db');
    }
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createExtendedTables(db);
      await _seedExtendedData(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'user',
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        brand TEXT,
        category TEXT,
        description TEXT,
        price REAL NOT NULL,
        sale_price REAL,
        stock INTEGER DEFAULT 0,
        image_url TEXT,
        rating REAL DEFAULT 0,
        reviews INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        shipping REAL DEFAULT 10,
        tax REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT DEFAULT 'Pending',
        address TEXT,
        payment_method TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        label TEXT,
        detail TEXT,
        is_default INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        label TEXT,
        detail TEXT,
        icon TEXT DEFAULT 'card',
        is_default INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        UNIQUE(user_id, product_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        created_at TEXT DEFAULT (datetime('now')),
        UNIQUE(user_id, product_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await _createExtendedTables(db);
    await _seedData(db);
    await _seedExtendedData(db);
  }

  Future<void> _createExtendedTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT DEFAULT 'system',
        is_read INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        phone TEXT,
        hours TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        is_from_user INTEGER DEFAULT 1,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _seedExtendedData(Database db) async {
    final storeCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM stores'),
    );
    if ((storeCount ?? 0) == 0) {
      final stores = [
        {
          'name': 'PopiDigicam Hanoi',
          'address': '12 Hang Bai, Hoan Kiem, Hanoi',
          'latitude': 21.0285,
          'longitude': 105.8542,
          'phone': '+84 24 3825 1234',
          'hours': 'Mon–Sat 9:00–21:00',
        },
        {
          'name': 'PopiDigicam Ho Chi Minh',
          'address': '45 Nguyen Hue, District 1, Ho Chi Minh City',
          'latitude': 10.7769,
          'longitude': 106.7009,
          'phone': '+84 28 3822 5678',
          'hours': 'Mon–Sun 9:00–22:00',
        },
        {
          'name': 'PopiDigicam Da Nang',
          'address': '88 Bach Dang, Hai Chau, Da Nang',
          'latitude': 16.0544,
          'longitude': 108.2022,
          'phone': '+84 236 388 9012',
          'hours': 'Mon–Sat 9:00–20:00',
        },
      ];
      for (final store in stores) {
        await db.insert('stores', store);
      }
    }

    final user = await db.query('users', where: 'email = ?', whereArgs: ['user@gmail.com']);
    if (user.isNotEmpty) {
      final userId = user.first['id'] as int;
      final notifCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM notifications WHERE user_id = ?', [userId]),
      );
      if ((notifCount ?? 0) == 0) {
        await db.insert('notifications', {
          'user_id': userId,
          'title': 'Welcome to PopiDigicam!',
          'body': 'Explore our latest digital cameras and exclusive deals.',
          'type': 'system',
        });
        await db.insert('notifications', {
          'user_id': userId,
          'title': 'Flash Sale!',
          'body': 'Up to 40% off on selected cameras today only!',
          'type': 'promo',
        });
      }

      final msgCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM messages WHERE user_id = ?', [userId]),
      );
      if ((msgCount ?? 0) == 0) {
        await db.insert('messages', {
          'user_id': userId,
          'content': 'Hi! Welcome to PopiDigicam Support. How can we help you today?',
          'is_from_user': 0,
        });
      }
    }
  }

  Future<void> _seedData(Database db) async {
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'role': 'admin',
    });
    await db.insert('users', {
      'name': 'Test User',
      'email': 'user@gmail.com',
      'password': 'user123',
      'role': 'user',
    });

    final products = [
      {
        'name': 'Canon IXY',
        'brand': 'Canon',
        'category': 'Instant Cameras',
        'description':
            'Compact digital camera with great image quality and easy-to-use features.',
        'price': 249.99,
        'sale_price': 199.99,
        'stock': 50,
        'image_url': 'CanonIXY.jpg',
        'rating': 4.6,
        'reviews': 128,
      },
      {
        'name': 'Canon IXY 620F',
        'brand': 'Canon',
        'category': 'Instant Cameras',
        'description':
            'Advanced compact camera with Wi-Fi connectivity and stunning picture quality.',
        'price': 299.99,
        'sale_price': 249.99,
        'stock': 30,
        'image_url': 'CanonIXY620F.jpg',
        'rating': 4.7,
        'reviews': 95,
      },
      {
        'name': 'Canon PowerShot',
        'brand': 'Canon',
        'category': 'DSLR',
        'description':
            'Professional-grade DSLR camera with advanced autofocus and 4K video recording.',
        'price': 349.99,
        'sale_price': 299.99,
        'stock': 20,
        'image_url': 'CanonPowershot.jpg',
        'rating': 4.8,
        'reviews': 210,
      },
      {
        'name': 'Casio Exilim',
        'brand': 'Casio',
        'category': 'Instant Cameras',
        'description':
            'Slim and stylish camera with built-in beauty features and easy sharing options.',
        'price': 179.99,
        'sale_price': 149.99,
        'stock': 15,
        'image_url': 'CasioExilim.jpg',
        'rating': 4.5,
        'reviews': 67,
      },
      {
        'name': 'Nikon Coolpix A100',
        'brand': 'Nikon',
        'category': 'DSLR',
        'description':
            'Entry-level DSLR with excellent image quality and versatile shooting modes.',
        'price': 229.99,
        'sale_price': null,
        'stock': 40,
        'image_url': 'NikonCoolpixA100.jpg',
        'rating': 4.4,
        'reviews': 89,
      },
      {
        'name': 'Panasonic Lumix',
        'brand': 'Panasonic',
        'category': 'Mirrorless',
        'description':
            'High-performance mirrorless camera with exceptional video capabilities and 4K recording.',
        'price': 449.99,
        'sale_price': 399.99,
        'stock': 25,
        'image_url': 'PanasonicLumix.jpg',
        'rating': 4.7,
        'reviews': 156,
      },
      {
        'name': 'Fujifilm FinePix',
        'brand': 'Fujifilm',
        'category': 'Instant Cameras',
        'description':
            'Classic Fujifilm design with modern digital capabilities and film simulation modes.',
        'price': 159.99,
        'sale_price': null,
        'stock': 35,
        'image_url': 'fujifilm.png',
        'rating': 4.3,
        'reviews': 44,
      },
    ];

    for (final p in products) {
      await db.insert('products', p);
    }
  }

  // ─── USER ───────────────────────────────────────────────────────────────────

  Future<UserModel?> getUserByEmail(String email) async {
    final database = await db;
    final result = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final database = await db;
    final result = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel> createUser(
    String name,
    String email,
    String password,
  ) async {
    final database = await db;
    final id = await database.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'role': 'user',
    });
    await addNotification(
      userId: id,
      title: 'Welcome to PopiDigicam!',
      body: 'Thanks for joining! Start exploring our camera collection.',
      type: 'system',
    );
    await sendMessage(
      userId: id,
      content: 'Hi $name! Welcome to PopiDigicam Support. How can we help you today?',
      isFromUser: false,
    );
    return (await getUserById(id))!;
  }

  Future<int> getUserCount() async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE role = ?',
      ['user'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // ─── PRODUCTS ───────────────────────────────────────────────────────────────

  Future<List<Product>> getAllProducts() async {
    final database = await db;
    final result = await database.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return result.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final database = await db;
    final result = await database.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Product.fromMap(result.first);
  }

  Future<int> addProduct(Map<String, dynamic> data) async {
    final database = await db;
    return database.insert('products', data);
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    final database = await db;
    await database.update('products', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProduct(int id) async {
    final database = await db;
    await database.update(
      'products',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── ORDERS ─────────────────────────────────────────────────────────────────

  Future<List<Order>> getOrdersByUser(int userId) async {
    final database = await db;
    final result = await database.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    final orders = result.map((m) => Order.fromMap(m)).toList();
    for (final order in orders) {
      order.items = await getOrderItems(order.id);
    }
    return orders;
  }

  Future<List<Order>> getAllOrders() async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT o.*, u.name as customer_name FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      ORDER BY o.created_at DESC
    ''');
    final orders = result.map((m) => Order.fromMap(m)).toList();
    for (final order in orders) {
      order.items = await getOrderItems(order.id);
    }
    return orders;
  }

  Future<Order?> getOrderById(int id) async {
    final database = await db;
    final result = await database.rawQuery(
      '''
      SELECT o.*, u.name as customer_name FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      WHERE o.id = ?
    ''',
      [id],
    );
    if (result.isEmpty) return null;
    final order = Order.fromMap(result.first);
    order.items = await getOrderItems(id);
    return order;
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final database = await db;
    final result = await database.rawQuery(
      '''
      SELECT oi.*, p.name as product_name, p.image_url FROM order_items oi
      LEFT JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
    ''',
      [orderId],
    );
    return result.map((m) => OrderItem.fromMap(m)).toList();
  }

  Future<int> createOrder({
    required int userId,
    required double subtotal,
    required double shipping,
    required double tax,
    required double total,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final database = await db;
    final orderId = await database.insert('orders', {
      'user_id': userId,
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'status': 'Pending',
      'address': address,
      'payment_method': paymentMethod,
    });
    for (final item in items) {
      await database.insert('order_items', {
        'order_id': orderId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }
    await addNotification(
      userId: userId,
      title: 'Order Placed!',
      body: 'Your order ORD-${orderId.toString().padLeft(4, '0')} has been placed successfully.',
      type: 'order',
    );
    return orderId;
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final database = await db;
    final order = await getOrderById(orderId);
    await database.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
    if (order != null) {
      await _notifyOrderStatusChange(order.userId, orderId, status);
    }
  }

  Future<void> _notifyOrderStatusChange(int userId, int orderId, String status) async {
    final orderLabel = 'ORD-${orderId.toString().padLeft(4, '0')}';
    String title;
    String body;
    switch (status) {
      case 'Processing':
        title = 'Order Processing';
        body = 'Your order $orderLabel is being processed.';
        break;
      case 'Shipped':
        title = 'Order Shipped!';
        body = 'Your order $orderLabel has been shipped.';
        break;
      case 'Delivered':
        title = 'Order Delivered';
        body = 'Your order $orderLabel has been delivered.';
        break;
      case 'Completed':
        title = 'Order Completed';
        body = 'Your order $orderLabel is complete. Thank you for shopping!';
        break;
      case 'Cancelled':
        title = 'Order Cancelled';
        body = 'Your order $orderLabel has been cancelled.';
        break;
      default:
        title = 'Order Updated';
        body = 'Your order $orderLabel status is now $status.';
    }
    await addNotification(userId: userId, title: title, body: body, type: 'order');
  }

  Future<Map<String, dynamic>> getRevenueStats() async {
    final database = await db;
    final revenueResult = await database.rawQuery(
      "SELECT COALESCE(SUM(total), 0) as total FROM orders WHERE status != 'Cancelled'",
    );
    final ordersResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM orders',
    );
    final productsResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE is_active = 1',
    );
    final customersResult = await database.rawQuery(
      "SELECT COUNT(*) as count FROM users WHERE role = 'user'",
    );
    return {
      'revenue': (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0,
      'orders': (ordersResult.first['count'] as int?) ?? 0,
      'products': (productsResult.first['count'] as int?) ?? 0,
      'customers': (customersResult.first['count'] as int?) ?? 0,
    };
  }

  // ─── ADDRESSES ──────────────────────────────────────────────────────────────

  Future<List<Address>> getAddressesByUser(int userId) async {
    final database = await db;
    final result = await database.query(
      'addresses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((m) => Address.fromMap(m)).toList();
  }

  Future<void> addAddress(int userId, String label, String detail) async {
    final database = await db;
    final existing = await getAddressesByUser(userId);
    await database.insert('addresses', {
      'user_id': userId,
      'label': label,
      'detail': detail,
      'is_default': existing.isEmpty ? 1 : 0,
    });
  }

  Future<void> deleteAddress(int id) async {
    final database = await db;
    await database.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  // ─── PAYMENT METHODS ─────────────────────────────────────────────────────────

  Future<List<PaymentMethod>> getPaymentMethodsByUser(int userId) async {
    final database = await db;
    final result = await database.query(
      'payment_methods',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((m) => PaymentMethod.fromMap(m)).toList();
  }

  Future<void> addPaymentMethod(
    int userId,
    String label,
    String detail,
    String icon,
  ) async {
    final database = await db;
    final existing = await getPaymentMethodsByUser(userId);
    await database.insert('payment_methods', {
      'user_id': userId,
      'label': label,
      'detail': detail,
      'icon': icon,
      'is_default': existing.isEmpty ? 1 : 0,
    });
  }

  Future<void> deletePaymentMethod(int id) async {
    final database = await db;
    await database.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }

  // ─── WISHLIST ────────────────────────────────────────────────────────────────

  Future<List<Product>> getWishlistByUser(int userId) async {
    final database = await db;
    final result = await database.rawQuery(
      '''
      SELECT p.* FROM wishlist w
      JOIN products p ON w.product_id = p.id
      WHERE w.user_id = ? AND p.is_active = 1
    ''',
      [userId],
    );
    return result.map((m) => Product.fromMap(m)).toList();
  }

  Future<bool> isInWishlist(int userId, int productId) async {
    final database = await db;
    final result = await database.query(
      'wishlist',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    return result.isNotEmpty;
  }

  Future<void> addToWishlist(int userId, int productId) async {
    final database = await db;
    await database.insert('wishlist', {
      'user_id': userId,
      'product_id': productId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFromWishlist(int userId, int productId) async {
    final database = await db;
    await database.delete(
      'wishlist',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  // ─── CART ────────────────────────────────────────────────────────────────────

  Future<List<CartItem>> getCartByUser(int userId) async {
    final database = await db;
    final result = await database.rawQuery(
      '''
      SELECT ci.*, p.name, p.price, p.sale_price, p.image_url, p.brand, p.category,
             p.description, p.stock, p.rating, p.reviews, p.is_active, p.created_at
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
      WHERE ci.user_id = ?
    ''',
      [userId],
    );
    return result.map((m) {
      final item = CartItem(
        id: m['id'] as int,
        userId: m['user_id'] as int,
        productId: m['product_id'] as int,
        quantity: m['quantity'] as int,
      );
      item.product = Product.fromMap({
        'id': m['product_id'],
        'name': m['name'],
        'brand': m['brand'],
        'category': m['category'],
        'description': m['description'],
        'price': m['price'],
        'sale_price': m['sale_price'],
        'stock': m['stock'],
        'image_url': m['image_url'],
        'rating': m['rating'],
        'reviews': m['reviews'],
        'is_active': m['is_active'],
        'created_at': m['created_at'],
      });
      return item;
    }).toList();
  }

  Future<void> addToCart(int userId, int productId, {int quantity = 1}) async {
    final database = await db;
    final existing = await database.query(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    if (existing.isNotEmpty) {
      final newQty = (existing.first['quantity'] as int) + quantity;
      await database.update(
        'cart_items',
        {'quantity': newQty},
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    } else {
      await database.insert('cart_items', {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateCartQuantity(
    int userId,
    int productId,
    int quantity,
  ) async {
    final database = await db;
    await database.update(
      'cart_items',
      {'quantity': quantity},
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<void> removeFromCart(int userId, int productId) async {
    final database = await db;
    await database.delete(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<void> clearCart(int userId) async {
    final database = await db;
    await database.delete(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ─── NOTIFICATIONS ───────────────────────────────────────────────────────────

  Future<List<AppNotification>> getNotificationsByUser(int userId) async {
    final database = await db;
    final result = await database.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((m) => AppNotification.fromMap(m)).toList();
  }

  Future<int> getUnreadNotificationCount(int userId) async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> addNotification({
    required int userId,
    required String title,
    required String body,
    String type = 'system',
  }) async {
    final database = await db;
    await database.insert('notifications', {
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
    });
  }

  Future<void> markNotificationRead(int id) async {
    final database = await db;
    await database.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllNotificationsRead(int userId) async {
    final database = await db;
    await database.update(
      'notifications',
      {'is_read': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ─── STORES ──────────────────────────────────────────────────────────────────

  Future<List<StoreLocation>> getAllStores() async {
    final database = await db;
    final result = await database.query(
      'stores',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((m) => StoreLocation.fromMap(m)).toList();
  }

  Future<StoreLocation?> getStoreById(int id) async {
    final database = await db;
    final result = await database.query(
      'stores',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return StoreLocation.fromMap(result.first);
  }

  // ─── MESSAGES ────────────────────────────────────────────────────────────────

  Future<List<ChatMessage>> getMessagesByUser(int userId) async {
    final database = await db;
    final result = await database.query(
      'messages',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    return result.map((m) => ChatMessage.fromMap(m)).toList();
  }

  Future<ChatMessage> sendMessage({
    required int userId,
    required String content,
    required bool isFromUser,
  }) async {
    final database = await db;
    final id = await database.insert('messages', {
      'user_id': userId,
      'content': content,
      'is_from_user': isFromUser ? 1 : 0,
    });
    final result = await database.query('messages', where: 'id = ?', whereArgs: [id]);
    return ChatMessage.fromMap(result.first);
  }
}
