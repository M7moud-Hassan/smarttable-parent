import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/attendance_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/usecases/get_attendance_use_case.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

/// تقرير المواظبة وسجلّه (شاشة ج٢).
class AttendanceBloc extends BaseBloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({
    required this.getAttendanceUseCase,
  }) : super(AttendanceInitial()) {
    on<AttendanceEvent>((event, emit) async {
      if (event is GetAttendanceEvent) {
        emit(AttendanceLoading());
        result = await getAttendanceUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(AttendanceFailureState(failure: failure)),
          (value) => emit(AttendanceLoadedState(report: value as AttendanceReport)),
        );
      }
    });
  }

  final GetAttendanceUseCase getAttendanceUseCase;
}
