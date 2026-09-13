import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/conts/ui_content.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/attendance_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_absence_period_use_case.dart';
import '../../../domain/usecases/submit_excuse_use_case.dart';

part 'excuse_event.dart';
part 'excuse_state.dart';

/// تقديم عذر غياب على فترة متصلة (شاشة ج٣).
///
/// أيام الفترة تُعرض بلا اختيار، ويختار ولي الأمر ما يغطّيه العذر. واستثناء
/// يوم من وسط ما اختاره يُنبَّه عليه، لأنه يبقى بلا عذر بين يومين معذورين.
class ExcuseBloc extends BaseBloc<ExcuseEvent, ExcuseState> {
  ExcuseBloc({
    required this.getAbsencePeriodUseCase,
    required this.submitExcuseUseCase,
  }) : super(ExcuseInitial()) {
    on<ExcuseEvent>((event, emit) async {
      if (event is GetAbsencePeriodEvent) {
        emit(ExcuseLoading());
        result = await getAbsencePeriodUseCase(IdEntity(id: event.periodId));
        result.fold(
          (failure) => emit(ExcuseFailureState(failure: failure)),
          (value) {
            final form = value as ExcuseForm;
            // تُفتح الشاشة بلا اختيار كما في التصميم، فلا يُرسل عذر عن يوم
            // لم يقصده ولي الأمر لمجرّد أنه لم ينتبه إلى إلغائه.
            _days = form.period.days;
            // قائمةٌ فارغة من الخادم تترك الشاشة بلا خيارات فيتعذّر الإرسال.
            _reasons = form.reasons.isEmpty ? UiContent.excuseReasons : form.reasons;
            emit(_form(form.period));
          },
        );
      } else if (event is ToggleExcuseDayEvent) {
        _days = _days
            .map((d) => d.id == event.dayId ? d.copyWith(selected: !d.selected) : d)
            .toList();
        _emitForm(emit);
      } else if (event is SelectExcuseReasonEvent) {
        _reason = event.reason;
        _emitForm(emit);
      } else if (event is ChangeExcuseNoteEvent) {
        _note = event.note;
        _emitForm(emit);
      } else if (event is AttachExcuseFileEvent) {
        _attachment = event.path;
        _emitForm(emit);
      } else if (event is SubmitExcuseEvent) {
        final period = _period;
        if (period == null) return;
        result = await submitExcuseUseCase(ExcuseEntity(
          studentId: event.studentId,
          periodId: period.id,
          dayIds: _days.where((d) => d.selected).map((d) => d.id).toList(),
          reason: _reason ?? '',
          note: _note,
          attachmentPath: _attachment,
        ));
        result.fold(
          (failure) => emit(ExcuseFailureState(failure: failure)),
          (_) => emit(ExcuseSubmittedState()),
        );
      }
    });
  }

  final GetAbsencePeriodUseCase getAbsencePeriodUseCase;
  final SubmitExcuseUseCase submitExcuseUseCase;

  AttendanceEntry? _period;
  List<AbsenceDay> _days = [];
  List<String> _reasons = UiContent.excuseReasons;
  String? _reason;
  String _note = '';
  String? _attachment;

  ExcuseFormState _form(AttendanceEntry period) {
    _period = period;
    return ExcuseFormState(
      period: period,
      days: _days,
      reasons: _reasons,
      reason: _reason,
      note: _note,
      attachment: _attachment,
    );
  }

  void _emitForm(Emitter<ExcuseState> emit) {
    final period = _period;
    if (period != null) emit(_form(period));
  }
}
