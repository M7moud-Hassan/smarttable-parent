import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/inputs/app_text_field.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_app_inactive_dialog.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../domain/entities/login_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import 'forgot_password_page.dart';
import 'register_phone_page.dart';
import 'select_student_page.dart';

/// A3 تسجيل الدخول.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  /// الزر الرئيسي يبقى بلون `primary-light` حتى يكتمل الحقلان — وهي حالته
  /// المرسومة في التصميم.
  bool get _canSubmit => _username.text.trim().isNotEmpty && _password.text.isNotEmpty;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            if (!state.user.parentAppActive) {
              ParentAppInactiveDialog.show(context);
            } else {
              AppUtils.goAndReplace(const SelectStudentPage());
            }
          } else if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    Dimensions.screenPadding, 22.h, Dimensions.screenPadding, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 8.h, bottom: 26.h),
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        alignment: Alignment.center,
                        child: Icon(AppIcons.school,
                            size: 50.sp, color: AppColors.primaryDark),
                      ),
                    ),
                    Text(AppText.loginTitle, style: AppTextStyles.screenTitle),
                    SizedBox(height: 10.h),
                    Text(AppText.loginSubtitle, style: AppTextStyles.bodyMuted),
                    SizedBox(height: 26.h),
                    FieldLabel(AppText.usernameOrEmail),
                    SizedBox(height: 10.h),
                    AppTextField(
                      controller: _username,
                      hint: AppText.usernameHint,
                      icon: AppIcons.user,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 18.h),
                    FieldLabel(AppText.password),
                    SizedBox(height: 10.h),
                    AppTextField(
                      controller: _password,
                      hint: AppText.passwordHint,
                      icon: AppIcons.lock,
                      obscure: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 14.h),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextLinkButton(
                        label: AppText.forgotPassword,
                        onTap: () => AppUtils.go(const ForgotPasswordPage()),
                      ),
                    ),
                    SizedBox(height: 26.h),
                    PrimaryButton(
                      label: AppText.login,
                      enabled: _canSubmit && !loading,
                      onTap: () => context.read<AuthBloc>().add(
                            LoginEvent(
                              entity: LoginEntity(
                                username: _username.text.trim(),
                                password: _password.text,
                              ),
                            ),
                          ),
                    ),
                    SizedBox(height: 26.h),
                    _divider(),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppText.firstTimeHint,
                            style: AppTextStyles.label.copyWith(height: 1.8),
                          ),
                          SizedBox(height: 12.h),
                          OutlinedPillButton(
                            label: AppText.firstTimeRegister,
                            background: AppColors.surface,
                            onTap: () => AppUtils.go(const RegisterPhonePage()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _divider() => Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider, height: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              AppText.or,
              style: TextStyle(fontSize: AppTextStyles.s10, color: AppColors.textFaint),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.divider, height: 1)),
        ],
      );
}
