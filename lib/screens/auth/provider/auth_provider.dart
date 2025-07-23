import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userType = '';
  String get userType => _userType;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _userType = prefs.getString('user_type') ?? '';
    notifyListeners();
  }

  Future<void> loginCitizen({
    required String name,
    required String nationalId,
    required String cardId,
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_type', 'citizen');
    await prefs.setString('user_name', name);
    await prefs.setString('user_national_id', nationalId);
    await prefs.setString('user_card_id', cardId);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_password', password);

    _isLoggedIn = true;
    _userType = 'citizen';
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // أو فقط احذف القيم الخاصة
    _isLoggedIn = false;
    _userType = '';
    notifyListeners();
  }
}
