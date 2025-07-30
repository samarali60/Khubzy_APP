import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadUsersToFirebase() async {
  try {
    final String jsonString = await rootBundle.loadString('assets/mock_users.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> citizens = jsonData['citizens'];
    final List<dynamic> bakers = jsonData['bakers'];

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // رفع المواطنين
    for (var citizen in citizens) {
      final String id = citizen['national_id'].toString();
      await firestore.collection('citizens').doc(id).set(citizen);
      debugPrint('✅ Uploaded citizen with ID: $id');
    }

    // رفع الخبازين
    for (var baker in bakers) {
      final String id = baker['national_id'].toString();
      await firestore.collection('bakers').doc(id).set(baker);
      debugPrint('✅ Uploaded baker with ID: $id');
    }

    debugPrint('🎉 All users uploaded successfully');
  } catch (e) {
    debugPrint('❌ Error uploading users: $e');
  }
}
