import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/models/bakery_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BakeryProvider with ChangeNotifier {
  List<BakeryModel> _bakeries = [];
  BakeryModel? _currentBakery;

  BakeryModel? get currentBakery => _currentBakery;
  List<BakeryModel> get bakeries => _bakeries;

  Future<void> loadBakeries() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('bakeries').get();

      _bakeries = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BakeryModel.fromJson(data);
      }).toList();

      debugPrint('Owners IDs: ${_bakeries.map((b) => b.ownersNationalId).toList()}');
      debugPrint('✅ Loaded ${_bakeries.length} bakeries from Firestore');

      // بعد التحميل شوف لو محتاج تصفير الحصة اليومية
      await resetDailyQuotaIfNeeded();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading bakeries: $e');
    }
  }

  Future<void> resetDailyQuotaIfNeeded() async {
    final today = DateTime.now();
    final bakeriesRef = FirebaseFirestore.instance.collection('bakeries');

    for (var bakery in _bakeries) {
      final lastReset = DateTime.tryParse(bakery.lastResetDate ?? "");

      bool isDifferentDay = lastReset == null||
          lastReset.day != today.day||
          lastReset.month != today.month ||
          lastReset.year != today.year;

      if (isDifferentDay) {
        try {
          await bakeriesRef.doc(bakery.ownersNationalId).update({
            'remaining_quota': bakery.dailyQuota,
            'last_reset_date': "${today.toIso8601String().split('T').first}",
          });

          bakery.remainingQuota = bakery.dailyQuota;
          bakery.lastResetDate = today.toIso8601String().split('T').first;

          debugPrint('🔄 Reset quota for bakery: ${bakery.bakeryName}');
        } catch (e) {
          debugPrint('⚠️ Failed to reset quota for ${bakery.bakeryName}: $e');
        }
      }
    }
    notifyListeners();
  }

  BakeryModel? getBakeryByOwner(String nationalId) {
    try {
      return _bakeries.firstWhere(
        (b) => b.ownersNationalId == nationalId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> loginBakery({
    required String nationalId,
    required String location,
    required String bakeryName,
  }) async {
    try {
      final bakery = _bakeries.firstWhere(
        (b) =>
            b.ownersNationalId == nationalId &&
            b.location == location &&
            b.bakeryName == bakeryName,
      );

      _currentBakery = bakery;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('baker_id', nationalId);

      print('bakerId: $nationalId');
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logoutBakery() {
    _currentBakery = null;
    notifyListeners();
  }
}