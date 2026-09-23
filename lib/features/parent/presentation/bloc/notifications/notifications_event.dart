part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

final class GetNotificationsEvent extends NotificationsEvent {
  const GetNotificationsEvent({this.onDone});

  /// يُستدعى بعد محاولة الجلب دائمًا، سواء تغيّرت الحالة أم لا — الاعتماد
  /// على تدفّق الحالة نفسه (كما في `RefreshIndicator`) لا يكفي: `emit` لا
  /// يبثّ شيئًا إن كانت النتيجة الجديدة تساوي الحالة الحالية (`Equatable`)،
  /// وهو ما يحدث غالبًا حين لا تصل إشعارات جديدة.
  final VoidCallback? onDone;
}

final class MarkAllReadEvent extends NotificationsEvent {}
