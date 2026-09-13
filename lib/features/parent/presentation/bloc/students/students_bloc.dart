import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/app_utils.dart';
import '../../../data/models/student_model.dart';
import '../../../domain/usecases/get_students_use_case.dart';

part 'students_event.dart';
part 'students_state.dart';

/// أبناء ولي الأمر والطالب المختار.
///
/// الاختيار حالة عامّة لا حالة شاشة: كل شاشة خدمة تقرأ الطالب المختار، وشريط
/// الأبناء في الرئيسية والشريط الجانبي في التابلت يبدّلانه، فيُحفظ في
/// `AppUtils` ويُعاد بثّه من هنا.
class StudentsBloc extends BaseBloc<StudentsEvent, StudentsState> {
  StudentsBloc({required this.getStudentsUseCase}) : super(StudentsInitial()) {
    on<StudentsEvent>((event, emit) async {
      if (event is GetStudentsEvent) {
        emit(StudentsLoading());
        result = await getStudentsUseCase();
        result.fold(
          (failure) => emit(StudentsFailureState(failure: failure)),
          (value) {
            final students = value as List<Student>;
            AppUtils.students = students;
            _restoreSelection(students);
            emit(StudentsLoadedState(
              students: students,
              selected: AppUtils.selectedStudent,
            ));
          },
        );
      } else if (event is SelectStudentEvent) {
        AppUtils.selectStudent(event.student);
        emit(StudentsLoadedState(
          students: AppUtils.students,
          selected: event.student,
        ));
      }
    });
  }

  final GetStudentsUseCase getStudentsUseCase;

  /// يعيد اختيار الطالب المحفوظ إن كان ما يزال مرتبطاً بولي الأمر، وإلا يقع
  /// الاختيار على الأول — فلا تُفتح الرئيسية بلا طالب.
  void _restoreSelection(List<Student> students) {
    if (students.isEmpty) {
      AppUtils.selectedStudent = null;
      return;
    }
    final savedId = AppUtils.instance.getSelectedStudentId();
    final match = students.where((s) => s.id == savedId);
    AppUtils.selectedStudent = match.isEmpty ? students.first : match.first;
  }
}
