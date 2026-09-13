import 'package:equatable/equatable.dart';

import '../../../../core/enums/attendance_status.dart';

/// يوم واحد داخل فترة غياب — يظهر كخانة اختيار في شاشة تقديم العذر.
class AbsenceDay extends Equatable {
  const AbsenceDay({required this.id, required this.label, this.selected = false});

  final String id;

  /// «الأحد 10 رمضان».
  final String label;

  final bool selected;

  AbsenceDay copyWith({bool? selected}) =>
      AbsenceDay(id: id, label: label, selected: selected ?? this.selected);

  factory AbsenceDay.fromJson(Map<String, dynamic> json) => AbsenceDay(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [id, label, selected];
}

/// سطر في سجل المواظبة.
///
/// أيام الغياب المتصلة تصل من الخادم مجموعة في سطر واحد — وهذا هو أساس قاعدة
/// «عذر واحد يغطي الفترة» التي تتكرّر في التصميم.
class AttendanceEntry extends Equatable {
  const AttendanceEntry({
    required this.id,
    required this.title,
    required this.status,
    required this.detail,
    this.days = const [],
    this.excuseStatus = ExcuseStatus.none,
    this.canSubmitExcuse = false,
  });

  final String id;

  /// «غياب متصل — 3 أيام» أو «الخميس 7 رمضان».
  final String title;

  final AttendanceStatus status;

  /// «من الأحد 10 رمضان إلى الثلاثاء 12 رمضان».
  final String detail;

  /// أيام الفترة — فارغة لليوم المفرد.
  final List<AbsenceDay> days;

  final ExcuseStatus excuseStatus;

  /// يظهر زر «تقديم عذر لهذه الفترة» فقط حين تسمح الإدارة بذلك.
  final bool canSubmitExcuse;

  /// عدد الأيام المعروض في الشارة — يُخفى حين يكون يوماً واحداً.
  int get dayCount => days.isEmpty ? 1 : days.length;

  AttendanceEntry copyWith({ExcuseStatus? excuseStatus, bool? canSubmitExcuse}) =>
      AttendanceEntry(
        id: id,
        title: title,
        status: status,
        detail: detail,
        days: days,
        excuseStatus: excuseStatus ?? this.excuseStatus,
        canSubmitExcuse: canSubmitExcuse ?? this.canSubmitExcuse,
      );

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) => AttendanceEntry(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        detail: json['detail']?.toString() ?? '',
        status: AttendanceStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AttendanceStatus.present,
        ),
        excuseStatus: ExcuseStatus.values.firstWhere(
          (e) => e.name == json['excuse_status'],
          orElse: () => ExcuseStatus.none,
        ),
        canSubmitExcuse: json['can_submit_excuse'] == true,
        days: ((json['days'] as List?) ?? [])
            .map((e) => AbsenceDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props =>
      [id, title, status, detail, days, excuseStatus, canSubmitExcuse];
}

/// ملخّص المواظبة أعلى الشاشة: النسبة وأعداد الحضور والتأخر والغياب.
class AttendanceReport extends Equatable {
  const AttendanceReport({
    required this.termLabel,
    required this.percentage,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.entries,
    this.warning,
  });

  /// «الفصل الدراسي الثاني».
  final String termLabel;

  final int percentage;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final List<AttendanceEntry> entries;

  /// «غياب بدون عذر: 3 أيام في فترة واحدة متصلة» — يُخفى حين لا يوجد.
  final String? warning;

  factory AttendanceReport.fromJson(Map<String, dynamic> json) => AttendanceReport(
        termLabel: json['term']?.toString() ?? '',
        percentage: int.tryParse(json['percentage']?.toString() ?? '') ?? 0,
        presentDays: int.tryParse(json['present']?.toString() ?? '') ?? 0,
        lateDays: int.tryParse(json['late']?.toString() ?? '') ?? 0,
        absentDays: int.tryParse(json['absent']?.toString() ?? '') ?? 0,
        warning: json['warning']?.toString(),
        entries: ((json['entries'] as List?) ?? [])
            .map((e) => AttendanceEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props =>
      [termLabel, percentage, presentDays, lateDays, absentDays, entries, warning];
}

/// نموذج شاشة تقديم العذر: الفترة وأسبابها معًا.
///
/// الأسباب قائمةٌ يملكها الخادم لا التطبيق — تُعدَّل المدرسة قائمتها بلا
/// إصدارٍ جديد. وتصل مع الفترة في نداءٍ واحد لأن الشاشة تعرضهما معًا.
class ExcuseForm extends Equatable {
  const ExcuseForm({required this.period, required this.reasons});

  final AttendanceEntry period;
  final List<String> reasons;

  factory ExcuseForm.fromJson(Map<String, dynamic> json) => ExcuseForm(
        period: AttendanceEntry.fromJson(json),
        reasons: ((json['reasons'] as List?) ?? []).map((e) => e.toString()).toList(),
      );

  @override
  List<Object?> get props => [period, reasons];
}
