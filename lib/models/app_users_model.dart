// مثال مستخدم
class AppUser {
  final String phone;
  final String password;
  final String userType;

  AppUser({required this.phone, required this.password, required this.userType});

  Map<String, dynamic> toMap() => {
        'phone': phone,
        'password': password,
        'userType': userType,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        phone: map['phone'],
        password: map['password'],
        userType: map['userType'],
      );
}
