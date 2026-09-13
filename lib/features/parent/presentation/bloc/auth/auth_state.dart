part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

/// فشل نداء المصادقة. رسالته تُعرض بجانب النموذج لا في إشعار عابر، لأن
/// المستخدم يقف على شاشة إدخال ويحتاج أن يعرف ما يصحّحه.
final class AuthFailureState extends AuthState {
  const AuthFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure, DateTime.now().microsecondsSinceEpoch];
}

/// دخل المستخدم أو أنشأ حسابه — التالي شاشة اختيار الطالب.
final class AuthenticatedState extends AuthState {
  const AuthenticatedState({required this.user});

  final ParentUser user;

  @override
  List<Object?> get props => [user];
}

final class OtpRequestedState extends AuthState {
  const OtpRequestedState({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class OtpVerifiedState extends AuthState {
  const OtpVerifiedState({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

/// حالة «تم إرسال الرابط» داخل شاشة A8 نفسها.
final class ResetLinkSentState extends AuthState {
  const ResetLinkSentState({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class PasswordResetState extends AuthState {}

final class PasswordChangedState extends AuthState {}

final class AccountDeletedState extends AuthState {}

final class LoggedOutState extends AuthState {}
