import 'package:equatable/equatable.dart';

/// أساس كل ما يُرسَل إلى طبقة البيانات. لا يحمل حقولاً بذاته — يوحّد فقط نوع
/// الوسيط الذي يمرّ من الشاشة إلى حالة الاستخدام إلى المستودع.
abstract class BaseEntity extends Equatable {
  const BaseEntity();

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [toJson()];
}

/// وسيط لا يحمل إلا معرّف الطالب — أكثر ما تحتاجه شاشات الخدمات.
class StudentEntity extends BaseEntity {
  const StudentEntity({required this.studentId});

  final String studentId;

  @override
  Map<String, dynamic> toJson() => {'student_id': studentId};
}

/// وسيط بمعرّف واحد — عنصر يُفتح أو يُحذف.
class IdEntity extends BaseEntity {
  const IdEntity({required this.id});

  final String id;

  @override
  Map<String, dynamic> toJson() => {'id': id};
}
