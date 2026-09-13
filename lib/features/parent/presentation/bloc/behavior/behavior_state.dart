part of 'behavior_bloc.dart';

sealed class BehaviorState extends Equatable {
  const BehaviorState();

  @override
  List<Object?> get props => [];
}

final class BehaviorInitial extends BehaviorState {}

final class BehaviorLoading extends BehaviorState {}

final class BehaviorFailureState extends BehaviorState {
  const BehaviorFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class BehaviorLoadedState extends BehaviorState {
  const BehaviorLoadedState({
    required this.report,
    required this.filter,
    required this.tab,
  });

  final BehaviorReport report;
  final BehaviorFilterEntity filter;
  final BehaviorTab tab;

  /// «7 ملاحظة · هذا الشهر».
  String get countLabel => '${report.notes.length} ملاحظة · ${filter.period.label}';

  @override
  List<Object?> get props => [report, filter, tab];
}
