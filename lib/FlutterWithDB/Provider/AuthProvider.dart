import 'package:flutter/material.dart';
import '../Service/AuthService.dart';

class AuthProvider extends ChangeNotifier { // Hérite de ChangeNotifier
  final AuthService authService;

  AuthProvider({required this.authService});

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> register(String email, String password) async {
    try {
      await authService.register(email, password);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await authService.login(email, password);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }
}
