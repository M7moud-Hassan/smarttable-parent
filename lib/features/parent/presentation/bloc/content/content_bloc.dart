import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/school_model.dart';
import '../../../domain/entities/base_entity.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_faq_use_case.dart';
import '../../../domain/usecases/get_school_use_case.dart';
import '../../../domain/usecases/get_static_page_use_case.dart';
import '../../../domain/usecases/get_support_use_case.dart';

part 'content_event.dart';
part 'content_state.dart';

/// المحتوى الثابت في مسار هـ: تواصل مع المدرسة، الدعم الفني، الأسئلة الشائعة،
/// ومن نحن والسياسة والشروط.
///
/// شاشة واحدة تخدم الصفحات النصّية الثلاث — «قالب واحد بثلاثة محتويات» كما
/// ينصّ التصميم — فيجمعها بلوك واحد.
class ContentBloc extends BaseBloc<ContentEvent, ContentState> {
  ContentBloc({
    required this.getSchoolUseCase,
    required this.getSupportUseCase,
    required this.getFaqUseCase,
    required this.getStaticPageUseCase,
  }) : super(ContentInitial()) {
    on<ContentEvent>((event, emit) async {
      emit(ContentLoading());
      if (event is GetSchoolEvent) {
        result = await getSchoolUseCase(StudentEntity(studentId: event.studentId));
        _settle(emit, (value) => SchoolLoadedState(info: value as SchoolInfo));
      } else if (event is GetSupportEvent) {
        result = await getSupportUseCase();
        _settle(emit, (value) => SchoolLoadedState(info: value as SchoolInfo));
      } else if (event is GetFaqEvent) {
        result = await getFaqUseCase();
        _settle(emit, (value) => FaqLoadedState(items: value as List<FaqItem>));
      } else if (event is GetStaticPageEvent) {
        result = await getStaticPageUseCase(StaticPageEntity(kind: event.kind));
        _settle(emit, (value) => StaticPageLoadedState(page: value as StaticPage));
      }
    });
  }

  final GetSchoolUseCase getSchoolUseCase;
  final GetSupportUseCase getSupportUseCase;
  final GetFaqUseCase getFaqUseCase;
  final GetStaticPageUseCase getStaticPageUseCase;

  void _settle(
    Emitter<ContentState> emit,
    ContentState Function(dynamic) onDone,
  ) {
    result.fold(
      (failure) => emit(ContentFailureState(failure: failure)),
      (value) => emit(onDone(value)),
    );
  }
}
