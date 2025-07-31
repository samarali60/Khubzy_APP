import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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

    await FirebaseFirestore.instance.collection('reservations').add({
      'user': userName,
      'phone': userPhone,
      'bakery': bakery,
      'date': reservationDate,
      'days': _selectedDays,
      'time': time,
      'quantity': totalBread,
      'confirmed': false,
    });

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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/bread.png", height: 150),
              const SizedBox(height: 16),
              const Text(
                "❌ لا يمكنك الحجز الآن.\nيرجى المحاولة بعد انتهاء المدة أو غداً.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD5A253),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Image.network(
                    "https://i.pinimg.com/736x/e1/fe/b4/e1feb42f72cc526b521cbb91bc77514a.jpg",
                    height: 400,
                    width: 600,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCard(
                        icon: Icons.calendar_today,
                        title: "اختر عدد الأيام:",
                        child: DropdownButton<int>(
                          value: _selectedDays,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text("يوم واحد")),
                            DropdownMenuItem(value: 2, child: Text("يومان")),
                            DropdownMenuItem(value: 3, child: Text("ثلاثة أيام")),
                          ],
                          onChanged: (value) => setState(() => _selectedDays = value!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCard(
                        icon: Icons.local_grocery_store,
                        title: "عدد الأرغفة المحجوزة:",
                        child: Text("$totalBread", style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedBakery == null)
                        _buildCard(
                          icon: Icons.store,
                          title: "اختر المخبز:",
                          child: FutureBuilder<String>(
                            future: _loadBakeryOptions(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                final bakeries = json.decode(snapshot.data!)['bakers'] as List<dynamic>;
                                final uniqueBakeries = bakeries.map((b) => b['bakery_name'] as String).toSet().toList();
                                return DropdownButton<String>(
                                  value: _selectedBakery,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: uniqueBakeries.map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _selectedBakery = value),
                                );
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                        )
                      else
                        _buildCard(
                          icon: Icons.store,
                          title: "المخبز المختار:",
                          child: Text("$_selectedBakery", style: const TextStyle(fontSize: 16)),
                        ),
                      const SizedBox(height: 12),
                      _buildCard(
                        icon: Icons.access_time,
                        title: "اختر الوقت المناسب:",
                        child: DropdownButton<String>(
                          value: _selectedTime,
                          hint: const Text("اختر وقتاً"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _availableTimes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (value) => setState(() => _selectedTime = value),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _selectedTime != null && _selectedBakery != null ? _confirmReservation : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTime != null && _selectedBakery != null ? const Color(0xFFD5A253) : const Color(0xFFEAD8B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("تأكيد الحجز"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFFD5A253)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Future<String> _loadBakeryOptions() async {
    return await DefaultAssetBundle.of(context).loadString('assets/mock_users.json');
  }
}
