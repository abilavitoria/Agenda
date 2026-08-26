import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    // Simula delay de autenticação
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim().isNotEmpty && password.length >= 4) {
      String name = email.split('@').first;
      if (name.isNotEmpty) {
        name = name[0].toUpperCase() + name.substring(1);
      } else {
        name = 'Usuário';
      }

      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email.trim(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().isNotEmpty && email.trim().isNotEmpty && password.length >= 4) {
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email.trim(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
