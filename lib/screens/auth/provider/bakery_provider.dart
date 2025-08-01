import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/models/bakery_model.dart';

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
    debugPrint('✅ Loaded ${_bakeries.length} bakeries from Firestore');
    notifyListeners();
  } catch (e) {
    debugPrint('❌ Error loading bakeries: $e');
  }
}

  BakeryModel? getBakeryByOwner(String nationalId) {
    try {
      return _bakeries.firstWhere(
        (b) => b.ownersNationalIds.contains(nationalId),
      );
    } catch (e) {
      return null;
    }
  }

  bool loginBakery({
    required String nationalId,
    required String location,
    required String bakeryName,
  }) {
    try {
      final bakery = _bakeries.firstWhere(
        (b) =>
            b.ownersNationalIds.contains(nationalId) &&
            b.location == location &&
            b.bakeryName == bakeryName,
      );

      _currentBakery = bakery;
     
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
