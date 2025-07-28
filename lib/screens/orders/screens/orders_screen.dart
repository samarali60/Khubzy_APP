import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> _myOrders = [];

  @override
  void initState() {
    super.initState();
    _loadMyOrders();
  }

  Future<void> _loadMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';
    final ordersData = prefs.getString('reservations');
    if (ordersData != null) {
      final orders = List<Map<String, dynamic>>.from(json.decode(ordersData));
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      final filtered = orders.where((order) {
        final isMine = order['phone'] == phone;
        final orderDate = DateTime.parse(order['date']);
        return isMine && orderDate.month == currentMonth && orderDate.year == currentYear;
      }).toList();

      setState(() {
        _myOrders = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("طلباتي")),
      body: _myOrders.isEmpty
          ? const Center(child: Text("لا يوجد طلبات هذا الشهر"))
          : ListView.builder(
              itemCount: _myOrders.length,
              itemBuilder: (context, index) {
                final order = _myOrders[index];
                final status = order['status'] == 'confirmed' ? '✅ تم تأكيد الطلب' : '⏳ قيد المراجعة';
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text("المخبز: ${order['bakery']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("الكمية: ${order['quantity']} رغيف"),
                        Text("التاريخ: ${order['date']}"),
                        Text("الوقت: ${order['time']}"),
                        Text("الحالة: $status"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
