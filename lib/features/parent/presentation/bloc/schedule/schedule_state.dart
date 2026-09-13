part of 'schedule_bloc.dart';

sealed class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

final class ScheduleInitial extends ScheduleState {}

final class ScheduleLoading extends ScheduleState {}

final class ScheduleFailureState extends ScheduleState {
  const ScheduleFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class ScheduleLoadedState extends ScheduleState {
  const ScheduleLoadedState({required this.week, required this.selectedDayId});

  final WeekSchedule week;
  final String selectedDayId;

  /// اليوم المعروض جدوله الآن.
  ScheduleDay? get selectedDay {
    for (final day in week.days) {
      if (day.id == selectedDayId) return day;
    }
    return week.days.isEmpty ? null : week.days.first;
  }

  @override
  List<Object?> get props => [week, selectedDayId];
}
