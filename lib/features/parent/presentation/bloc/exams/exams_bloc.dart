import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/exam_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/usecases/get_exams_use_case.dart';
import '../../../domain/usecases/get_exam_details_use_case.dart';

part 'exams_event.dart';
part 'exams_state.dart';

/// مواعيد الاختبارات وتفاصيل الموعد الواحد (شاشتا د١ ود٢).
class ExamsBloc extends BaseBloc<ExamsEvent, ExamsState> {
  ExamsBloc({
    required this.getExamsUseCase,
    required this.getExamDetailsUseCase,
  }) : super(ExamsInitial()) {
    on<ExamsEvent>((event, emit) async {
      if (event is GetExamsEvent) {
        emit(ExamsLoading());
        result = await getExamsUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(ExamsFailureState(failure: failure)),
          (value) => emit(ExamsLoadedState(exams: value as List<Exam>)),
        );
      } else if (event is GetExamDetailsEvent) {
        emit(ExamsLoading());
        result = await getExamDetailsUseCase(IdEntity(id: event.examId));
        result.fold(
          (failure) => emit(ExamsFailureState(failure: failure)),
          (value) => emit(ExamDetailsLoadedState(exam: value as Exam)),
        );
      }
    });
  }

  final GetExamsUseCase getExamsUseCase;
  final GetExamDetailsUseCase getExamDetailsUseCase;
}
