part of 'stats_bloc.dart';

sealed class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

final class StatsInitial extends StatsState {}

final class StatsLoading extends StatsState {}

final class StatsFailureState extends StatsState {
  const StatsFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class StatsLoadedState extends StatsState {
  const StatsLoadedState({required this.stats, required this.filter});

  final StudentStats stats;
  final StatsFilterEntity filter;

  @override
  List<Object?> get props => [stats, filter];
}
