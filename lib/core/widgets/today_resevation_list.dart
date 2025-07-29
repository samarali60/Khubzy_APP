import 'package:flutter/material.dart';
import 'package:khubzy/models/reservation_model.dart';

class TodayReservationsList extends StatelessWidget {
  final List<Reservation> reservations;

  const TodayReservationsList({
    super.key,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (reservations.isEmpty) {
      return Center(
        child: Text(
          "لا توجد حجوزات اليوم",
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: reservations.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          title: Text(
            reservation.citizenName,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            "الكمية المطلوبة: ${reservation.breadAmount} رغيف\n",
            style: theme.textTheme.bodyMedium,
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
        );
      },
    );
  }
}
