import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khubzy/models/reservation_model.dart';
import 'package:khubzy/core/constants/colors.dart';

class BakeryOrdersScreen extends StatefulWidget {
  const BakeryOrdersScreen({super.key});

  @override
  State<BakeryOrdersScreen> createState() => _BakeryOrdersScreenState();
}

class _BakeryOrdersScreenState extends State<BakeryOrdersScreen> {
  // Mock data for demonstration purposes
  final List<Reservation> _reservations = [
    Reservation(
      isDelivered: false,
        citizenName: 'أحمد محمود',
        breadAmount: 10,
        numberOfDays: 2,
        reservationDateTime: DateTime.now().subtract(const Duration(hours: 2))),
    Reservation(
        isDelivered: true,
        citizenName: 'فاطمة الزهراء',
        breadAmount: 5,
        numberOfDays: 1,
        reservationDateTime: DateTime.now().subtract(const Duration(hours: 5))),
    Reservation(
        isDelivered: false,
        citizenName: 'محمد علي',
        breadAmount: 15,
        numberOfDays: 3,
        reservationDateTime:
            DateTime.now().subtract(const Duration(days: 1, hours: 3))),
    Reservation(
        isDelivered: false,
        citizenName: 'سارة إبراهيم',
        breadAmount: 20,
        numberOfDays: 4,
        reservationDateTime:
            DateTime.now().subtract(const Duration(days: 1, hours: 6))),
    Reservation(
        isDelivered: true,
        citizenName: 'خالد عبد الله',
        breadAmount: 8,
        numberOfDays: 2,
        reservationDateTime:
            DateTime.now().subtract(const Duration(days: 2, hours: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'ar_EG';

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات المواطنين'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final order = _reservations[index];
          return _buildOrderCard(order, context);
        },
      ),
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('تأكيد'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(Reservation order, BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  order.citizenName,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _buildDetailRow(
              theme: theme,
              icon: Icons.bakery_dining_outlined,
              label: 'كمية الخبز',
              value: '${order.breadAmount} رغيف',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              theme: theme,
              icon: Icons.calendar_today_outlined,
              label: 'عدد الأيام',
              value: '${order.numberOfDays} أيام',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              theme: theme,
              icon: Icons.date_range_outlined,
              label: 'تاريخ الحجز',
              value: order.formattedDate,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              theme: theme,
              icon: Icons.access_time_outlined,
              label: 'وقت الحجز',
              value: order.formattedTime,
            ),
            const SizedBox(height: 20),
            
            // --- ENHANCED ACTION BUTTONS ---
            // This setup ensures both buttons have the exact same width.
            Row(
              children: [
                // Decline Button
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
            
                    ),
                    onPressed: () {
                      _showConfirmationDialog(
                        context: context,
                        title: 'تأكيد الرفض',
                        content:
                            'هل أنت متأكد من أنك تريد رفض طلب ${order.citizenName}؟',
                        onConfirm: () {
                          print('Order from ${order.citizenName} DECLINED.');
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Accept Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('قبول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                     // padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      _showConfirmationDialog(
                        context: context,
                        title: 'تأكيد القبول',
                        content:
                            'هل أنت متأكد من أنك تريد قبول طلب ${order.citizenName}؟',
                        onConfirm: () {
                          print('Order from ${order.citizenName} ACCEPTED.');
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          value,
          style:
              theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
        ),
      ],
    );
  }
}