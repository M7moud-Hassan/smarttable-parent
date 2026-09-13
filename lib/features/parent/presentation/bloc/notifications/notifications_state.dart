part of 'notifications_bloc.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {}

final class NotificationsLoading extends NotificationsState {}

final class NotificationsFailureState extends NotificationsState {
  const NotificationsFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class NotificationsLoadedState extends NotificationsState {
  const NotificationsLoadedState({required this.notifications});

  final List<ParentNotification> notifications;

  int get unreadCount => notifications.where((n) => !n.read).length;

  @override
  List<Object?> get props => [notifications];
}
