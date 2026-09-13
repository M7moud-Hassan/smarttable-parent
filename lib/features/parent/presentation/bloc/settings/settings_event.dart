part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class GetSettingsEvent extends SettingsEvent {}

/// قلب مفتاح واحد. الحفظ فوري لأن الشاشة لا تحمل زر «حفظ».
final class ToggleSettingEvent extends SettingsEvent {
  const ToggleSettingEvent({required this.key});

  final String key;

  @override
  List<Object?> get props => [key];
}

final class ChangeLanguageEvent extends SettingsEvent {
  const ChangeLanguageEvent({required this.languageCode, required this.countryCode});

  final String languageCode;
  final String countryCode;

  @override
  List<Object?> get props => [languageCode, countryCode];
}
