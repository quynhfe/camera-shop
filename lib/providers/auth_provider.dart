import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final user = await DatabaseService.instance.getUserById(userId);
      _user = user;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    final user = await DatabaseService.instance.getUserByEmail(email);
    if (user == null || user.password != password) {
      return 'Invalid email or password';
    }
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    notifyListeners();
    return null;
  }

  Future<String?> register(String name, String email, String password) async {
    final existing = await DatabaseService.instance.getUserByEmail(email);
    if (existing != null) {
      return 'Email already in use';
    }
    final user = await DatabaseService.instance.createUser(name, email, password);
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    notifyListeners();
  }

  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remembered_email');
  }

  Future<void> rememberEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remembered_email', email);
  }

  Future<void> clearRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_email');
  }
}
