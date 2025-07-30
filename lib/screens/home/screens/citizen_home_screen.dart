import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:khubzy/screens/reservation/provider/screens/reservation_screen.dart';
import 'package:khubzy/core/services/egypt_locations.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  String userName = '';
  int remainingBread = 0;
  int maxBread = 0;
  int familyMembers = 0;
  List<dynamic> nearbyBakeries = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'مستخدم';
      remainingBread = prefs.getInt('available_bread') ?? 0;
      maxBread = prefs.getInt('monthly_bread_quota') ?? 0;
      familyMembers = prefs.getInt('family_members') ?? 0;
    });

    final userCenter = prefs.getString('user_center');
    double? userLat;
    double? userLng;

    // استخراج lat/lng من center
    if (userCenter != null) {
      for (var centerList in locations.values) {
        for (var center in centerList) {
          if (center['name'] == userCenter) {
            userLat = center['lat'];
            userLng = center['lng'];
            break;
          }
        }
        if (userLat != null && userLng != null) break;
      }
    }

    if (userLat != null && userLng != null) {
      await _fetchNearbyBakeries(userLat, userLng);
    }
  }

  Future<void> _fetchNearbyBakeries(double lat, double lng) async {
    
   final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=10000&type=bakery&key=AIzaSyChQ0n-vud41n-_pz-nXBiDJTQrG7F0CJs');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nearbyBakeries = data['results'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching bakeries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('خبزي')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                '👋 أهلاً يا $userName، نتمنى لك تجربة سعيدة!\nيمكنك حجز خبز من أقرب مخبز لك.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              buildReserveButton(),
              const SizedBox(height: 16),
              buildNearestBakeries(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReserveButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReservationScreen()),
        );
      },
      child: const Text("احجز الخبز الآن"),
    );
  }

  Widget buildNearestBakeries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📍 أقرب المخابز إليك:"),
        const SizedBox(height: 8),
        if (nearbyBakeries.isEmpty)
          const Text("لا توجد مخابز قريبة حالياً"),
        ...nearbyBakeries.map((b) {
          final name = b['name'] ?? 'مخبز';
          final address = b['vicinity'] ?? '';
          return Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: Text(name),
              subtitle: Text(address),
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReservationScreen(selectedBakery: name),
                    ),
                  );
                },
                child: const Text("احجز الآن"),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
