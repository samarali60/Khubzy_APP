
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khubzy/models/citizen_model.dart';

class CitizenProvider with ChangeNotifier {
  List<CitizenModel> citizens = [];

  Future<void> loadCitizens() async {
    final String response = await rootBundle.loadString('assets/mock_users.json');
    final data = json.decode(response);
    final citizenList = data['citizens'] as List;

    citizens = citizenList.map((e) => CitizenModel.fromJson(e)).toList();
    notifyListeners();
  }
}
