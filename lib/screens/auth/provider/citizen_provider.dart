import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khubzy/models/citizen_model.dart';

class CitizenProvider with ChangeNotifier {
  List<CitizenModel> citizens = [];
  CitizenModel? _currentCitizen;
  bool _isLoading = false;

  CitizenModel? get currentCitizen => _currentCitizen;
  bool get isLoading => _isLoading;

  /// ✅ تحميل كل المواطنين من Firestore
  Future<void> loadCitizens() async {
    _isLoading = true;
    // notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('citizens').get();
      citizens = snapshot.docs
          .map((doc) => CitizenModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('🔥 Error loading citizens: $e');
      citizens = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ البحث عن مواطن برقم الهاتف داخل القائمة المحمّلة
  void setCurrentCitizenByPhone(String phone) {
    debugPrint('⏳ Trying to find user with phone: $phone');
    debugPrint('📋 Available phones: ${citizens.map((c) => c.phone).toList()}');

    try {
      _currentCitizen = citizens.firstWhere((c) => c.phone == phone);
      debugPrint('✅ Found user: ${_currentCitizen!.name}');
    } catch (e) {
      debugPrint('❌ No matching user found!');
      _currentCitizen = null;
    }

    notifyListeners();
  }

  /// ✅ البحث عن مواطن مباشر من Firestore (بدون تحميل الكل)
  Future<void> loadCitizenByPhone(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('citizens')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _currentCitizen = CitizenModel.fromJson(snapshot.docs.first.data());
        debugPrint('✅ Loaded citizen from Firebase: ${_currentCitizen!.name}');
      } else {
        _currentCitizen = null;
        debugPrint('❌ No citizen found with that phone!');
      }
    } catch (e) {
      debugPrint('🔥 Error loading citizen by phone: $e');
      _currentCitizen = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearCurrentCitizen() {
    _currentCitizen = null;
    notifyListeners();
  }

  /// 📊 رصيد الخبز
  int get totalBalance => _currentCitizen?.monthlyBreadQuota ?? 0;
  int get dailyAvailableBalance => _currentCitizen?.availableBreadPerDay ?? 0;
  int get availableBreadFor2Days => dailyAvailableBalance * 2;
  int get availableBreadFor3Days => dailyAvailableBalance * 3;
  int get remainingBalance => _currentCitizen?.availableBread ?? 0;
}
