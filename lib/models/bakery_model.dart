class BakeryModel {
  final int id;
  final String bakeryName;
  final String location;
  final String ownersNationalId;
  final int dailyQuota;
  int remainingQuota;
  final int productionRate;
  final double rating;
  String? lastResetDate; // تاريخ آخر تصفير (YYYY-MM-DD)

  BakeryModel({
    required this.id,
    required this.bakeryName,
    required this.location,
    required this.ownersNationalId,
    required this.dailyQuota,
    required this.remainingQuota,
    required this.productionRate,
    required this.rating,
    this.lastResetDate,
  });

  factory BakeryModel.fromJson(Map<String, dynamic> json) {
    return BakeryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      bakeryName: json['bakery_name'] ?? '',
      location: json['location'] ?? '',
      ownersNationalId: json['owners_national_id'] ?? '',
      dailyQuota: json['daily_quota'] ?? 0,
      remainingQuota: json['remaining_quota'] ?? 0,
      productionRate: json['production_rate'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      lastResetDate: json['last_reset_date'], // ممكن تكون null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bakery_name': bakeryName,
      'location': location,
      'owners_national_id': ownersNationalId,
      'daily_quota': dailyQuota,
      'remaining_quota': remainingQuota,
      'production_rate': productionRate,
      'rating': rating,
      'last_reset_date': lastResetDate,
    };
  }
}