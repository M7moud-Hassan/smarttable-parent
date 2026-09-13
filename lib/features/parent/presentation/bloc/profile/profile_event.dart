part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class GetProfileEvent extends ProfileEvent {}

final class PickAvatarEvent extends ProfileEvent {
  const PickAvatarEvent({required this.path});

  final String path;

  @override
  List<Object?> get props => [path];
}

final class SaveProfileEvent extends ProfileEvent {
  const SaveProfileEvent({required this.entity});

  final ProfileEntity entity;

  @override
  List<Object?> get props => [entity];
}
