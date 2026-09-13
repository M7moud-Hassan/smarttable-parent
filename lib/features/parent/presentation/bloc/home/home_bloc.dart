import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/home_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/usecases/get_home_use_case.dart';

part 'home_event.dart';
part 'home_state.dart';

/// محتوى الرئيسية للطالب المختار (شاشة B1، وB4 في التابلت).
///
/// تبديل الطالب من شريط الأبناء يعيد تحميل هذه الشاشة وحدها — بقية الشاشات
/// تُحمَّل عند فتحها.
class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  HomeBloc({required this.getHomeUseCase}) : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      if (event is GetHomeEvent) {
        emit(HomeLoading());
        result = await getHomeUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(HomeFailureState(failure: failure)),
          (value) => emit(HomeLoadedState(summary: value as HomeSummary)),
        );
      }
    });
  }

  final GetHomeUseCase getHomeUseCase;
}
