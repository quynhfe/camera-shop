import 'package:flutter/material.dart';

enum ToastType { success, warning, error }

class ToastMessage {
  final String message;
  final ToastType type;
  ToastMessage(this.message, this.type);
}

class ToastProvider extends ChangeNotifier {
  ToastMessage? _current;

  ToastMessage? get current => _current;

  void show(String message, {ToastType type = ToastType.success}) {
    _current = ToastMessage(message, type);
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      if (_current?.message == message) {
        _current = null;
        notifyListeners();
      }
    });
  }

  void success(String message) => show(message, type: ToastType.success);
  void warning(String message) => show(message, type: ToastType.warning);
  void error(String message) => show(message, type: ToastType.error);
  void dismiss() {
    _current = null;
    notifyListeners();
  }
}
