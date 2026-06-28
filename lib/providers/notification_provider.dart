import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _items = [];
  int? _userId;

  List<AppNotification> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  void setUser(int? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (userId != null) {
        loadNotifications();
      } else {
        _items = [];
        notifyListeners();
      }
    }
  }

  Future<void> loadNotifications() async {
    if (_userId == null) return;
    _items = await DatabaseService.instance.getNotificationsByUser(_userId!);
    notifyListeners();
  }

  Future<void> markRead(int id) async {
    await DatabaseService.instance.markNotificationRead(id);
    final index = _items.indexWhere((n) => n.id == id);
    if (index != -1) {
      final n = _items[index];
      _items[index] = AppNotification(
        id: n.id,
        userId: n.userId,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (_userId == null) return;
    await DatabaseService.instance.markAllNotificationsRead(_userId!);
    _items = _items
        .map((n) => AppNotification(
              id: n.id,
              userId: n.userId,
              title: n.title,
              body: n.body,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            ))
        .toList();
    notifyListeners();
  }
}
