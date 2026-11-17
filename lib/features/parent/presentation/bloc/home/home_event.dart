part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class GetHomeEvent extends HomeEvent {
  const GetHomeEvent({required this.studentId, this.onDone});

  final String studentId;

  /// يُستدعى بعد محاولة الجلب دائمًا، سواء تغيّرت الحالة أم لا — كما في
  /// `GetNotificationsEvent`: `emit` لا يبثّ شيئًا إن ساوت النتيجةُ الجديدة
  /// الحالةَ الحالية (`Equatable`)، وهو ما يقع كثيرًا هنا لأن عدّادات
  /// البطاقات تعود كما هي، فيبقى مؤشّر «سحب للتحديث» دائرًا بلا نهاية.
  final VoidCallback? onDone;

  @override
  List<Object?> get props => [studentId];
}
