import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _userPhone;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadUserPhone();
  }

  Future<void> _loadUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    _userPhone = prefs.getString('user_phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("طلباتي")),
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_userPhone == null) {
            return const Center(child: Text("لم يتم العثور على بيانات المستخدم."));
          }

          final currentMonth = DateTime.now().month;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reservations')
                .where('phone', isEqualTo: _userPhone)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs.where((doc) {
                final dateStr = doc['date'] ?? '';
                try {
                  final date = DateFormat('yyyy-MM-dd').parse(dateStr);
                  return date.month == currentMonth;
                } catch (e) {
                  return false;
                }
              }).toList();

              if (docs.isEmpty) {
                return const Center(child: Text("لا توجد طلبات حالياً."));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final bakery = doc['bakery'] ?? 'مخبز غير معروف';
                  final date = doc['date'] ?? '';
                  final time = doc['time'] ?? '';
                  final quantity = doc['quantity'] ?? 0;
                  final isConfirmed = doc['confirmed'] == true;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("المخبز: $bakery"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("التاريخ: $date"),
                          Text("الوقت: $time"),
                          Text("الكمية: $quantity رغيف"),
                          Text(
                            isConfirmed
                                ? "✅ تم تأكيد طلبك. يمكنك التوجه للمخبز لاستلام الخبز."
                                : "⌛️ الطلب قيد المراجعة من المخبز.",
                            style: TextStyle(
                              color: isConfirmed ? Colors.green : Colors.orange,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
