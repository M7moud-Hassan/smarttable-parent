import 'package:equatable/equatable.dart';

/// حصّة واحدة في الجدول المدرسي (شاشة ج١).
class Lesson extends Equatable {
  const Lesson({
    required this.order,
    required this.subject,
    required this.teacher,
    required this.from,
    required this.to,
    this.isCurrent = false,
  });

  /// ترتيب الحصة نصّاً كما في التصميم: «الأولى»، «الثانية»…
  final String order;

  final String subject;
  final String teacher;
  final String from;
  final String to;

  /// الحصة الجارية الآن — تُميَّز بخلفية وحدّ بلون الهوية.
  final bool isCurrent;

  String get timeRange => '\u2066$from - $to\u2069';

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        order: json['order']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        teacher: json['teacher']?.toString() ?? '',
        from: json['from']?.toString() ?? '',
        to: json['to']?.toString() ?? '',
        isCurrent: json['is_current'] == true,
      );

  @override
  List<Object?> get props => [order, subject, teacher, from, to, isCurrent];
}

/// يوم في شريط أيام الجدول: «الثلاثاء / 12».
class ScheduleDay extends Equatable {
  const ScheduleDay({
    required this.id,
    required this.weekday,
    required this.dayNumber,
    required this.lessons,
    this.isToday = false,
  });

  final String id;
  final String weekday;

  /// رقم اليوم في الشهر الهجري.
  final String dayNumber;

  final List<Lesson> lessons;
  final bool isToday;

  Lesson? get currentLesson {
    for (final lesson in lessons) {
      if (lesson.isCurrent) return lesson;
    }
    return null;
  }

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => ScheduleDay(
        id: json['id']?.toString() ?? '',
        weekday: json['weekday']?.toString() ?? '',
        dayNumber: json['day']?.toString() ?? '',
        isToday: json['is_today'] == true,
        lessons: ((json['lessons'] as List?) ?? [])
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, weekday, dayNumber, isToday, lessons];
}

/// جدول أسبوع كامل مع اسم الشهر الهجري وعدّاد الحصة الحالية.
class WeekSchedule extends Equatable {
  const WeekSchedule({
    required this.hijriMonth,
    required this.days,
    this.remainingInCurrentLesson = '',
  });

  /// «رمضان 1447».
  final String hijriMonth;

  final List<ScheduleDay> days;

  /// الوقت المتبقي من الحصة الحالية بصيغة `mm:ss`.
  final String remainingInCurrentLesson;

  factory WeekSchedule.fromJson(Map<String, dynamic> json) => WeekSchedule(
        hijriMonth: json['hijri_month']?.toString() ?? '',
        remainingInCurrentLesson: json['remaining']?.toString() ?? '',
        days: ((json['days'] as List?) ?? [])
            .map((e) => ScheduleDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [hijriMonth, days, remainingInCurrentLesson];
}
