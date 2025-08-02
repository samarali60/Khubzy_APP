import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khubzy/firebase/send_notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khubzy/screens/reservation/provider/screens/reservation_screen.dart';
import 'package:khubzy/core/services/egypt_locations.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  String userName = '';
  String nationalId = '';
  int remainingBread = 0;
  int maxBread = 0;
  int familyMembers = 0;
  List<Map<String, dynamic>> matchingBakeries = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'مستخدم';
      nationalId = prefs.getString('user_national_id') ?? '';
      remainingBread = prefs.getInt('available_bread') ?? 0;
      maxBread = prefs.getInt('monthly_bread_quota') ?? 0;
      familyMembers = prefs.getInt('family_members') ?? 0;
    });

    saveUserToken(nationalId);
    final userCenter = prefs.getString('user_center');

    if (userCenter != null) {
      final userGovernorate = _getGovernorateForCenter(userCenter);
      if (userGovernorate.isNotEmpty) {
        await _fetchBakeriesFromFirestore(userCenter, userGovernorate);
      }
    }
  }

  String _getGovernorateForCenter(String? center) {
    if (center == null) return '';
    for (var entry in locations.entries) {
      for (var c in entry.value) {
        if (c['name'] == center) return entry.key;
      }
    }
    return '';
  }

  Future<void> _fetchBakeriesFromFirestore(String center, String governorate) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('bakeries').get();
      final all = snapshot.docs.map((doc) => doc.data()).toList();

      // فلترة حسب المحافظة
      final inGovernorate = all
          .where((b) =>
              (b['location'] ?? '').toString().contains(governorate))
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // ترتيب المخابز اللي في نفس المركز أولاً
      inGovernorate.sort((a, b) {
        final aInCenter = (a['location'] ?? '').toString().contains(center);
        final bInCenter = (b['location'] ?? '').toString().contains(center);
        if (aInCenter && !bInCenter) return -1;
        if (!aInCenter && bInCenter) return 1;
        return 0;
      });

      setState(() {
        matchingBakeries = inGovernorate;
      });
    } catch (e) {
      debugPrint('Error fetching bakeries from Firestore: $e');
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
                '👋 أهلاً يا $userName، نتمنى لك تجربة سعيدة!\nيمكنك حجز خبز من أقرب مخبز لك في محافظتك.',
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
    onPressed: () async {
      if (matchingBakeries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لا توجد مخابز متاحة حالياً")),
        );
        return;
      }

      final bakeryWithQuota = matchingBakeries.firstWhere(
        (b) => (b['remaining_quota'] ?? 0) > 0,
        orElse: () => {},
      );

      if (bakeryWithQuota.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لا يوجد مخبز به حصة متاحة الآن")),
        );
        return;
      }

      final bakeryName = bakeryWithQuota['bakery_name'];
            final bakeryOwnerId = bakeryWithQuota['owners_national_id'];


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationScreen(selectedBakery: bakeryName,
            selectedNationalId: bakeryOwnerId,
          ),
        ),
      );
    },
    child: const Text("احجز الخبز الآن"),
  );
}

  Widget buildNearestBakeries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📍 أقرب المخابز إليك (حسب المركز والمحافظة):"),
        const SizedBox(height: 8),
        if (matchingBakeries.isEmpty)
          const Text("لا توجد مخابز حالياً في هذه المنطقة"),
        ...matchingBakeries.map((b) {
          final name = b['bakery_name'] ?? 'مخبز';
                      final bakeryOwnerId = b['owners_national_id'];

          final address = b['location'] ?? '';
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
                          ReservationScreen(selectedBakery: name,
                            selectedNationalId: bakeryOwnerId
                          ),
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
