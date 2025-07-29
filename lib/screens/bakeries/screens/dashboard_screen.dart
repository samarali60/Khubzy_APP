import 'package:flutter/material.dart';
import 'package:khubzy/core/widgets/bakary_info_card.dart';
import 'package:khubzy/models/bakery_model.dart';
import 'package:khubzy/models/baker_model.dart';
import 'package:khubzy/models/reservation_model.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:khubzy/screens/bakeries/providers/baker_provider.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
      // Ensure data is loaded before using it
      await bakerProvider.loadBakers();
      // Use the existing bakery model from the provider
      final bakery = bakeryProvider.getBakeryByOwner(bakerId);
      final baker = bakerProvider.getBakerByNationalId(bakerId);
      if (mounted) {
        setState(() {
          _bakery = bakery;
          _baker = baker;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock data for reservations
    final List<Reservation> todayReservations = [
      Reservation(
          citizenName: "أحمد محمود",
          breadAmount: 5,
          numberOfDays: 3,
          isDelivered: true,
          reservationDateTime: DateTime.now()),
      Reservation(
          citizenName: "سارة علي",
          breadAmount: 3,
          numberOfDays: 2,
          isDelivered: false,
          reservationDateTime: DateTime.now()),
      Reservation(
          citizenName: "John Doe",
          breadAmount: 10,
          numberOfDays: 5,
          isDelivered: true,
          reservationDateTime: DateTime.now()),
    ];

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

    // Calculations for the stat cards
    final soldQuota = _bakery!.dailyQuota - _bakery!.remainingQuota;
    final soldPercentage = soldQuota / _bakery!.dailyQuota;
    final remainingPercentage = _bakery!.remainingQuota / _bakery!.dailyQuota;
    final deliveredReservations =
        todayReservations.where((res) => res.isDelivered).length;
    final deliveredPercentage =
        todayReservations.isNotEmpty ? deliveredReservations / todayReservations.length : 0.0;

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
            _buildTotalReservationsCard(context, todayReservations.length),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context: context,
                  title: 'الخبز المباع',
                  value: soldQuota,
                  total: _bakery!.dailyQuota,
                  percentage: soldPercentage,
                  color: AppColors.primary,
                  icon: Icons.bakery_dining_outlined,
                ),
                _buildStatCard(
                  context: context,
                  title: 'الحصة المتبقية',
                  value: _bakery!.remainingQuota,
                  total: _bakery!.dailyQuota,
                  percentage: remainingPercentage,
                  color: Colors.orange,
                  icon: Icons.inventory_2_outlined,
                ),
                _buildStatCard(
                  context: context,
                  title: 'الطلبات المسلمة',
                  value: deliveredReservations,
                  total: todayReservations.length,
                  percentage: deliveredPercentage,
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
                _buildStatCard(
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

  Widget _buildTotalReservationsCard(BuildContext context, int reservationCount) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي حجوزات اليوم',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reservationCount.toString(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            Icon(
              Icons.list_alt_outlined,
              size: 50,
              color: Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required int value,
    int? total,
    double? percentage,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Icon(icon, color: color),
              ],
            ),
            Expanded(
              child: Center(
                child: (percentage != null && total != null)
                    ? CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 8.0,
                        percent: percentage.clamp(0.0, 1.0),
                        center: Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold, color: color),
                        ),
                        progressColor: color,
                        backgroundColor: color.withOpacity(0.2),
                        circularStrokeCap: CircularStrokeCap.round,
                      )
                    : Text(
                        value.toString(),
                        style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold, color: color),
                      ),
              ),
            ),
            if (total != null)
              Text(
                '$value / $total',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              )
          ],
        ),
      ),
    );
  }
}