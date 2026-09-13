import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/health_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_health_use_case.dart';
import '../../../domain/usecases/save_health_use_case.dart';

part 'health_event.dart';
part 'health_state.dart';

/// الحالة الصحية للطالب: أمراض مزمنة، تعليمات للمدرسة، وتقرير طبي (شاشة ج٥).
class HealthBloc extends BaseBloc<HealthEvent, HealthState> {
  HealthBloc({
    required this.getHealthUseCase,
    required this.saveHealthUseCase,
  }) : super(HealthInitial()) {
    on<HealthEvent>((event, emit) async {
      if (event is GetHealthEvent) {
        emit(HealthLoading());
        result = await getHealthUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(HealthFailureState(failure: failure)),
          (value) {
            _record = value as HealthRecord;
            emit(HealthFormState(record: _record!));
          },
        );
      } else if (event is ToggleDiseaseEvent) {
        final record = _record;
        if (record == null) return;
        final selected = List<String>.from(record.selected);
        selected.contains(event.disease)
            ? selected.remove(event.disease)
            : selected.add(event.disease);
        _record = record.copyWith(selected: selected);
        emit(HealthFormState(record: _record!, attachmentPath: _attachment));
      } else if (event is ChangeInstructionsEvent) {
        final record = _record;
        if (record == null) return;
        _record = record.copyWith(instructions: event.instructions);
        emit(HealthFormState(record: _record!, attachmentPath: _attachment));
      } else if (event is AttachMedicalReportEvent) {
        _attachment = event.path;
        final record = _record;
        if (record == null) return;
        _record = record.copyWith(reportName: event.path.split(RegExp(r'[\\/]')).last);
        emit(HealthFormState(record: _record!, attachmentPath: _attachment));
      } else if (event is SaveHealthEvent) {
        final record = _record;
        if (record == null) return;
        result = await saveHealthUseCase(HealthEntity(
          studentId: event.studentId,
          diseases: record.selected,
          instructions: record.instructions,
          reportPath: _attachment,
        ));
        result.fold(
          (failure) => emit(HealthFailureState(failure: failure)),
          (_) {
            // الرسالة ثم النموذج بقيمه: الشاشة تسمع الأولى وتُعيد بناء
            // الثانية، فلا تحتاج إلى استدعاء يعيدها بنفسها.
            emit(HealthSavedState());
            emit(HealthFormState(record: record, attachmentPath: _attachment));
          },
        );
      }
    });
  }

  final GetHealthUseCase getHealthUseCase;
  final SaveHealthUseCase saveHealthUseCase;

  HealthRecord? _record;
  String? _attachment;
}
