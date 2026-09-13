import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/circular_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/usecases/get_circulars_use_case.dart';
import '../../../domain/usecases/get_circular_details_use_case.dart';

part 'circulars_event.dart';
part 'circulars_state.dart';

/// التعاميم الإدارية وتفاصيل التعميم الواحد (شاشتا د٣ ود٤).
class CircularsBloc extends BaseBloc<CircularsEvent, CircularsState> {
  CircularsBloc({
    required this.getCircularsUseCase,
    required this.getCircularDetailsUseCase,
  }) : super(CircularsInitial()) {
    on<CircularsEvent>((event, emit) async {
      if (event is GetCircularsEvent) {
        emit(CircularsLoading());
        result = await getCircularsUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(CircularsFailureState(failure: failure)),
          (value) => emit(CircularsLoadedState(circulars: value as List<Circular>)),
        );
      } else if (event is GetCircularDetailsEvent) {
        emit(CircularsLoading());
        result = await getCircularDetailsUseCase(IdEntity(id: event.circularId));
        result.fold(
          (failure) => emit(CircularsFailureState(failure: failure)),
          (value) => emit(CircularDetailsLoadedState(circular: value as Circular)),
        );
      }
    });
  }

  final GetCircularsUseCase getCircularsUseCase;
  final GetCircularDetailsUseCase getCircularDetailsUseCase;
}
