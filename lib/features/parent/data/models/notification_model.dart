import 'package:equatable/equatable.dart';

/// وجهة الإشعار — أي شاشة يفتحها الضغط عليه (شاشة B2).
enum NotificationTarget {
  attendance,
  excuseResult,
  behavior,
  exam,
  circular,
  adminAction,
}

/// إشعار في قائمة الإشعارات.
///
/// إشعار الغياب مجمَّع لكل ابن: ثلاثة أيام متصلة تصل إشعاراً واحداً لا ثلاثة،
/// كما ينصّ التصميم.
class ParentNotification extends Equatable {
  const ParentNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.age,
    required this.target,
    required this.studentId,
    this.read = false,
    this.targetId,
  });

  final String id;
  final String title;
  final String body;

  /// «اليوم» / «أمس» / «قبل 3 أيام» / «متراكم».
  final String age;

  final NotificationTarget target;

  /// الطالب المعني — فتح الإشعار يبدّل الطالب المختار إليه.
  final String studentId;

  final bool read;

  /// معرّف العنصر داخل الشاشة الهدف (اختبار بعينه، تعميم بعينه…).
  final String? targetId;

  ParentNotification copyWith({bool? read}) => ParentNotification(
        id: id,
        title: title,
        body: body,
        age: age,
        target: target,
        studentId: studentId,
        read: read ?? this.read,
        targetId: targetId,
      );

  factory ParentNotification.fromJson(Map<String, dynamic> json) => ParentNotification(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        age: json['age']?.toString() ?? '',
        studentId: json['student_id']?.toString() ?? '',
        targetId: json['target_id']?.toString(),
        read: json['read'] == true,
        target: NotificationTarget.values.firstWhere(
          (e) => e.name == json['target'],
          orElse: () => NotificationTarget.circular,
        ),
      );

  @override
  List<Object?> get props => [id, title, body, age, target, studentId, read, targetId];
}
