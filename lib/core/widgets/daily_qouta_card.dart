import 'package:flutter/material.dart';
import 'package:khubzy/models/bakery_model.dart';

class DailyQuotaCard extends StatelessWidget {
  final BakeryModel bakery;

  const DailyQuotaCard({super.key, required this.bakery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double productionRate = bakery.remainingQuota / bakery.dailyQuota;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("تفاصيل الحصة اليومية", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text("إجمالي الحصة: ${bakery.dailyQuota} رغيف", style: theme.textTheme.bodyMedium),
            Text("المتبقي: ${bakery.remainingQuota} رغيف", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text("نسبة الإنتاج", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: productionRate.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 6),
            Text("${(productionRate * 100).toStringAsFixed(1)}%", style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
