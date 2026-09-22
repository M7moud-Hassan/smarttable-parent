import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
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
import 'main_shell.dart';

/// هـ2 تغيير كلمة المرور — تحقق فوري من التطابق.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  bool get _match => _next.text.isNotEmpty && _next.text == _confirm.text;

  bool get _canSubmit => _current.text.isNotEmpty && _next.text.length >= 8 && _match;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordChangedState) {
            AppUtils.showCustomSnackbar(AppText.passwordUpdated, SnackType.SUCESS);
            AppUtils.back();
          } else if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.passwordTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldLabel(AppText.currentPassword),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: _current,
                  hint: AppText.currentPasswordHint,
                  icon: AppIcons.lock,
                  obscure: true,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 18.h),
                FieldLabel(AppText.newPassword),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: _next,
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
                // التحقق فوري كما ينصّ التصميم: السطر يخبر بالتطابق قبل
                // الضغط على الزر لا بعده.
                FieldHint(
                  _confirm.text.isEmpty
                      ? AppText.passwordAdviceLong
                      : (_match ? 'الكلمتان متطابقتان.' : 'الكلمتان غير متطابقتين.'),
                  color: _confirm.text.isEmpty
                      ? AppColors.textFaint
                      : (_match ? AppColors.success : AppColors.danger),
                ),
                SizedBox(height: 26.h),
                PrimaryButton(
                  label: AppText.updatePassword,
                  enabled: _canSubmit && state is! AuthLoading,
                  onTap: () => context.read<AuthBloc>().add(
                        ChangePasswordEvent(
                          entity: ChangePasswordEntity(
                            currentPassword: _current.text,
                            newPassword: _next.text,
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
