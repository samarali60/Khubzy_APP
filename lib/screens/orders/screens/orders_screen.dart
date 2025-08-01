import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khubzy/core/constants/colors.dart';
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
            return const Center(
              child: Text("لم يتم العثور على بيانات المستخدم."),
            );
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/no-data_ig65.png',
                        height: 300,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "لا توجد طلبات حالياً.",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final bakery = doc['bakery'] ?? 'مخبز غير معروف';
                  final date = doc['date'] ?? '';
                  final time = doc['time'] ?? '';
                  final quantity = doc['quantity'] ?? 0;
                  final numberOfDays = doc['days'] ?? 0;
                  final isConfirmed = doc['confirmed'] == true;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.store, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "المخبز: $bakery",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 6),
                              Text("تاريخ الحجز: $date"),
                              const Spacer(),
                              Icon(
                                Icons.bakery_dining,
                                size: 18,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text("لـ $numberOfDays يوم"),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 6),
                              Text("الكمية: $quantity رغيف"),

                              const Spacer(),
                              Icon(Icons.today, size: 18, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text("الوقت: $time"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isConfirmed
                                      ? Icons.check_circle
                                      : Icons.hourglass_empty,
                                  color: isConfirmed
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isConfirmed
                                        ? " تم تأكيد طلبك. يمكنك التوجه للمخبز لاستلام الخبز."
                                        : " الطلب قيد المراجعة من المخبز.",
                                    style: TextStyle(
                                      color: isConfirmed
                                          ? Colors.green.shade700
                                          : Colors.orange.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
