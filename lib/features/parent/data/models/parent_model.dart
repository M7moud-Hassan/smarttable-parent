import 'package:equatable/equatable.dart';

import '../../../../core/utils/phone_format.dart';

/// ولي الأمر — البيانات التي تظهر في الترويسة وشاشتي «حسابي» و«البيانات
/// الشخصية».
class ParentUser extends Equatable {
  const ParentUser({
    required this.id,
    required this.name,
    required this.phone,
    this.username = '',
    this.email = '',
    this.nationalId = '',
    this.workplace = '',
    this.avatar,
    this.schoolName = '',
  });

  final String id;
  final String name;

  /// رقم الجوال هو معرّف الحساب لدى المدرسة (نصّ شاشة هـ١).
  final String phone;

  final String username;
  final String email;
  final String nationalId;
  final String workplace;

  /// رابط الصورة أو مسارها محلياً بعد التقاطها.
  final String? avatar;

  /// اسم مدرسة الطالب المختار — يظهر تحت التحية في الرئيسية.
  final String schoolName;

  /// الرقم بصيغة العرض في شاشة «حسابي»: `+966 55 123 4567`.
  String get displayPhone => PhoneFormat.display(phone);

  /// الرقم مُقنَّعاً كما في شاشة رمز التحقق: `055****567`.
  String get maskedPhone => PhoneFormat.masked(phone);

  ParentUser copyWith({
    String? name,
    String? phone,
    String? username,
    String? email,
    String? nationalId,
    String? workplace,
    String? avatar,
    String? schoolName,
  }) =>
      ParentUser(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        username: username ?? this.username,
        email: email ?? this.email,
        nationalId: nationalId ?? this.nationalId,
        workplace: workplace ?? this.workplace,
        avatar: avatar ?? this.avatar,
        schoolName: schoolName ?? this.schoolName,
      );

  factory ParentUser.fromJson(Map<String, dynamic> json) => ParentUser(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        nationalId: json['national_id']?.toString() ?? '',
        workplace: json['workplace']?.toString() ?? '',
        avatar: json['avatar']?.toString(),
        schoolName: json['school_name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'username': username,
        'email': email,
        'national_id': nationalId,
        'workplace': workplace,
        'avatar': avatar,
        'school_name': schoolName,
      };

  @override
  List<Object?> get props =>
      [id, name, phone, username, email, nationalId, workplace, avatar, schoolName];
}
