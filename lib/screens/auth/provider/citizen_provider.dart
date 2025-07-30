import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khubzy/models/citizen_model.dart';

class CitizenProvider with ChangeNotifier {
  List<CitizenModel> citizens = [];
  CitizenModel? _currentCitizen;
  bool _isLoading = false;

  CitizenModel? get currentCitizen => _currentCitizen;
  bool get isLoading => _isLoading;

  Future<void> loadCitizens() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/mock_users.json');
      final data = json.decode(response);
      final citizenList = data['citizens'] as List;

      citizens = citizenList.map((e) => CitizenModel.fromJson(e)).toList();
    } catch (e) {
      citizens = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🔍 البحث عن المواطن برقم الهاتف
  void setCurrentCitizenByPhone(String phone) {
    try {
      _currentCitizen = citizens.firstWhere((c) => c.phone == phone);
    } catch (e) {
      _currentCitizen = null;
    }
    notifyListeners();
  }

  void clearCurrentCitizen() {
    _currentCitizen = null;
    notifyListeners();
  }

  /// الرصيد الكلي للمواطن خلال الشهر
  int get totalBalance => _currentCitizen?.monthlyBreadQuota ?? 0;

  /// الرصيد المتاح يوميًا
  int get dailyAvailableBalance => _currentCitizen?.availableBreadPerDay ?? 0;

  int get availableBreadFor2Days => dailyAvailableBalance * 2;
  int get availableBreadFor3Days => dailyAvailableBalance * 3;

  /// الرصيد المتبقي خلال الشهر
  int get remainingBalance => _currentCitizen?.availableBread ?? 0;
}
