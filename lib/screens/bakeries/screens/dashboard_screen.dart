import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khubzy/core/widgets/bakary_info_card.dart';
import 'package:khubzy/core/widgets/stateCard.dart';
import 'package:khubzy/core/widgets/total_reservation_card.dart';
import 'package:khubzy/firebase/send_notification_services.dart';
import 'package:khubzy/models/bakery_model.dart';
import 'package:khubzy/models/baker_model.dart';
import 'package:khubzy/models/reservation_model.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:khubzy/screens/bakeries/providers/baker_provider.dart';
import 'package:provider/provider.dart';
import 'package:khubzy/core/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BakeryDashboardScreen extends StatefulWidget {
  const BakeryDashboardScreen({super.key});

  @override
  State<BakeryDashboardScreen> createState() => _BakeryDashboardScreenState();
}

class _BakeryDashboardScreenState extends State<BakeryDashboardScreen> {
  BakerModel? _baker;
  BakeryModel? _bakery;
  bool _isLoading = true;
  int? reservationCount;
  List<Reservation> todayReservations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bakeryProvider = Provider.of<BakeryProvider>(context, listen: false);
    final bakerProvider = Provider.of<BakerProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final bakerId = prefs.getString('baker_id');

    if (bakerId != null) {
      await bakerProvider.loadBakers();
      final bakery = bakeryProvider.getBakeryByOwner(bakerId);
      final baker = bakerProvider.getBakerByNationalId(bakerId);

      if (bakery != null) {
        await _loadReservationsForBakery(bakery.bakeryName);
      }

      if (mounted) {
        setState(() {
          _bakery = bakery;
          _baker = baker;
          reservationCount = todayReservations.length;
          _isLoading = false;
        });
      }
      saveUserToken(bakerId);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReservationsForBakery(String bakeryName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('bakery', isEqualTo: bakeryName)
        .get();

    final List<Reservation> allReservations = snapshot.docs.map((doc) {
      final data = doc.data();
      return Reservation(
        citizenName: data['user'] ?? 'غير معروف',
        breadAmount: data['quantity'] ?? 0,
        numberOfDays: data['days'] ?? 0,
        isDelivered: data['confirmed'] ?? false,
        reservationDateTime:
            DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
        userNationalId: data['userNationalId'] ?? '',
        bekaryNationalId: data['bakeryNationalId'] ?? '',
        cardId: data['cardId'] ?? '',
      );
    }).toList();

    todayReservations = allReservations.where((res) {
      final now = DateTime.now();
      return res.reservationDateTime.year == now.year &&
          res.reservationDateTime.month == now.month &&
          res.reservationDateTime.day == now.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_bakery == null || _baker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم')),
        body: const Center(child: Text('لا توجد بيانات للمخبز')),
      );
    }

    final soldQuota = _bakery!.dailyQuota - _bakery!.remainingQuota;
    final soldPercentage = soldQuota / _bakery!.dailyQuota;
    final remainingPercentage = _bakery!.remainingQuota / _bakery!.dailyQuota;

    final deliveredReservations = todayReservations
        .where((res) => res.isDelivered)
        .length;
    final deliveredPercentage = todayReservations.isNotEmpty
        ? deliveredReservations / todayReservations.length
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم اليومية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BakeryInfoCard(bakery: _bakery!, baker: _baker!),
            const SizedBox(height: 24),
            buildTotalReservationsCard(context, reservationCount ?? 0),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                buildStatCard(
                  context: context,
                  title: 'الخبز المباع',
                  value: soldQuota,
                  total: _bakery!.dailyQuota,
                  percentage: soldPercentage,
                  color: AppColors.primary,
                  icon: Icons.bakery_dining_outlined,
                ),
                buildStatCard(
                  context: context,
                  title: 'الحصة المتبقية',
                  value: _bakery!.remainingQuota,
                  total: _bakery!.dailyQuota,
                  percentage: remainingPercentage,
                  color: Colors.orange,
                  icon: Icons.inventory_2_outlined,
                ),
                buildStatCard(
                  context: context,
                  title: 'الطلبات المسلمة',
                  value: deliveredReservations,
                  total: todayReservations.length,
                  percentage: deliveredPercentage,
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
                buildStatCard(
                  context: context,
                  title: 'تقييم المخبز',
                  value: _bakery!.rating.toInt(),
                  total: 5,
                  percentage: _bakery!.rating / 5.0,
                  color: Colors.amber,
                  icon: Icons.star_border_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
