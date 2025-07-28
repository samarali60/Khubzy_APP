import 'package:flutter/material.dart';

class ProductionRateBar extends StatelessWidget {
  final int dailyQuota;
  final int remainingQuota;

  const ProductionRateBar({
    super.key,
    required this.dailyQuota,
    required this.remainingQuota,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double productionRate =
        (dailyQuota - remainingQuota) / dailyQuota.clamp(1, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("نسبة الإنتاج", style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: productionRate.clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${(productionRate * 100).toStringAsFixed(1)}%",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
