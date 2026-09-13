import 'package:equatable/equatable.dart';

/// الحالة الصحية للطالب (شاشة ج٥).
class HealthRecord extends Equatable {
  const HealthRecord({
    required this.available,
    required this.selected,
    this.instructions = '',
    this.reportName,
  });

  /// الأمراض المزمنة المتاحة للاختيار — تأتي من الخادم لتبقى موحّدة بين
  /// التطبيق ونظام المدرسة.
  final List<String> available;

  final List<String> selected;

  /// تعليمات ولي الأمر للمدرسة.
  final String instructions;

  /// اسم التقرير الطبي المرفق، أو `null` حين لا مرفق.
  final String? reportName;

  /// ملخّص يظهر في بطاقة «الحالة الصحية» على الرئيسية.
  String get summary => selected.isEmpty ? 'لا توجد أمراض مسجّلة' : selected.join('، ');

  HealthRecord copyWith({
    List<String>? selected,
    String? instructions,
    String? reportName,
  }) =>
      HealthRecord(
        available: available,
        selected: selected ?? this.selected,
        instructions: instructions ?? this.instructions,
        reportName: reportName ?? this.reportName,
      );

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        available: ((json['available'] as List?) ?? []).map((e) => e.toString()).toList(),
        selected: ((json['selected'] as List?) ?? []).map((e) => e.toString()).toList(),
        instructions: json['instructions']?.toString() ?? '',
        reportName: json['report_name']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'selected': selected,
        'instructions': instructions,
        'report_name': reportName,
      };

  @override
  List<Object?> get props => [available, selected, instructions, reportName];
}
