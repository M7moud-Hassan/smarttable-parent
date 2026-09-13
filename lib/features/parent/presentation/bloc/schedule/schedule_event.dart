part of 'schedule_bloc.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

final class GetScheduleEvent extends ScheduleEvent {
  const GetScheduleEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

final class SelectDayEvent extends ScheduleEvent {
  const SelectDayEvent({required this.dayId});

  final String dayId;

  @override
  List<Object?> get props => [dayId];
}
