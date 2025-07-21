import 'package:flutter/material.dart';
import 'package:khubzy/core/widgets/custom_button.dart';
import 'package:khubzy/core/widgets/info_card.dart';
import 'package:khubzy/core/widgets/section_title.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("خبزي"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("أهلاً يا سمر 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            const SectionTitle(title: "رصيدك الحالي", icon: Icons.account_balance_wallet),
            const SizedBox(height: 8),

            const InfoCard(title: "عدد الأرغفة المتاحة", value: "14 رغيف", icon: Icons.local_dining),
            const SizedBox(height: 20),

            CustomButton(
              text: "احجز خبز الآن",
              onPressed: () {
                Navigator.pushNamed(context, "/reservation");
              },
            ),

            const SizedBox(height: 30),
            const SectionTitle(title: "المخابز القريبة", icon: Icons.store),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: const [
                  InfoCard(title: "مخبز النصر", value: "يبعد 300 متر", icon: Icons.location_on),
                  InfoCard(title: "مخبز النيل", value: "يبعد 500 متر", icon: Icons.location_on),
                ],
              ),
            ),
          ],
        ),
      ),

);
  }
}
