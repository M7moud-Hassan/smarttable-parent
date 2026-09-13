part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class GetHomeEvent extends HomeEvent {
  const GetHomeEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}
