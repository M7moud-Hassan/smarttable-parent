part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {}

final class SettingsFailureState extends SettingsState {
  const SettingsFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class SettingsLoadedState extends SettingsState {
  const SettingsLoadedState({required this.settings});

  final List<NotificationSetting> settings;

  @override
  List<Object?> get props => [settings];
}

final class LanguageChangedState extends SettingsState {
  const LanguageChangedState({required this.languageCode});

  final String languageCode;

  @override
  List<Object?> get props => [languageCode];
}
