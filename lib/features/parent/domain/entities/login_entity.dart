import 'base_entity.dart';

/// بيانات الدخول المحفوظة — يقرأها اعتراض dio ليضعها في ترويسة كل طلب،
/// ويقرأها الإقلاع ليعرف هل يفتح الرئيسية أم شاشة الدخول.
class LoginEntity extends BaseEntity {
  const LoginEntity({required this.username, required this.password});

  final String username;
  final String password;

  @override
  Map<String, dynamic> toJson() => {'username': username, 'password': password};

  factory LoginEntity.fromJson(Map<String, dynamic> json) => LoginEntity(
        username: json['username']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
      );
}
