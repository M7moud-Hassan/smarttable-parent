import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/inputs/app_text_field.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../domain/entities/auth_entities.dart';
import '../bloc/auth/auth_bloc.dart';
import 'login_page.dart';

/// A9 تحديث كلمة المرور — بعد التحديث يعود إلى شاشة الدخول.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.token = ''});

  /// الرمز الوارد في رابط الرسالة النصية.
  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool get _canSubmit => _password.text.length >= 8 && _password.text == _confirm.text;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetState) {
            AppUtils.showCustomSnackbar(AppText.passwordUpdated, SnackType.SUCESS);
            AppUtils.goAndReplace(const LoginPage());
          } else if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.updatePasswordTitle,
            onBack: AppUtils.back,
            showAvatarInHeader: false,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppText.updatePasswordSubtitle,
                    style: AppTextStyles.bodyMuted.copyWith(height: 1.8)),
                SizedBox(height: 24.h),
                FieldLabel(AppText.newPassword),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: _password,
                  hint: AppText.newPasswordHint,
                  icon: AppIcons.lock,
                  obscure: true,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 18.h),
                FieldLabel(AppText.confirmPassword),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: _confirm,
                  hint: AppText.confirmPasswordHint,
                  icon: AppIcons.lock,
                  obscure: true,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 14.h),
                FieldHint(AppText.passwordAdvice),
                SizedBox(height: 26.h),
                PrimaryButton(
                  label: AppText.updatePassword,
                  enabled: _canSubmit && state is! AuthLoading,
                  onTap: () => context.read<AuthBloc>().add(
                        ResetPasswordEvent(
                          entity: ResetPasswordEntity(
                            token: widget.token,
                            password: _password.text,
                          ),
                        ),
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
