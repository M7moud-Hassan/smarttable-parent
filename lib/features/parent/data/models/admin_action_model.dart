import 'package:equatable/equatable.dart';

import '../../../../core/enums/note_type.dart';

/// إجراء إداري صادر عن ملاحظة مسجَّلة على الطالب (شاشة د٥).
///
/// الإجراء لا يقوم بذاته: لكل إجراء ملاحظة مرتبطة ورقم تكرارها، والضغط على
/// الملاحظة ينقل إلى سجل المواظبة أو تقرير السلوك بحسب مصدرها.
class AdminAction extends Equatable {
  const AdminAction({
    required this.id,
    required this.title,
    required this.date,
    required this.issuer,
    required this.source,
    required this.state,
    required this.linkedNote,
    required this.occurrenceLabel,
    required this.body,
    this.highlight,
    this.appointment,
  });

  final String id;

  /// «استدعاء ولي الأمر»، «حسم درجات المواظبة»…
  final String title;

  /// «12 رمضان».
  final String date;

  /// «وكيل شؤون الطلاب».
  final String issuer;

  final AdminActionSource source;
  final AdminActionState state;

  /// نص الملاحظة التي أنتجت الإجراء.
  final String linkedNote;

  /// «المرة الثانية على هذه الملاحظة».
  final String occurrenceLabel;

  /// شرح الإجراء الموجّه لولي الأمر.
  final String body;

  /// سطر أحمر بارز داخل البطاقة — «حُسم 2 من 10 درجات».
  final String? highlight;

  /// موعد الاستدعاء حين يتطلب الإجراء تأكيد حضور.
  final String? appointment;

  /// «12 رمضان · وكيل شؤون الطلاب».
  String get byline => '$date · $issuer';

  bool get needsParent => state != AdminActionState.seen;

  AdminAction copyWith({AdminActionState? state}) => AdminAction(
        id: id,
        title: title,
        date: date,
        issuer: issuer,
        source: source,
        state: state ?? this.state,
        linkedNote: linkedNote,
        occurrenceLabel: occurrenceLabel,
        body: body,
        highlight: highlight,
        appointment: appointment,
      );

  factory AdminAction.fromJson(Map<String, dynamic> json) => AdminAction(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        issuer: json['issuer']?.toString() ?? '',
        linkedNote: json['linked_note']?.toString() ?? '',
        occurrenceLabel: json['occurrence']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        highlight: json['highlight']?.toString(),
        appointment: json['appointment']?.toString(),
        source: json['source'] == 'behavior'
            ? AdminActionSource.behavior
            : AdminActionSource.attendance,
        state: AdminActionState.values.firstWhere(
          (e) => e.name == json['state'],
          orElse: () => AdminActionState.seen,
        ),
      );

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        issuer,
        source,
        state,
        linkedNote,
        occurrenceLabel,
        body,
        highlight,
        appointment
      ];
}
