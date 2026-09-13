import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/schedule_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/usecases/get_schedule_use_case.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

/// جدول أسبوع الطالب المختار (شاشة ج١).
class ScheduleBloc extends BaseBloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc({
    required this.getScheduleUseCase,
  }) : super(ScheduleInitial()) {
    on<ScheduleEvent>((event, emit) async {
      if (event is GetScheduleEvent) {
        emit(ScheduleLoading());
        result = await getScheduleUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(ScheduleFailureState(failure: failure)),
          (value) {
            final week = value as WeekSchedule;
            emit(ScheduleLoadedState(
              week: week,
              selectedDayId: _defaultDay(week),
            ));
          },
        );
      } else if (event is SelectDayEvent) {
        final current = state;
        if (current is ScheduleLoadedState) {
          emit(ScheduleLoadedState(week: current.week, selectedDayId: event.dayId));
        }
      }
    });
  }

  final GetScheduleUseCase getScheduleUseCase;

  /// تفتح الشاشة على يوم اليوم، فإن لم يكن ضمن الأسبوع فعلى أوّل أيامه.
  String _defaultDay(WeekSchedule week) {
    if (week.days.isEmpty) return '';
    final today = week.days.where((d) => d.isToday);
    return today.isEmpty ? week.days.first.id : today.first.id;
  }
}
