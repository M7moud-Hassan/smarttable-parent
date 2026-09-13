import 'package:equatable/equatable.dart';

import '../../../../core/enums/note_type.dart';

/// ملاحظة سلوك واحدة (تبويب «الملاحظات» في شاشة ج٤).
class BehaviorNote extends Equatable {
  const BehaviorNote({
    required this.id,
    required this.type,
    required this.body,
    required this.teacher,
    required this.subject,
    required this.date,
  });

  final String id;
  final BehaviorNoteType type;

  /// نص الملاحظة: «مشاركة متميزة في حل تمارين الوحدة».
  final String body;

  final String teacher;
  final String subject;

  /// «12 رمضان».
  final String date;

  /// «أ. ماجد القحطاني — الرياضيات».
  String get byline => '$teacher — $subject';

  factory BehaviorNote.fromJson(Map<String, dynamic> json) => BehaviorNote(
        id: json['id']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        teacher: json['teacher']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        type: json['type'] == 'positive'
            ? BehaviorNoteType.positive
            : BehaviorNoteType.needsWork,
      );

  @override
  List<Object?> get props => [id, type, body, teacher, subject, date];
}

/// عمودٌ في مخطّط الأسابيع: الأسبوع وتوزيع ملاحظاته بين إيجابي وسلبي.
class BehaviorBreakdown extends Equatable {
  const BehaviorBreakdown({
    required this.label,
    required this.positive,
    required this.needsWork,
  });

  final String label;
  final int positive;
  final int needsWork;

  int get total => positive + needsWork;

  factory BehaviorBreakdown.fromJson(Map<String, dynamic> json) => BehaviorBreakdown(
        label: json['label']?.toString() ?? '',
        positive: int.tryParse(json['positive']?.toString() ?? '') ?? 0,
        needsWork: int.tryParse(json['needs_work']?.toString() ?? '') ?? 0,
      );

  @override
  List<Object?> get props => [label, positive, needsWork];
}

/// تبويب «الإحصائية» في شاشة ج٤.
class BehaviorStatistics extends Equatable {
  const BehaviorStatistics({
    required this.total,
    required this.positive,
    required this.needsWork,
    required this.weeks,
  });

  final int total;
  final int positive;
  final int needsWork;


  /// أربعة أسابيع بترتيب «قبل 3 · قبل 2 · قبل 1 · الحالي».
  final List<BehaviorBreakdown> weeks;

  int get positivePercent => total == 0 ? 0 : (positive * 100 / total).round();
  int get needsWorkPercent => total == 0 ? 0 : 100 - positivePercent;

  factory BehaviorStatistics.fromJson(Map<String, dynamic> json) => BehaviorStatistics(
        total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
        positive: int.tryParse(json['positive']?.toString() ?? '') ?? 0,
        needsWork: int.tryParse(json['needs_work']?.toString() ?? '') ?? 0,
        weeks: ((json['weeks'] as List?) ?? [])
            .map((e) => BehaviorBreakdown.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [total, positive, needsWork, weeks];
}

/// تقرير السلوك كاملاً: الملاحظات، الإحصائية، وقوائم التصفية.
class BehaviorReport extends Equatable {
  const BehaviorReport({
    required this.notes,
    required this.statistics,
  });

  final List<BehaviorNote> notes;
  final BehaviorStatistics statistics;

  /// قوائم شرائح التصفية — تأتي من الخادم لا من الملاحظات المعروضة، فتبقى
  /// ثابتة حين تُصفّى القائمة.

  factory BehaviorReport.fromJson(Map<String, dynamic> json) => BehaviorReport(
        notes: ((json['notes'] as List?) ?? [])
            .map((e) => BehaviorNote.fromJson(e as Map<String, dynamic>))
            .toList(),
        statistics: BehaviorStatistics.fromJson(
            (json['statistics'] as Map<String, dynamic>?) ?? {}),
      );

  @override
  List<Object?> get props => [notes, statistics];
}
