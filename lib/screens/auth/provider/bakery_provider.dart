import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/models/bakery_model.dart';

class BakeryProvider with ChangeNotifier {
  List<BakeryModel> _bakeries = [];

  BakeryModel? _currentBakery;
  BakeryModel? get currentBakery => _currentBakery;
  List<BakeryModel> get bakeries => _bakeries;

  Future<void> loadBakeries() async {
    final String response = await rootBundle.loadString(
      'assets/mock_bakery_data.json',
    );
    final List<dynamic> data = jsonDecode(response);
    _bakeries = data.map((item) => BakeryModel.fromJson(item)).toList();
    notifyListeners();
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
