import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

Future<void> saveUserToken(String nationalId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('user_tokens')
            .doc(nationalId)
            .set({
              'token': fcmToken,
              'updatedAt': FieldValue.serverTimestamp(),
            });
        print('✅ Token saved for user: $nationalId');
      } else {
        print('⚠️ FCM token is null');
      }
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  Future<String?> getTokenByNationalId(String nationalId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_tokens')
          .doc(nationalId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['token'];
      } else {
        print('❌ No token found for this national ID');
        return null;
      }
    } catch (e) {
      print('⚠️ Error fetching token: $e');
      return null;
    }
  }

Future<String> getAccessToken() async {
  final jsonString = await rootBundle.loadString(
    'assets/fcm/khubzy-51aa8-243570844cc5.json',
  );

  final accountCredentials =
      auth.ServiceAccountCredentials.fromJson(jsonString);

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

  return client.credentials.accessToken.data;
}

Future<void> sendNotificationToUser(
    {required String nationalId, required title, required body,Map<String, String>? data}) async {
  final token = await getTokenByNationalId(nationalId);
  if (token == null) {
    print('❌ No token found for user with national ID: $nationalId');
    return;
  }

  await _sendNotification(
    token: token,
    title: title,
    body: body,
    data: data,
  );
}


 Future<void> _sendNotification(
    {required String token,
    required String title,
    required String body,
    required Map<String, String>? data}) async {
  final String accessToken = await getAccessToken();
  final String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/khubzy-51aa8/messages:send';

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(<String, dynamic>{
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data, // Add custom data here

        'android': {
          'notification': {
            "sound": "custom_sound",
            'click_action':
                'FLUTTER_NOTIFICATION_CLICK', // Required for tapping to trigger response
            'channel_id': 'high_importance_channel'
          },
        },
        'apns': {
          'payload': {
            'aps': {"sound": "custom_sound.caf", 'content-available': 1},
          },
        },
      },
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}

