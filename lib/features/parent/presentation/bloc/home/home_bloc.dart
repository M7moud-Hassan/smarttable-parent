import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
        // البطاقات المعروضة لا تُمسح في إعادة قراءةٍ لنفس الطالب — سحبٌ
        // للتحديث، أو عودةٌ من شاشة خدمة، أو إيقاظُ التطبيق. دائرةُ تحميلٍ
        // مكان الشبكة في كل مرة تُرجف الشاشة، والعدّاد القديم أصدق من فراغ.
        // أما تبديل الابن فشاشةٌ أخرى: إبقاءُ عدّادات أخيه معروضةً تحت اسمه
        // كذبٌ صريح، فتُمسح.
        if (state is! HomeLoadedState || _loadedStudentId != event.studentId) {
          emit(HomeLoading());
        }
        result = await getHomeUseCase(StudentEntity(studentId: event.studentId));
        result.fold(
          (failure) => emit(HomeFailureState(failure: failure)),
          (value) {
            _loadedStudentId = event.studentId;
            emit(HomeLoadedState(summary: value as HomeSummary));
          },
        );
        event.onDone?.call();
      }
    });
  }

  final GetHomeUseCase getHomeUseCase;

  /// آخر ابنٍ اكتملت قراءة رئيسيته — به يُفرَّق التحديثُ عن تبديل الابن.
  String? _loadedStudentId;
}
