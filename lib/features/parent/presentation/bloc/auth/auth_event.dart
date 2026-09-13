part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class LoginEvent extends AuthEvent {
  const LoginEvent({required this.entity});

  final LoginEntity entity;

  @override
  List<Object?> get props => [entity];
}

final class RequestOtpEvent extends AuthEvent {
  const RequestOtpEvent({required this.entity});

  final PhoneEntity entity;

  @override
  List<Object?> get props => [entity];
}

final class VerifyOtpEvent extends AuthEvent {
  const VerifyOtpEvent({required this.entity});

  final OtpEntity entity;

  @override
  List<Object?> get props => [entity];
}

final class CreateAccountEvent extends AuthEvent {
  const CreateAccountEvent({required this.entity});

  final CreateAccountEntity entity;

  @override
  List<Object?> get props => [entity];
}

final class ForgotPasswordEvent extends AuthEvent {
  const ForgotPasswordEvent({required this.entity});

  final PhoneEntity entity;

  @override
  List<Object?> get props => [entity];
}

final class ResetPasswordEvent extends AuthEvent {
  const ResetPasswordEvent({required this.entity});

  final ResetPasswordEntity entity;

  @override
  List<Object?> get props => [entity];
}

final class ChangePasswordEvent extends AuthEvent {
  const ChangePasswordEvent({required this.entity});

  final ChangePasswordEntity entity;

  @override
  List<Object?> get props => [entity];
}

final class DeleteAccountEvent extends AuthEvent {}

final class LogoutEvent extends AuthEvent {}
