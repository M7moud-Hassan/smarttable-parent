part of 'circulars_bloc.dart';

sealed class CircularsEvent extends Equatable {
  const CircularsEvent();

  @override
  List<Object?> get props => [];
}

final class GetCircularsEvent extends CircularsEvent {
  const GetCircularsEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

final class GetCircularDetailsEvent extends CircularsEvent {
  const GetCircularDetailsEvent({required this.circularId});

  final String circularId;

  @override
  List<Object?> get props => [circularId];
}
