import 'base_entity.dart';

export 'login_entity.dart';

/// الخطوة الأولى من التسجيل: رقم الجوال المسجَّل لدى المدرسة (شاشة A4).
class PhoneEntity extends BaseEntity {
  const PhoneEntity({required this.phone});

  final String phone;

  @override
  Map<String, dynamic> toJson() => {'phone': phone};
}

/// رمز التحقق المكوَّن من أربع خانات (شاشة A5).
class OtpEntity extends BaseEntity {
  const OtpEntity({required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  Map<String, dynamic> toJson() => {'phone': phone, 'code': code};
}

/// إنشاء الحساب بعد التحقق من الرقم (شاشة A6).
class CreateAccountEntity extends BaseEntity {
  const CreateAccountEntity({
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
  });

  final String phone;
  final String username;
  final String email;
  final String password;

  @override
  Map<String, dynamic> toJson() => {
        'phone': phone,
        'username': username,
        'email': email,
        'password': password,
      };
}

/// تحديث كلمة المرور من رابط الاستعادة (شاشة A9).
class ResetPasswordEntity extends BaseEntity {
  const ResetPasswordEntity({required this.token, required this.password});

  final String token;
  final String password;

  @override
  Map<String, dynamic> toJson() => {'token': token, 'password': password};
}

/// تغيير كلمة المرور من داخل الحساب (شاشة هـ٢).
class ChangePasswordEntity extends BaseEntity {
  const ChangePasswordEntity({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'new_password': newPassword,
      };
}
