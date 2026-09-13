import 'package:equatable/equatable.dart';

/// سطر «الدرجة / المدة / المقرر» في تفاصيل الاختبار — محتوى حرّ يكتبه المعلم،
/// فلا يُفترض عدد بنوده ولا أسماؤها.
class ExamDetailRow extends Equatable {
  const ExamDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  factory ExamDetailRow.fromJson(Map<String, dynamic> json) => ExamDetailRow(
        label: json['label']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [label, value];
}

/// موعد اختبار (شاشتا د١ ود٢).
class Exam extends Equatable {
  const Exam({
    required this.id,
    required this.subject,
    required this.dayNumber,
    required this.monthName,
    required this.weekday,
    required this.from,
    required this.to,
    required this.place,
    required this.daysAway,
    this.fullDate = '',
    this.teacher = '',
    this.details = const [],
    this.topics = const [],
    this.notes,
  });

  final String id;
  final String subject;

  /// «17» — يظهر في المربّع الملوّن يمين البطاقة.
  final String dayNumber;

  /// «رمضان».
  final String monthName;

  final String weekday;
  final String from;
  final String to;
  final String place;

  /// كم يوماً يفصلنا عن الاختبار — يحدّد لون الشارة ونصّها.
  final int daysAway;

  /// «الأحد 17 رمضان 1447».
  final String fullDate;

  final String teacher;

  /// ما كتبه المعلم: الدرجة، المدة، المقرر…
  final List<ExamDetailRow> details;

  final List<String> topics;
  final String? notes;

  /// «الأحد · 07:00 - 08:30» — والمدى الزمني معزول الاتجاه كي لا ينقلب.
  String get timeLabel => '$weekday · \u2066$from - $to\u2069';

  /// نصّ الشارة: «بعد 5 أيام» / «بعد 12 يوماً».
  String get countdownLabel {
    if (daysAway <= 0) return 'اليوم';
    if (daysAway == 1) return 'غداً';
    if (daysAway <= 10) return 'بعد $daysAway أيام';
    return 'بعد $daysAway يوماً';
  }

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
        id: json['id']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        dayNumber: json['day']?.toString() ?? '',
        monthName: json['month']?.toString() ?? '',
        weekday: json['weekday']?.toString() ?? '',
        from: json['from']?.toString() ?? '',
        to: json['to']?.toString() ?? '',
        place: json['place']?.toString() ?? '',
        daysAway: int.tryParse(json['days_away']?.toString() ?? '') ?? 0,
        fullDate: json['full_date']?.toString() ?? '',
        teacher: json['teacher']?.toString() ?? '',
        notes: json['notes']?.toString(),
        details: ((json['details'] as List?) ?? [])
            .map((e) => ExamDetailRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        topics: ((json['topics'] as List?) ?? []).map((e) => e.toString()).toList(),
      );

  @override
  List<Object?> get props =>
      [id, subject, dayNumber, monthName, weekday, from, to, place, daysAway];
}
