import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:khubzy/firebase/send_notification_services.dart';
import 'package:khubzy/models/reservation_model.dart';
import 'package:khubzy/core/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BakeryOrdersScreen extends StatefulWidget {
  const BakeryOrdersScreen({super.key});

  @override
  State<BakeryOrdersScreen> createState() => _BakeryOrdersScreenState();
}

class _BakeryOrdersScreenState extends State<BakeryOrdersScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _currentBakeryName;

  @override
  @override
  void initState() {
    super.initState();
    _loadBakeryNameAndReservations();
  }

  Future<void> _loadBakeryNameAndReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final bakeryName = prefs.getString('bakery_name');

    if (bakeryName == null) {
      print("اسم المخبز مش موجود في SharedPreferences");
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _currentBakeryName = bakeryName;
    });

    await _fetchReservations(bakeryName);
  }

  Future<void> _fetchReservations(String bakeryName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('bakery', isEqualTo: bakeryName)
          .get();

      final List<Reservation> loadedReservations = snapshot.docs.map((doc) {
        final data = doc.data();
        return Reservation(
          userNationalId: data['user_national_id'] ?? '',
          citizenName: data['user'] ?? '',
          breadAmount: data['quantity'] ?? 0,
          numberOfDays: data['days'] ?? 0,
          bekaryNationalId: data['bakery_owner_national_id'] ?? '',
          reservationDateTime: DateTime.parse(data['date']),
          isDelivered: data['confirmed'] ?? false,
          cardId: data['card_id'], // Use the document ID as the card ID
        );
      }).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reservation_count', loadedReservations.length);
      print('تم تحميل ${loadedReservations.length} طلبات للمخبز $bakeryName');
      setState(() {
        _reservations = loadedReservations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reservations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'ar_EG';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات المواطنين'),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.background,
            unselectedLabelColor: AppColors.darkText,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'كل الطلبات (${_reservations.length})'),
              Tab(
                text:
                    'المسلمة (${_reservations.where((order) => order.isDelivered).length})',
              ),
              Tab(
                text:
                    'الملغية (${_reservations.where((order) => !order.isDelivered).length})',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildOrdersList(_reservations), // كل الطلبات
                  _buildOrdersList(
                    _reservations.where((order) => order.isDelivered).toList(),
                  ), // المسلمة
                  _buildOrdersList(
                    _reservations.where((order) => !order.isDelivered).toList(),
                  ), // الملغية
                ],
              ),
      ),
    );
  }

  Widget _buildOrdersList(List<Reservation> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text("لا يوجد طلبات في هذه الفئة"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(
          orders[index],
          context,
          showActions:
              !orders[index].isDelivered &&
              _reservations.contains(orders[index]),
        );
      },
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

  Widget _buildOrderCard(
    Reservation order,
    BuildContext context, {
    bool showActions = true,
  }) {
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  order.cardId,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              label: 'وقت الإستلام',
              value: order.formattedTime,
            ),
            const SizedBox(height: 20),

            // --- ENHANCED ACTION BUTTONS ---
            // This setup ensures both buttons have the exact same width.
            showActions
                ? Row(
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
                                sendNotificationToUser(
                                  nationalId: order.userNationalId,
                                  title: 'تم لإلغاء طلبك',
                                  body:
                                      'لقد تم إلغاء طلبك ${order.citizenName}',
                                );
                                print(
                                  'Order from ${order.citizenName} DECLINED.',
                                );
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
                              onConfirm: () async {
                                try {
                                  sendNotificationToUser(
                                    nationalId: order.userNationalId,
                                    title: 'تم قبول طلبك',
                                    body:
                                        'لقد تم قبول طلبك ${order.citizenName} بنجاح',
                                  
                                  );
                                  final querySnapshot = await FirebaseFirestore
                                      .instance
                                      .collection('reservations')
                                      .where('card_id', isEqualTo: order.cardId)
                                      .limit(1)
                                      .get();

                                  final doc = querySnapshot.docs.first;

                                  await doc.reference.update({
                                    'confirmed': true,
                                    'delivered': true, // ← إضافة حالة التسليم
                                    //  'updated_at':
                                    //      FieldValue.serverTimestamp(), // ← اختياري لتتبع وقت التعديل
                                  });

                                  // تحديد مرجع المواطن من nationalId
                                  final citizenQuery = await FirebaseFirestore
                                      .instance
                                      .collection('citizens')
                                      .where(
                                        'national_id',
                                        isEqualTo: order.userNationalId,
                                      )
                                      .limit(1)
                                      .get();

                                  if (citizenQuery.docs.isNotEmpty) {
                                    final citizenDoc = citizenQuery.docs.first;
                                    final currentBread =
                                        citizenDoc['available_bread'] ?? 0;
                                    final updatedBread =
                                        currentBread - order.breadAmount;

                                    await citizenDoc.reference.update({
                                      'available_bread': updatedBread < 0
                                          ? 0
                                          : updatedBread,
                                    });
                                  }

                                  // تحديث الواجهة بعد التعديل

                                  setState(() {
                                    _fetchReservations(_currentBakeryName!);
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم قبول الطلب بنجاح',
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 16,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFD5A253),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  );
                                  print('تم قبول الطلب وتحديث بيانات المواطن.');
                                } catch (e) {
                                  print('فشل في تأكيد الطلب: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'حدث خطأ أثناء تأكيد الطلب',
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      order.isDelivered
                          ? '✅ تم تسليم الطلب'
                          : '❌ تم إلغاء الطلب',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: order.isDelivered ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
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
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
        ),
      ],
    );
  }
}
