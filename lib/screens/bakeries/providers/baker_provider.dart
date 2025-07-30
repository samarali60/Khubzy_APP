import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/models/baker_model.dart';

class BakerProvider with ChangeNotifier {
  List<BakerModel> _bakers = [];

  List<BakerModel> get bakers => _bakers;

  Future<void> loadBakers() async {
    final String response = await rootBundle.loadString('assets/mock_users.json');
    final  data = jsonDecode(response);
     final bakerList = data['bakers'] as List;
    if (bakerList.isEmpty) {
        debugPrint("⚠️ No bakers found in mock_users.json");
      throw Exception("No bakers found in the mock data.");
    }
    _bakers = bakerList.map((json) => BakerModel.fromJson(json)).toList();
    notifyListeners();
  }

  BakerModel? getBakerByNationalId(String nationalId) {
    try {
      return _bakers.firstWhere((baker) => baker.nationalId == nationalId);
    } catch (e) {
      return null;
    }
  }
}
