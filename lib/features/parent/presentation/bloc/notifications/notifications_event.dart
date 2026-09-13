part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

final class GetNotificationsEvent extends NotificationsEvent {}

final class MarkAllReadEvent extends NotificationsEvent {}
