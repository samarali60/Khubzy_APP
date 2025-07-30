import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/core/widgets/bakary_info_card.dart';
import 'package:khubzy/core/widgets/daily_qouta_card.dart';
import 'package:khubzy/core/widgets/production_rate_bar.dart';
import 'package:khubzy/core/widgets/todat_resevation_list.dart';
import 'package:khubzy/models/reservations.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:provider/provider.dart';

class BakeryDashboardScreen extends StatelessWidget {
  const BakeryDashboardScreen({super.key});

  Future<void> confirmReservation(String docId) async {
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(docId)
        .update({'confirmed': true});
  }

  @override
  Widget build(BuildContext context) {
    final bakery = Provider.of<BakeryProvider>(context).currentBakery;

    if (bakery == null) {
      return Scaffold(
        appBar: AppBar(title: Text('لوحة التحكم')),
        body: Center(child: Text('لا توجد بيانات للمخبز')),
      );
    }

    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // logout logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            BakeryInfoCard(bakery: bakery),
            SizedBox(height: 16),
            Row(
              children: [Expanded(child: DailyQuotaCard(bakery: bakery))],
            ),
            SizedBox(height: 16),
            ProductionRateBar(
              dailyQuota: bakery.dailyQuota,
              remainingQuota: bakery.remainingQuota,
            ),
            SizedBox(height: 16),
            Text(
              "حجوزات اليوم",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TodayReservationsList(
                reservations: [
                  Reservation(citizenName: "أحمد محمود", quantity: 5),
                  Reservation(citizenName: "سارة علي", quantity: 3),
                  Reservation(citizenName: "محمد حسن", quantity: 4),
                ],
              ),
            ),
            SizedBox(height: 16),
           
          ],
        ),
      ),
    );
  }
}
