  import 'package:flutter/material.dart';

Widget buildTotalReservationsCard(BuildContext context, int reservationCount) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي حجوزات اليوم',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reservationCount.toString(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            Icon(
              Icons.list_alt_outlined,
              size: 50,
              color: Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }

