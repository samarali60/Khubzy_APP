import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadBakeriesToFirebase() async {
  try {
    final String jsonString = await rootBundle.loadString('assets/mock_bakery_data.json');
    final List<dynamic> bakeryList = json.decode(jsonString);

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (var bakery in bakeryList) {
      final String id = bakery['id'].toString();
      await firestore.collection('bakeries').doc(id).set(bakery);
      debugPrint('✅ Uploaded bakery with ID: $id');
    }

    debugPrint('🎉 All bakeries uploaded successfully');
  } catch (e) {
    debugPrint('❌ Error uploading bakeries: $e');
  }
}
