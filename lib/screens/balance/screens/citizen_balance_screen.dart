import 'package:flutter/material.dart';
import 'package:khubzy/core/constants/colors.dart';
import 'package:khubzy/core/widgets/info_card.dart';
import 'package:khubzy/screens/auth/provider/citizen_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class CitizenBalanceScreen extends StatelessWidget {
  const CitizenBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final citizenProvider = Provider.of<CitizenProvider>(context);
    final theme = Theme.of(context);
    if (citizenProvider.currentCitizen == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final monthlyBalance = citizenProvider.totalBalance;
    final remaining = citizenProvider.remainingBalance;
    final consumed = monthlyBalance - remaining;
    final dailyBalance = citizenProvider.dailyBalance;

    if (monthlyBalance <= 0 || remaining < 0) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الرصيد"),
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InfoCard(
              title: "الرصيد الشهري المتاح",
              value: "$monthlyBalance رغيف",
              icon: Icons.breakfast_dining,
            ),

            const SizedBox(height: 8),
            InfoCard(
              title: "الرصيد اليومي المتاح",
              value: "$dailyBalance رغيف",
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: 8),
            InfoCard(
              title: "الرصيد المستهلك خلال الشهر",
              value: "$consumed رغيف",
              icon: Icons.receipt_long,
            ),
            const SizedBox(height: 8),
            InfoCard(
              title: "الرصيد المتبقي خلال الشهر",
              value: "$remaining رغيف",
              icon: Icons.account_balance_wallet,
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: AppColors.primary,
                      value: remaining.toDouble(), // الرصيد المتبقي
                      title: 'المتبقي',
                      radius: 70,
                      titleStyle: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.secondary,
                      value: consumed.toDouble(), // الرصيد المستهلك
                      title: 'المستهلك',
                      radius: 70,
                      titleStyle: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIndicator(color: AppColors.secondary, text: "المستهلك"),
                _buildIndicator(color: AppColors.primary, text: "المتبقي"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
