part of 'circulars_bloc.dart';

sealed class CircularsState extends Equatable {
  const CircularsState();

  @override
  List<Object?> get props => [];
}

final class CircularsInitial extends CircularsState {}

final class CircularsLoading extends CircularsState {}

final class CircularsFailureState extends CircularsState {
  const CircularsFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class CircularsLoadedState extends CircularsState {
  const CircularsLoadedState({required this.circulars});

  final List<Circular> circulars;

  @override
  List<Object?> get props => [circulars];
}

final class CircularDetailsLoadedState extends CircularsState {
  const CircularDetailsLoadedState({required this.circular});

  final Circular circular;

  @override
  List<Object?> get props => [circular];
}
