import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/notification_model.dart';
import '../../../domain/usecases/get_notifications_use_case.dart';
import '../../../domain/usecases/mark_all_read_use_case.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// قائمة الإشعارات (شاشة B2).
///
/// الإشعارات لكل الأبناء لا للطالب المختار وحده، لأن كل إشعار يحمل الطالب
/// المعنيّ وفتحُه يبدّل الاختيار إليه.
class NotificationsBloc extends BaseBloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markAllReadUseCase,
  }) : super(NotificationsInitial()) {
    on<NotificationsEvent>((event, emit) async {
      if (event is GetNotificationsEvent) {
        // لا يُخفي القائمة الظاهرة أثناء إعادة الجلب (سحب للتحديث أو فتح
        // التبويب من جديد)، بل تبقى حتى تصل نتيجة الجلب.
        if (state is! NotificationsLoadedState) emit(NotificationsLoading());
        result = await getNotificationsUseCase();
        result.fold(
          (failure) => emit(NotificationsFailureState(failure: failure)),
          (value) => emit(
              NotificationsLoadedState(notifications: value as List<ParentNotification>)),
        );
        event.onDone?.call();
      } else if (event is MarkAllReadEvent) {
        result = await markAllReadUseCase();
        result.fold(
          (failure) => emit(NotificationsFailureState(failure: failure)),
          (_) {
            final current = state;
            if (current is NotificationsLoadedState) {
              emit(NotificationsLoadedState(
                notifications:
                    current.notifications.map((n) => n.copyWith(read: true)).toList(),
              ));
            }
          },
        );
      }
    });
  }

  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAllReadUseCase markAllReadUseCase;
}
