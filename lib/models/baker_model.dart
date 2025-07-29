class BakerModel {
  final String id;
  final String name;
  final String nationalId;
  final String location;
  final String bakeryName;

  BakerModel({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.location,
    required this.bakeryName,
  });

  factory BakerModel.fromJson(Map<String, dynamic> json) {
    return BakerModel(
      id: int.parse(json['id'].toString()).toString(),
      name: json['name'],
      nationalId: json['national_id'],
      location: json['location'],
      bakeryName: json['bakery_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'national_id': nationalId,
      'location': location,
      'bakery_name': bakeryName,
    };
  }
}
