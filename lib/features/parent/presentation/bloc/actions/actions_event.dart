part of 'actions_bloc.dart';

/// تبويبا شاشة د٥: الكل / يتطلب اطلاعك.
enum ActionsTab { all, needsReview }

sealed class ActionsEvent extends Equatable {
  const ActionsEvent();

  @override
  List<Object?> get props => [];
}

final class GetActionsEvent extends ActionsEvent {
  const GetActionsEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

final class ChangeActionsTabEvent extends ActionsEvent {
  const ChangeActionsTabEvent({required this.tab});

  final ActionsTab tab;

  @override
  List<Object?> get props => [tab];
}

/// «تم الاطلاع» أو «تأكيد الحضور» بحسب ما يطلبه الإجراء.
final class RespondToActionEvent extends ActionsEvent {
  const RespondToActionEvent({required this.actionId, required this.confirmAttendance});

  final String actionId;
  final bool confirmAttendance;

  @override
  List<Object?> get props => [actionId, confirmAttendance];
}
