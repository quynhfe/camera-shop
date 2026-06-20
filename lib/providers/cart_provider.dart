import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  int? _userId;

  List<CartItem> get items => _items;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void setUser(int? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (userId != null) {
        loadCart();
      } else {
        _items = [];
        notifyListeners();
      }
    }
  }

  Future<void> loadCart() async {
    if (_userId == null) return;
    _items = await DatabaseService.instance.getCartByUser(_userId!);
    notifyListeners();
  }

  Future<void> addToCart(int productId) async {
    if (_userId == null) return;
    await DatabaseService.instance.addToCart(_userId!, productId);
    await loadCart();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (_userId == null) return;
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    await DatabaseService.instance.updateCartQuantity(_userId!, productId, quantity);
    await loadCart();
  }

  Future<void> removeFromCart(int productId) async {
    if (_userId == null) return;
    await DatabaseService.instance.removeFromCart(_userId!, productId);
    await loadCart();
  }

  Future<void> clearCart() async {
    if (_userId == null) return;
    await DatabaseService.instance.clearCart(_userId!);
    _items = [];
    notifyListeners();
  }
}
