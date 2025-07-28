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
  int _breadPerDay = 0;
  bool _canReserve = true;
  bool _isLoading = true;
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

  int get totalBread {
    int bread = _breadPerDay;
    if (bread == 0) {
      bread = _familyMembers * 5;
    }
    return bread * _selectedDays;
  }

  @override
  void initState() {
    super.initState();
    _selectedBakery = widget.selectedBakery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _checkReservationRestriction();
    });
  }

  Future<void> _loadUserData() async {
    final citizenProvider = Provider.of<CitizenProvider>(context, listen: false);
    final citizen = citizenProvider.currentCitizen;
    setState(() {
      _familyMembers = citizen?.familyMembers ?? 1;
      _breadPerDay = citizen?.availableBreadPerDay ?? (_familyMembers * 5);
      _isLoading = false;
    });
  }

  Future<void> _checkReservationRestriction() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone');
    if (phone != null) {
      String? userData = prefs.getString('reservations_meta');
      if (userData != null) {
        Map<String, dynamic> meta = json.decode(userData);
        if (meta.containsKey(phone)) {
          String lastReservationDate = meta[phone]['date'];
          int reservedDays = meta[phone]['days'];
          DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastReservationDate);
          DateTime endDate = lastDate.add(Duration(days: reservedDays));
          if (_today.isBefore(endDate)) {
            setState(() {
              _canReserve = false;
            });
          }
        }
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
      'status': 'pending',
    };

    final existing = prefs.getString('reservations');
    List<Map<String, dynamic>> reservations = [];
    if (existing != null) {
      reservations = List<Map<String, dynamic>>.from(json.decode(existing));
    }

    reservations.add(newReservation);
    await prefs.setString('reservations', json.encode(reservations));

    final phone = prefs.getString('user_phone');
    if (phone != null) {
      Map<String, dynamic> meta = {};
      String? userData = prefs.getString('reservations_meta');
      if (userData != null) {
        meta = json.decode(userData);
      }
      meta[phone] = {
        'date': reservationDate,
        'days': _selectedDays,
      };
      await prefs.setString('reservations_meta', json.encode(meta));
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("✅ تم تأكيد الحجز"),
        content: Text(
          "عدد الأرغفة: $totalBread\nالوقت: $time\nالمخبز: $bakery",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canReserve) {
      return Scaffold(
        appBar: AppBar(title: const Text("الحجز غير متاح")),
        body: const Center(
          child: Text(
            "❌ لا يمكنك الحجز الآن. الرجاء الانتظار حتى انتهاء المدة.",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("حجز الخبز")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("اختر عدد الأيام:"),
            DropdownButton<int>(
              value: _selectedDays,
              items: const [
                DropdownMenuItem(value: 1, child: Text("يوم واحد")),
                DropdownMenuItem(value: 2, child: Text("يومان")),
                DropdownMenuItem(value: 3, child: Text("ثلاثة أيام")),
              ],
              onChanged: (value) {
                setState(() => _selectedDays = value!);
              },
            ),
            const SizedBox(height: 12),
            Text("عدد الأرغفة المحجوزة: $totalBread"),
            const SizedBox(height: 16),
            if (_selectedBakery == null) ...[
              const Text("اختر المخبز:"),
              FutureBuilder<String>(
                future: _loadBakeryOptions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    final bakeries = json.decode(snapshot.data!)['bakers'] as List<dynamic>;
                    final uniqueBakeries = bakeries.map((b) => b['bakery_name'] as String).toSet().toList();
                    return DropdownButton<String>(
                      value: _selectedBakery,
                      items: uniqueBakeries.map((name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedBakery = value);
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ] else
              Text("المخبز المختار: $_selectedBakery"),
            const SizedBox(height: 16),
            const Text("اختر الوقت المناسب:"),
            DropdownButton<String>(
              value: _selectedTime,
              hint: const Text("اختر وقتاً"),
              items: _availableTimes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (value) => setState(() => _selectedTime = value),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _selectedTime != null && _selectedBakery != null ? _confirmReservation : null,
                child: const Text("تأكيد الحجز"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadBakeryOptions() async {
    return await DefaultAssetBundle.of(context).loadString('assets/mock_users.json');
  }
}
