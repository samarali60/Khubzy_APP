import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/models/baker_model.dart';

class BakerProvider with ChangeNotifier {
  List<BakerModel> _bakers = [];

  List<BakerModel> get bakers => _bakers;


  Future<void> loadBakers() async {
  try {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('bakers').get();

    _bakers = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BakerModel.fromJson(data);
    }).toList();

    notifyListeners();
  } catch (e) {
    debugPrint('❌ Error loading bakers from Firebase: $e');
  }
}


  BakerModel? getBakerByNationalId(String nationalId) {
    try {
      return _bakers.firstWhere((baker) => baker.nationalId == nationalId);
    } catch (e) {
      return null;
    }
  }
}
