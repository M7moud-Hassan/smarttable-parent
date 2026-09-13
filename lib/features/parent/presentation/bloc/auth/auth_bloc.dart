import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/base_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/app_utils.dart';
import '../../../data/models/parent_model.dart';
import '../../../domain/entities/auth_entities.dart';
import '../../../domain/usecases/change_password_use_case.dart';
import '../../../domain/usecases/create_account_use_case.dart';
import '../../../domain/usecases/delete_account_use_case.dart';
import '../../../domain/usecases/forgot_password_use_case.dart';
import '../../../domain/usecases/login_use_case.dart';
import '../../../domain/usecases/request_otp_use_case.dart';
import '../../../domain/usecases/reset_password_use_case.dart';
import '../../../domain/usecases/verify_otp_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// مسار A كاملاً: الدخول، التسجيل لأول مرة، رمز التحقق، إنشاء الحساب،
/// استعادة كلمة المرور وتحديثها، وتغييرها وحذف الحساب من داخل الحساب.
class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.loginUseCase,
    required this.requestOtpUseCase,
    required this.verifyOtpUseCase,
    required this.createAccountUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
  }) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is LoginEvent) {
        emit(AuthLoading());
        result = await loginUseCase(event.entity);
        await _onUser(emit, event.entity);
      } else if (event is RequestOtpEvent) {
        emit(AuthLoading());
        result = await requestOtpUseCase(event.entity);
        _settle(emit, (value) => OtpRequestedState(phone: value as String));
      } else if (event is VerifyOtpEvent) {
        emit(AuthLoading());
        result = await verifyOtpUseCase(event.entity);
        _settle(emit, (_) => OtpVerifiedState(phone: event.entity.phone));
      } else if (event is CreateAccountEvent) {
        emit(AuthLoading());
        result = await createAccountUseCase(event.entity);
        await _onUser(
          emit,
          LoginEntity(username: event.entity.username, password: event.entity.password),
        );
      } else if (event is ForgotPasswordEvent) {
        emit(AuthLoading());
        result = await forgotPasswordUseCase(event.entity);
        _settle(emit, (value) => ResetLinkSentState(phone: value as String));
      } else if (event is ResetPasswordEvent) {
        emit(AuthLoading());
        result = await resetPasswordUseCase(event.entity);
        _settle(emit, (_) => PasswordResetState());
      } else if (event is ChangePasswordEvent) {
        emit(AuthLoading());
        result = await changePasswordUseCase(event.entity);
        _settle(emit, (_) => PasswordChangedState());
      } else if (event is DeleteAccountEvent) {
        emit(AuthLoading());
        result = await deleteAccountUseCase();
        _settle(emit, (_) => AccountDeletedState());
      } else if (event is LogoutEvent) {
        await AppUtils.instance.logout();
        emit(LoggedOutState());
      }
    });
  }

  final LoginUseCase loginUseCase;
  final RequestOtpUseCase requestOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final CreateAccountUseCase createAccountUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  /// الدخول وإنشاء الحساب ينتهيان إلى الشيء نفسه: حفظ المستخدم وبيانات
  /// الاعتماد ثم الانتقال إلى اختيار الطالب.
  Future<void> _onUser(Emitter<AuthState> emit, LoginEntity credentials) async {
    await result.fold(
      (failure) async => emit(AuthFailureState(failure: failure)),
      (value) async {
        final user = value as ParentUser;
        await AppUtils.instance.setUser(user);
        await AppUtils.instance.login(credentials);
        emit(AuthenticatedState(user: user));
      },
    );
  }

  void _settle(Emitter<AuthState> emit, AuthState Function(dynamic) onDone) {
    result.fold(
      (failure) => emit(AuthFailureState(failure: failure)),
      (value) => emit(onDone(value)),
    );
  }
}
