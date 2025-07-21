import 'package:flutter/material.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حجز الخبز"),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("احجز خبزك الآن", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // هنا يمكنك إضافة نموذج الحجز أو أي محتوى آخر

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // العودة إلى الشاشة السابقة
              },
              child: const Text("العودة إلى الرئيسية"),
            ),
          ],
        ),
      ),
    );
  }
}