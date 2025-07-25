class CitizenModel {
  final String id;
  final String name;
  final String nationalId;
  final String phone;
  final String cardId;
  final int familyMembers;
  final int monthlyBreadQuota;
  final int availableBreadPerDay;
  final int availableBread;

  CitizenModel({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.phone,
    required this.cardId,
    required this.familyMembers,
    required this.monthlyBreadQuota,
    required this.availableBreadPerDay,
    required this.availableBread,
  });

  factory CitizenModel.fromJson(Map<String, dynamic> json) {
    return CitizenModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      nationalId: json['national_id'] ?? '',
      phone: json['phone'] ?? '',
      cardId: json['card_id'] ?? '',
      familyMembers: json['family_members'] ?? 0,
      monthlyBreadQuota: json['monthly_bread_quota'] ?? 0,
      availableBreadPerDay: json['available_bread_per_day'] ?? 0,
      availableBread: json['available_bread'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'national_id': nationalId,
      'phone': phone,
      'card_id': cardId,
      'family_members': familyMembers,
      'monthly_bread_quota': monthlyBreadQuota,
      'available_bread_per_day': availableBreadPerDay,
      'available_bread': availableBread,
    };
  }
}
