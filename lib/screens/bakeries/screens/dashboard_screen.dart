import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khubzy/screens/auth/provider/bakery_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
            Text(
              "حجوزات اليوم",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reservations')
                    .where('bakery', isEqualTo: bakery.bakeryName)
                    .where('date', isEqualTo: currentDate)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("لا توجد حجوزات اليوم."));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final citizenName = doc['user'] ?? 'مواطن';
                      final quantity = doc['quantity'] ?? 0;
                      final isConfirmed = doc['confirmed'] == true;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text("$citizenName - $quantity رغيف"),
                          subtitle: Text(isConfirmed ? "تم التأكيد" : "قيد المراجعة"),
                          trailing: isConfirmed
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () => confirmReservation(doc.id),
                                  child: const Text("تأكيد"),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
