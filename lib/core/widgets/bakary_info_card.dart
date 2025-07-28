import 'package:flutter/material.dart';
import 'package:khubzy/models/bakery_model.dart';

class BakeryInfoCard extends StatelessWidget {
  final BakeryModel bakery;

  const BakeryInfoCard({super.key, required this.bakery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("اسم المخبز: ${bakery.bakeryName}", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("المكان: ${bakery.location}", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text("عدد المالكين: ${bakery.ownersNationalIds.length}", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            // Text("رقم التليفون: ${bakery.location}", style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
