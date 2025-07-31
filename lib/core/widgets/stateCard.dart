  
  import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Widget buildStatCard({
    required BuildContext context,
    required String title,
    required int value,
    int? total,
    double? percentage,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Icon(icon, color: color),
              ],
            ),
            Expanded(
              child: Center(
                child: (percentage != null && total != null)
                    ? CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 8.0,
                        percent: percentage.clamp(0.0, 1.0),
                        center: Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold, color: color),
                        ),
                        progressColor: color,
                        backgroundColor: color.withOpacity(0.2),
                        circularStrokeCap: CircularStrokeCap.round,
                      )
                    : Text(
                        value.toString(),
                        style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold, color: color),
                      ),
              ),
            ),
            if (total != null)
              Text(
                '$value / $total',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              )
          ],
        ),
      ),
    );
  }
