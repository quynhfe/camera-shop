import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  List<Product> _items = [];
  int? _userId;

  List<Product> get items => _items;
  int get count => _items.length;

  bool isSaved(int productId) => _items.any((p) => p.id == productId);

  void setUser(int? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (userId != null) {
        loadWishlist();
      } else {
        _items = [];
        notifyListeners();
      }
    }
  }

  Future<void> loadWishlist() async {
    if (_userId == null) return;
    _items = await DatabaseService.instance.getWishlistByUser(_userId!);
    notifyListeners();
  }

  Future<void> toggle(int productId) async {
    if (_userId == null) return;
    if (isSaved(productId)) {
      _items.removeWhere((p) => p.id == productId);
      notifyListeners();
      try {
        await DatabaseService.instance.removeFromWishlist(_userId!, productId);
      } catch (_) {
        await loadWishlist();
      }
    } else {
      try {
        await DatabaseService.instance.addToWishlist(_userId!, productId);
        await loadWishlist();
      } catch (_) {}
    }
  }
}
