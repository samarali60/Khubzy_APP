import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _phone;
  String? _userType; // 'citizen' أو 'baker'

  bool get isLoggedIn => _isLoggedIn;
  String? get phone => _phone;
  String? get userType => _userType;

  // تسجيل الدخول
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('user_phone');
    final savedPassword = prefs.getString('user_password');
    final savedUserType = prefs.getString('user_type');

    if (phone == savedPhone && password == savedPassword) {
      _isLoggedIn = true;
      _phone = phone;
      _userType = savedUserType;
      notifyListeners();
      return true;
    }

    return false;
  }

  // تسجيل جديد
  Future<void> signup({
    required String phone,
    required String password,
    required String userType, // 'citizen' أو 'baker'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_password', password);
    await prefs.setString('user_type', userType);

    _isLoggedIn = true;
    _phone = phone;
    _userType = userType;
    notifyListeners();
  }

  // تسجيل الخروج
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', false); // فقط نغير حالة تسجيل الدخول
_phone = null;
_userType = null;
  _isLoggedIn = false;
  notifyListeners();
}


  // تحميل بيانات المستخدم عند بدء التطبيق
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('user_phone');
    final savedUserType = prefs.getString('user_type');

    if (savedPhone != null) {
      _isLoggedIn = true;
      _phone = savedPhone;
      _userType = savedUserType;
    } else {
      _isLoggedIn = false;
    }

    notifyListeners();
  }
}
