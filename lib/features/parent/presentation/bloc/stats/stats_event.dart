part of 'stats_bloc.dart';

sealed class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

final class GetStatsEvent extends StatsEvent {
  const GetStatsEvent({required this.filter});

  final StatsFilterEntity filter;

  @override
  List<Object?> get props => [filter];
}
