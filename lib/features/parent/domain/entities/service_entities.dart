import 'package:easy_localization/easy_localization.dart';

import '../../../../core/enums/note_type.dart';
import 'base_entity.dart';

/// تصفية تقرير السلوك (شاشة ج٤): الفترة والنوع.
///
/// لا تصفية بالمادة ولا بالمعلم: سجلّ السلوك لا يحفظ معلّم الملاحظة، والمادة
/// تُقرأ من جدول الفصل فتغيب حين لا يكون للفصل صفٌّ فيه.
class BehaviorFilterEntity extends BaseEntity {
  const BehaviorFilterEntity({
    required this.studentId,
    this.period = BehaviorPeriod.month,
    this.type,
  });

  final String studentId;
  final BehaviorPeriod period;

  /// `null` تعني «الكل».
  final BehaviorNoteType? type;

  bool get hasActiveFilter =>
      type != null || period != BehaviorPeriod.month;

  BehaviorFilterEntity copyWith({
    BehaviorPeriod? period,
    BehaviorNoteType? type,
    bool clearType = false,
  }) =>
      BehaviorFilterEntity(
        studentId: studentId,
        period: period ?? this.period,
        type: clearType ? null : (type ?? this.type),
      );

  @override
  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'period': period.name,
        'type': type?.name,
      };
}

/// فترة تقرير السلوك.
enum BehaviorPeriod {
  week('thisWeek'),
  month('thisMonth'),
  term('thisTerm');

  const BehaviorPeriod(this._key);

  final String _key;

  String get label => _key.tr();
}

/// عذر غياب يغطّي أياماً مختارة من فترة واحدة (شاشة ج٣).
class ExcuseEntity extends BaseEntity {
  const ExcuseEntity({
    required this.studentId,
    required this.periodId,
    required this.dayIds,
    required this.reason,
    this.note = '',
    this.attachmentPath,
  });

  final String studentId;
  final String periodId;

  /// الأيام التي يغطيها العذر — قد تكون بعض أيام الفترة لا كلها.
  final List<String> dayIds;

  final String reason;
  final String note;
  final String? attachmentPath;

  @override
  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'period_id': periodId,
        'days': dayIds,
        'reason': reason,
        'note': note,
        'attachment': attachmentPath,
      };
}

/// حفظ الحالة الصحية (شاشة ج٥).
class HealthEntity extends BaseEntity {
  const HealthEntity({
    required this.studentId,
    required this.diseases,
    required this.instructions,
    this.reportPath,
  });

  final String studentId;
  final List<String> diseases;
  final String instructions;
  final String? reportPath;

  @override
  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'diseases': diseases,
        'instructions': instructions,
        'report': reportPath,
      };
}

/// تحديث البيانات الشخصية (شاشة هـ١).
class ProfileEntity extends BaseEntity {
  const ProfileEntity({
    required this.name,
    required this.nationalId,
    required this.email,
    required this.workplace,
    required this.phone,
    this.avatarPath,
  });

  final String name;
  final String nationalId;
  final String email;
  final String workplace;
  final String phone;
  final String? avatarPath;

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'national_id': nationalId,
        'email': email,
        'workplace': workplace,
        'phone': phone,
        'avatar': avatarPath,
      };
}

/// ردّ ولي الأمر على إجراء إداري (شاشة د٥).
class ActionResponseEntity extends BaseEntity {
  const ActionResponseEntity({required this.actionId, required this.confirmAttendance});

  final String actionId;

  /// `true` تأكيد حضور الاستدعاء، `false` تسجيل اطلاع فقط.
  final bool confirmAttendance;

  @override
  Map<String, dynamic> toJson() =>
      {'action_id': actionId, 'confirm_attendance': confirmAttendance};
}

/// حفظ مفاتيح التنبيهات (شاشة هـ٣).
class NotificationSettingsEntity extends BaseEntity {
  const NotificationSettingsEntity({required this.settings});

  final Map<String, bool> settings;

  @override
  Map<String, dynamic> toJson() => settings;
}

/// نوع الصفحة النصّية المطلوبة — قالب واحد بثلاثة محتويات (شاشة هـ٨).
enum StaticPageKind { about, privacy, terms }

class StaticPageEntity extends BaseEntity {
  const StaticPageEntity({required this.kind});

  final StaticPageKind kind;

  @override
  Map<String, dynamic> toJson() => {'kind': kind.name};
}
