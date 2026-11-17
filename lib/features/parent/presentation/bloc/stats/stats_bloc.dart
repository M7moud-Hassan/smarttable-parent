import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/stats_model.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_stats_use_case.dart';

part 'stats_event.dart';
part 'stats_state.dart';

/// إحصاءات الابن — شاشةٌ واحدة بمدى قابل للتبديل.
///
/// تبديل المدى يعيد النداء ولا يُصفّي ما في اليد: الأرقام كلّها محسوبةٌ على
/// الخادم بدوالّ المدرسة نفسها، فلو حُسبت هنا لاختلف ما يراه وليّ الأمر عمّا
/// يراه وكيل المدرسة في شاشته.
class StatsBloc extends BaseBloc<StatsEvent, StatsState> {
  StatsBloc({required this.getStatsUseCase}) : super(StatsInitial()) {
    on<StatsEvent>((event, emit) async {
      if (event is GetStatsEvent) {
        _filter = event.filter;
        emit(StatsLoading());
        result = await getStatsUseCase(event.filter);
        result.fold(
          (failure) => emit(StatsFailureState(failure: failure)),
          (value) => emit(StatsLoadedState(
            stats: value as StudentStats,
            filter: event.filter,
          )),
        );
      }
    });
  }

  final GetStatsUseCase getStatsUseCase;

  StatsFilterEntity? _filter;

  /// المدى الجاري — تقرأه الشاشة لتبني عليه الحدث التالي.
  StatsFilterEntity? get filter => _filter;
}
