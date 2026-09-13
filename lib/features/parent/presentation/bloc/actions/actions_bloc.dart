import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/admin_action_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_admin_actions_use_case.dart';
import '../../../domain/usecases/respond_to_action_use_case.dart';

part 'actions_event.dart';
part 'actions_state.dart';

/// الإجراءات الإدارية وردّ ولي الأمر عليها (شاشة د٥).
class ActionsBloc extends BaseBloc<ActionsEvent, ActionsState> {
  ActionsBloc({
    required this.getAdminActionsUseCase,
    required this.respondToActionUseCase,
  }) : super(ActionsInitial()) {
    on<ActionsEvent>((event, emit) async {
      if (event is GetActionsEvent) {
        _studentId = event.studentId;
        emit(ActionsLoading());
        result = await getAdminActionsUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(ActionsFailureState(failure: failure)),
          (value) {
            _actions = value as List<AdminAction>;
            emit(ActionsLoadedState(actions: _actions, tab: _tab));
          },
        );
      } else if (event is ChangeActionsTabEvent) {
        _tab = event.tab;
        emit(ActionsLoadedState(actions: _actions, tab: _tab));
      } else if (event is RespondToActionEvent) {
        result = await respondToActionUseCase(ActionResponseEntity(
          actionId: event.actionId,
          confirmAttendance: event.confirmAttendance,
        ));
        await result.fold(
          (failure) async => emit(ActionsFailureState(failure: failure)),
          (_) async {
            emit(ActionRespondedState(confirmedAttendance: event.confirmAttendance));
            // القائمة تُقرأ من جديد لا تُعدَّل محلياً، لأن ردّ ولي الأمر قد
            // يغيّر أكثر من حالة الإجراء الواحد.
            result = await getAdminActionsUseCase(StudentEntity(studentId: _studentId));
            result.fold(
              (failure) => emit(ActionsFailureState(failure: failure)),
              (value) {
                _actions = value as List<AdminAction>;
                emit(ActionsLoadedState(actions: _actions, tab: _tab));
              },
            );
          },
        );
      }
    });
  }

  final GetAdminActionsUseCase getAdminActionsUseCase;
  final RespondToActionUseCase respondToActionUseCase;

  List<AdminAction> _actions = [];
  ActionsTab _tab = ActionsTab.all;
  String _studentId = '';
}
