
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khubzy/models/citizen_model.dart';

class CitizenProvider with ChangeNotifier {
  List<CitizenModel> citizens = [];
  CitizenModel? _currentCitizen;

  CitizenModel? get currentCitizen => _currentCitizen;

  Future<void> loadCitizens() async {
    final String response = await rootBundle.loadString('assets/mock_users.json');
    final data = json.decode(response);
    final citizenList = data['citizens'] as List;

    citizens = citizenList.map((e) => CitizenModel.fromJson(e)).toList();
    notifyListeners();
  }

  // 🔎 البحث عن المواطن بناءً على رقم الهاتف
  void setCurrentCitizenByPhone(String phone) {
    try {
      _currentCitizen = citizens.firstWhere((c) => c.phone == phone);
    } catch (e) {
      _currentCitizen = null; // مش لاقيه
    }
    notifyListeners();
  }

  void clearCurrentCitizen() {
    _currentCitizen = null;
    notifyListeners();
  }
 /// الرصيد الكلي للمواطن خلال الشهر
  int get totalBalance => _currentCitizen?.monthlyBreadQuota ?? 0;

int get dailyBalance => _currentCitizen?.familyMembers ?? 0;
  /// الرصيد المتاح سحبه خلال اليوم الواحد
  //int get dailyAvailableBalance => _currentCitizen?.availableBreadPerDay ?? 0;

//  int get availableBreadFor2Days => dailyAvailableBalance * 2 ;

//   int get availableBreadFor3Days => dailyAvailableBalance * 3 ;

  /// الرصيد المتبقي للمواطن خلال الشهر
  int get remainingBalance => _currentCitizen?.availableBread ?? 0;

}
