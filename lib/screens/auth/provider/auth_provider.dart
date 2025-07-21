
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _userToken;
  bool get isAuthenticated => _userToken != null;

  void login(String token) {
    _userToken = token;
    notifyListeners();
  }

  void logout() {
    _userToken = null;
    notifyListeners();
  }
}
