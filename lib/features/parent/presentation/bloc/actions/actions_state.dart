part of 'actions_bloc.dart';

sealed class ActionsState extends Equatable {
  const ActionsState();

  @override
  List<Object?> get props => [];
}

final class ActionsInitial extends ActionsState {}

final class ActionsLoading extends ActionsState {}

final class ActionsFailureState extends ActionsState {
  const ActionsFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// ردّ ولي الأمر سُجّل — تعرض الشاشة رسالة ثم تبقى على القائمة المحدَّثة.
final class ActionRespondedState extends ActionsState {
  const ActionRespondedState({required this.confirmedAttendance});

  final bool confirmedAttendance;

  @override
  List<Object?> get props => [confirmedAttendance, DateTime.now().microsecondsSinceEpoch];
}

final class ActionsLoadedState extends ActionsState {
  const ActionsLoadedState({required this.actions, required this.tab});

  final List<AdminAction> actions;
  final ActionsTab tab;

  /// ما يُعرض فعلاً بحسب التبويب المختار.
  List<AdminAction> get visible =>
      tab == ActionsTab.all ? actions : actions.where((a) => a.needsParent).toList();

  @override
  List<Object?> get props => [actions, tab];
}
