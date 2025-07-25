class CitizenModel {
  final String id;
  final String name;
  final String nationalId;
  final String email;
  final String password;
  final String phone;
  final String location;

  CitizenModel({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.email,
    required this.password,
    required this.phone,
    required this.location,
  });

factory CitizenModel.fromJson(Map<String, dynamic> json) {
      return CitizenModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        nationalId: json['national_id'].toString(),
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        phone: json['phone'] ?? '',
        location: json['location'] ?? '',
      );
    }
  

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'national_id': nationalId,
      'email': email,
      'password': password,
      'phone': phone,
      'location': location,
    };
  }
}
