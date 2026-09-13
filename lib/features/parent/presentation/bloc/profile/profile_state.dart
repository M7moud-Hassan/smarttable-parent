part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileFailureState extends ProfileState {
  const ProfileFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure, DateTime.now().microsecondsSinceEpoch];
}

final class ProfileLoadedState extends ProfileState {
  const ProfileLoadedState({required this.user, this.avatarPath});

  final ParentUser user;

  /// صورة اختارها المستخدم ولم تُحفظ بعد.
  final String? avatarPath;

  @override
  List<Object?> get props => [user, avatarPath];
}

final class ProfileSavedState extends ProfileState {
  const ProfileSavedState({required this.user});

  final ParentUser user;

  @override
  List<Object?> get props => [user, DateTime.now().microsecondsSinceEpoch];
}
