class BakeryModel {
  final int id;
  final String bakeryName;
  final String location;
  final String ownersNationalId;
  final int dailyQuota;
 int remainingQuota;
  final int productionRate;
  final double rating;

  BakeryModel({
    required this.id,
    required this.bakeryName,
    required this.location,
    required this.ownersNationalId,
    required this.dailyQuota,
    required this.remainingQuota,
    required this.productionRate,
    required this.rating,
  });

  factory BakeryModel.fromJson(Map<String, dynamic> json) {
    return BakeryModel(
      id: int.parse(json['id'].toString()),
      bakeryName: json['bakery_name'],
      location: json['location'],
      ownersNationalId: json['owners_national_id'],
      dailyQuota: json['daily_quota'],
      remainingQuota: json['remaining_quota'],
      productionRate: json['production_rate'],
      rating: (json['rating'] as num).toDouble(),
    );
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bakery_name': bakeryName,
      'location': location,
      'owners_national_id': ownersNationalId,
    };
  }
}
