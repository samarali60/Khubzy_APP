import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends StatefulWidget {
  final String? selectedBakery;
  const ReservationScreen({super.key, this.selectedBakery});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int _selectedDays = 1;
  int _familyMembers = 1;
  int _breadPerDay = 5;
  bool _canReserve = true;
  DateTime _today = DateTime.now();
  List<String> _availableTimes = [
    "7:00 ص",
    "8:00 ص",
    "9:00 ص",
    "10:00 ص",
    "11:00 ص",
    "12:00 م",
  ];
  String? _selectedTime;
  String? _selectedBakery;

  int get totalBread => _breadPerDay * _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedBakery = widget.selectedBakery;
    _loadUserData();
    _checkReservationRestriction();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final citizenProvider = Provider.of<CitizenProvider>(
      context,
      listen: false,
    );

    setState(() {
      _familyMembers = citizenProvider.currentCitizen?.familyMembers ?? 1;
      _breadPerDay = citizenProvider.dailyAvailableBalance;
      // _breadPerDay = prefs.getInt('available_bread_per_day') ?? _familyMembers * 5;
      print("Family Members: $_familyMembers, Bread Per Day: $_breadPerDay");
    });
  }

  Future<void> _checkReservationRestriction() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastReservationDate = prefs.getString('last_reservation_date');
    int? reservedDays = prefs.getInt('reserved_days');

    if (lastReservationDate != null && reservedDays != null) {
      DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastReservationDate);
      DateTime endDate = lastDate.add(Duration(days: reservedDays));
      if (_today.isBefore(endDate)) {
        setState(() {
          _canReserve = false;
        });
      }
    }
  }

  Future<void> _confirmReservation() async {
    final prefs = await SharedPreferences.getInstance();

    final userName = prefs.getString('user_name') ?? 'مستخدم';
    final userPhone = prefs.getString('user_phone') ?? '';
    final reservationDate = DateFormat('yyyy-MM-dd').format(_today);
    final time = _selectedTime ?? '';
    final bakery = _selectedBakery ?? 'مخبز غير معروف';

    final newReservation = {
      'user': userName,
      'phone': userPhone,
      'bakery': bakery,
      'date': reservationDate,
      'days': _selectedDays,
      'time': time,
      'quantity': totalBread,
    };

    final existing = prefs.getString('reservations');
    List<Map<String, dynamic>> reservations = [];
    if (existing != null) {
      reservations = List<Map<String, dynamic>>.from(json.decode(existing));
    }

    reservations.add(newReservation);
    await prefs.setString('reservations', json.encode(reservations));

    await prefs.setString('last_reservation_date', reservationDate);
    await prefs.setInt('reserved_days', _selectedDays);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("✅ تم تأكيد الحجز"),
        content: Text(
          "عدد الأرغفة: $totalBread\nالوقت: $time\nالمخبز: $bakery",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canReserve) {
      return Scaffold(
        appBar: AppBar(title: const Text("الحجز غير متاح")),
        body: const Center(
          child: Text(
            "❌ لا يمكنك الحجز الآن. الرجاء الانتظار حتى انتهاء المدة.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("حجز الخبز"),
        centerTitle: true,
        leading: const Icon(Icons.local_grocery_store),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  "تفاصيل الحجز",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(thickness: 1.5),
                const SizedBox(height: 12),

                Row(
                  children: const [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8),
                    Text("اختر عدد الأيام:"),
                  ],
                ),
                DropdownButton<int>(
                  value: _selectedDays,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("يوم واحد")),
                    DropdownMenuItem(value: 2, child: Text("يومان")),
                    DropdownMenuItem(value: 3, child: Text("ثلاثة أيام")),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDays = value!);
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  "🥖 عدد الأرغفة المحجوزة: $totalBread",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                if (_selectedBakery == null) ...[
                  Row(
                    children: const [
                      Icon(Icons.store),
                      SizedBox(width: 8),
                      Text("اختر المخبز:"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<String>(
                    future: _loadBakeryOptions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        final bakeries =
                            json.decode(snapshot.data!)['bakers']
                                as List<dynamic>;
                        return DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("اختر مخبزاً"),
                          value: _selectedBakery,
                          items: bakeries.map<DropdownMenuItem<String>>((b) {
                            return DropdownMenuItem<String>(
                              value: b['bakery_name'] as String,
                              child: Text(b['bakery_name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedBakery = value);
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ] else
                  Text("✅ المخبز المختار: $_selectedBakery"),
                const SizedBox(height: 16),

                Row(
                  children: const [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text("اختر الوقت المناسب:"),
                  ],
                ),
                DropdownButton<String>(
                  value: _selectedTime,
                  isExpanded: true,
                  hint: const Text("اختر وقتاً"),
                  items: _availableTimes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedTime = value),
                ),

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text("تأكيد الحجز"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedTime != null && _selectedBakery != null
                      ? _confirmReservation
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _loadBakeryOptions() async {
    return await DefaultAssetBundle.of(
      context,
    ).loadString('assets/mock_users.json');
  }
}
