
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});
  @override
  State<CitizenHomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<CitizenHomeScreen> {
  String userName = '';
  int remainingBread = 0;
  int maxBread = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'مستخدم';
      remainingBread = prefs.getInt('remaining_bread') ?? 0;
      maxBread = prefs.getInt('max_bread') ?? 0;
    });
  }


  @override
  Widget build(BuildContext context) {
     return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('مرحبًا $userName')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildTodayAlert(),
              const SizedBox(height: 16),
              _buildReserveButton(),
              const SizedBox(height: 16),
              _buildBreadBalance(),
              const SizedBox(height: 16),
              _buildNearestBakery(),
              const SizedBox(height: 16),
              _buildNextReservation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text("🍞 لديك $remainingBread رغيف متبقي اليوم"),
    );
  }

  Widget _buildReserveButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: navigate to booking
      },
      child: const Text("احجز الخبز الآن"),
    );
  }

  Widget _buildBreadBalance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📊 رصيدك الحالي:"),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: maxBread == 0 ? 0 : remainingBread / maxBread,
          minHeight: 12,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 4),
        Text("$remainingBread من $maxBread رغيف"),
      ],
    );
  }

  Widget _buildNearestBakery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📍 أقرب مخبز إليك:"),
        const SizedBox(height: 4),
        const Text("🟢 مخبز الفتح - يبعد 500م"),
        TextButton(
          onPressed: () {
            // TODO: show map
          },
          child: const Text("عرض على الخريطة"),
        ),
      ],
    );
  }

  Widget _buildNextReservation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📅 حجزك القادم:"),
        const Text("5 أرغفة - الساعة 9 ص - مخبز النور"),
        TextButton.icon(
          onPressed: () {
            // TODO: edit booking
          },
          icon: const Icon(Icons.edit),
          label: const Text("تعديل الحجز"),
        ),
      ],
    );
  }
}
