import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  int? _userId;
  bool _isSending = false;

  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;

  void setUser(int? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (userId != null) {
        loadMessages();
      } else {
        _messages = [];
        notifyListeners();
      }
    }
  }

  Future<void> loadMessages() async {
    if (_userId == null) return;
    _messages = await DatabaseService.instance.getMessagesByUser(_userId!);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_userId == null || content.trim().isEmpty || _isSending) return;
    _isSending = true;
    notifyListeners();

    final userMessage = await DatabaseService.instance.sendMessage(
      userId: _userId!,
      content: content.trim(),
      isFromUser: true,
    );
    _messages = [..._messages, userMessage];
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));
    final reply = _buildSupportReply(content.trim());
    final supportMessage = await DatabaseService.instance.sendMessage(
      userId: _userId!,
      content: reply,
      isFromUser: false,
    );
    _messages = [..._messages, supportMessage];
    _isSending = false;
    notifyListeners();
  }

  String _buildSupportReply(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('order') || lower.contains('shipping')) {
      return 'Thanks for reaching out! Please check My Orders for the latest status, or share your order ID and we will assist you.';
    }
    if (lower.contains('return') || lower.contains('refund')) {
      return 'Our return policy allows returns within 14 days. Visit any PopiDigicam store or reply with your order details.';
    }
    if (lower.contains('price') || lower.contains('sale') || lower.contains('discount')) {
      return 'Great timing! Check the Home screen for flash sales, or visit Store Locations for in-store promotions.';
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('xin chao')) {
      return 'Hello! Welcome to PopiDigicam Support. Ask us about orders, products, returns, or store locations anytime.';
    }
    return 'Thank you for your message! A support agent will follow up shortly. For urgent order issues, include your order ID.';
  }
}
