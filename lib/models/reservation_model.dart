import 'package:intl/intl.dart';

class Reservation {
  final String citizenName;
  final String userNationalId;
  final int breadAmount;
  final int numberOfDays;
  final String bekaryNationalId;
  final DateTime reservationDateTime;
  final bool isDelivered;
  final bool isConfirmed ; // Assuming this is a default value
  final String cardId;

  Reservation({
    required this.citizenName,
    required this.userNationalId,
    required this.breadAmount,
    required this.numberOfDays,
    required this.reservationDateTime,
    required this.bekaryNationalId,
  required this.isDelivered,
  required this.isConfirmed,
    required this.cardId,
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
