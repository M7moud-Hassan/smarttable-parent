import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String title;

  const Failure({required this.message, required this.title});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$title : $message';
}

class OfflineFailure extends Failure {
  const OfflineFailure({required super.title, required super.message});
}

/// ردّ خطأ من الخادم (404، 500، انتهاء مهلة...). رسالته للسجل فقط — ما يراه
/// المستخدم يعرضه اعتراض dio في إشعار منبثق.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.title});
}

/// خطأ في بيانات أدخلها المستخدم — يُعرض بجانب الحقل لا في إشعار.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, required super.title});
}

/// انتهاء الجلسة — يعيد التطبيق المستخدم إلى شاشة الدخول.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message, required super.title});
}

/// المدرسة لم تفعّل تطبيق ولي الأمر ولا تجربته المجانية. تُعرض بحوار مخصّص
/// (`ParentAppInactiveDialog`) لا برسالة الخادم — فرسالتها هنا عربية ثابتة،
/// احتياطًا فقط لو عرضتها شاشة مباشرة بدل الاستماع لذلك الحوار.
class ParentAppInactiveFailure extends Failure {
  const ParentAppInactiveFailure()
      : super(title: 'غير مفعّل', message: 'التطبيق غير مفعّل في هذه المدرسة.');
}
