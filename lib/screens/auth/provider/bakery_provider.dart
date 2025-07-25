import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/models/bakery_model.dart';

class BakeryProvider with ChangeNotifier {
  List<BakeryModel> _bakeries = [];

  List<BakeryModel> get bakeries => _bakeries;

  Future<void> loadBakeries() async {
    final String response = await rootBundle.loadString('assets/mock_bakery_data.json');
    final List<dynamic> data = jsonDecode(response);
    _bakeries = data.map((item) => BakeryModel.fromJson(item)).toList();
    notifyListeners();
  }

  BakeryModel? getBakeryByOwner(String nationalId) {
    try {
      return _bakeries.firstWhere((b) => b.ownersNationalIds.contains(nationalId));
    } catch (e) {
      return null;
    }
  }
}
