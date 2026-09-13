import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/app_utils.dart';
import '../../../data/models/home_model.dart';
import '../../../domain/entities/service_entities.dart';
import '../../../domain/usecases/get_notification_settings_use_case.dart';
import '../../../domain/usecases/save_notification_settings_use_case.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// إعدادات التنبيهات (شاشة هـ٣) واللغة (شاشة هـ٤).
///
/// الشاشتان بلا زر حفظ، فكل تبديل يُحفظ فور وقوعه.
class SettingsBloc extends BaseBloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required this.getNotificationSettingsUseCase,
    required this.saveNotificationSettingsUseCase,
  }) : super(SettingsInitial()) {
    on<SettingsEvent>((event, emit) async {
      if (event is GetSettingsEvent) {
        emit(SettingsLoading());
        result = await getNotificationSettingsUseCase();
        result.fold(
          (failure) => emit(SettingsFailureState(failure: failure)),
          (value) {
            _settings = value as List<NotificationSetting>;
            emit(SettingsLoadedState(settings: _settings));
          },
        );
      } else if (event is ToggleSettingEvent) {
        _settings = _settings
            .map((s) => s.key == event.key ? s.copyWith(enabled: !s.enabled) : s)
            .toList();
        emit(SettingsLoadedState(settings: _settings));
        result = await saveNotificationSettingsUseCase(NotificationSettingsEntity(
          settings: {for (final s in _settings) s.key: s.enabled},
        ));
      } else if (event is ChangeLanguageEvent) {
        AppUtils.instance.setLocale(event.languageCode, event.countryCode);
        emit(LanguageChangedState(languageCode: event.languageCode));
      }
    });
  }

  final GetNotificationSettingsUseCase getNotificationSettingsUseCase;
  final SaveNotificationSettingsUseCase saveNotificationSettingsUseCase;

  List<NotificationSetting> _settings = [];
}
