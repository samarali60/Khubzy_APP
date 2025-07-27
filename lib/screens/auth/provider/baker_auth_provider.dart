import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class BakeryAuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login({
    required String name,
    required String nationalId,
    required String bakeryName,
    required String location,
    required String phone,
    required String password,
  }) async {
    final data = await rootBundle.loadString('assets/mock_bakery_data.json');
    final List<dynamic> bakeries = json.decode(data);

    final matching = bakeries.firstWhere(
      (b) =>
          (b['owners_national_ids'] as List).contains(nationalId) &&
          b['bakery_name'] == bakeryName &&
          b['location'] == location,
      orElse: () => null,
    );

    if (matching != null) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

}
