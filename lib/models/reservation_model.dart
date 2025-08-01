import 'package:intl/intl.dart';

class Reservation {
  final String citizenName;
  final String userNationalId;
  final int breadAmount;
  final int numberOfDays;
  final String bekaryNationalId;
  final DateTime reservationDateTime;
  final bool isDelivered;

  Reservation({
    required this.citizenName,
    required this.userNationalId,
    required this.breadAmount,
    required this.numberOfDays,
    required this.reservationDateTime,
    required this.bekaryNationalId,
    required this.isDelivered,
  });

  // Helper to format the date string
  String get formattedDate {
    return DateFormat('yyyy/MM/dd', 'ar_EG').format(reservationDateTime);
  }

  // Helper to format the time string
  String get formattedTime {
    return DateFormat('hh:mm a', 'ar_EG').format(reservationDateTime);
  }
}
