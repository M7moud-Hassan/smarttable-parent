import 'package:equatable/equatable.dart';

import '../../../../core/enums/parent_app_state.dart';
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
    this.parentAppState = ParentAppState.ok,
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

  /// أيفتح التطبيق؟ وإن لم يفتح فلماذا — لا اشتراك للمدرسة، أم لا أبناء
  /// مرتبطين بالرقم. والاشتراك المطلوب هو **تطبيق ولي الأمر نفسه** (أو تجربته
  /// المجانية)؛ لا يكفي عنه اشتراك المتابع الإداري ولا الجدول الذكي الأساسي.
  final ParentAppState parentAppState;

  /// يُفتح التطبيق إن كان لولي الأمر ابنٌ واحد في مدرسةٍ مشتركة.
  bool get parentAppActive => parentAppState.isOpen;

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
    ParentAppState? parentAppState,
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
        parentAppState: parentAppState ?? this.parentAppState,
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
        parentAppState: ParentAppState.fromJson(
          json['parent_app_state'],
          active: json['parent_app_active'] as bool? ?? true,
        ),
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
        // الحقلان معًا: `parent_app_state` هو المقروء، و`parent_app_active`
        // يبقى ليصحّ قراءة المخزون لو عاد المستخدم إلى نسخة تطبيقٍ أقدم.
        'parent_app_active': parentAppActive,
        'parent_app_state': parentAppState.wire,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        username,
        email,
        nationalId,
        workplace,
        avatar,
        schoolName,
        parentAppState,
      ];
}
