part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeFailureState extends HomeState {
  const HomeFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class HomeLoadedState extends HomeState {
  const HomeLoadedState({required this.summary});

  final HomeSummary summary;

  @override
  List<Object?> get props => [summary];
}
