import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/behavior_model.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_behavior_use_case.dart';

part 'behavior_event.dart';
part 'behavior_state.dart';

/// تقرير السلوك بتبويبيه وتصفيته الرباعية (شاشة ج٤).
///
/// التصفية تعيش في البلوك لا في الشاشة، لأن كل تغيير فيها يعيد النداء: النتيجة
/// تأتي من الخادم مصفّاة، فلا تُصفّى القائمة مرتين.
class BehaviorBloc extends BaseBloc<BehaviorEvent, BehaviorState> {
  BehaviorBloc({required this.getBehaviorUseCase}) : super(BehaviorInitial()) {
    on<BehaviorEvent>((event, emit) async {
      if (event is GetBehaviorEvent) {
        _filter = event.filter;
        emit(BehaviorLoading());
        result = await getBehaviorUseCase(event.filter);
        result.fold(
          (failure) => emit(BehaviorFailureState(failure: failure)),
          (value) => emit(BehaviorLoadedState(
            report: value as BehaviorReport,
            filter: event.filter,
            tab: _tab,
          )),
        );
      } else if (event is ChangeBehaviorTabEvent) {
        _tab = event.tab;
        final current = state;
        if (current is BehaviorLoadedState) {
          emit(BehaviorLoadedState(
            report: current.report,
            filter: current.filter,
            tab: _tab,
          ));
        }
      }
    });
  }

  final GetBehaviorUseCase getBehaviorUseCase;

  BehaviorFilterEntity? _filter;
  BehaviorTab _tab = BehaviorTab.notes;

  /// التصفية الجارية — تقرأها الشاشة لتبني الحدث التالي فوقها.
  BehaviorFilterEntity? get filter => _filter;
}
