import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/inputs/app_text_field.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_app_inactive_dialog.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../domain/entities/auth_entities.dart';
import '../bloc/auth/auth_bloc.dart';
import 'select_student_page.dart';

/// A6 إنشاء الحساب — اسم مستخدم بحروف صغيرة وأرقام، بريد، وكلمة مرور وتأكيدها.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({
    super.key,
    required this.phone,
    this.studentsCount = 0,
  });

  final String phone;

  /// عدد الأبناء الذين وجدهم الخادم لهذا الرقم — يُعرض في لوح الترحيب.
  final int studentsCount;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  /// القاعدة نصّها في التصميم: حروف إنجليزية صغيرة وأرقام فقط، فتُمنع الحروف
  /// الكبيرة والرموز عند الكتابة لا بعد الإرسال.
  static final _usernameFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]'));

  bool get _passwordsMatch =>
      _password.text.isNotEmpty && _password.text == _confirm.text;

  bool get _canSubmit =>
      _username.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _password.text.length >= 8 &&
      _passwordsMatch;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
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
          if (state is AuthenticatedState) {
            if (!state.user.parentAppActive) {
              ParentAppInactiveDialog.show(context);
            } else {
              AppUtils.goAndReplace(const SelectStudentPage());
            }
          } else if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(
                state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.createAccount,
            onBack: AppUtils.back,
            showAvatarInHeader: false,
            bodyPadding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 32.h),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoBanner(
                  message: widget.studentsCount > 0
                      ? 'تعرّفنا على رقمك. أنت مسجّل كولي أمر لـ '
                          '${widget.studentsCount} طلاب — أكمل بيانات حسابك للمتابعة.'
                      : 'تعرّفنا على رقمك — أكمل بيانات حسابك للمتابعة.',
                  icon: AppIcons.info,
                ),
                SizedBox(height: 26.h),
                FieldLabel(AppText.usernameHint),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: _username,
                  hint: 'abu.abdulrahman',
                  icon: AppIcons.user,
                  inputFormatters: [_usernameFormatter],
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 10.h),
                FieldHint(AppText.usernameRule),
                SizedBox(height: 18.h),
                FieldLabel(AppText.email),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: _email,
                  hint: AppText.emailHint,
                  icon: AppIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 18.h),
                FieldLabel(AppText.password),
                SizedBox(height: 10.h),
                AppTextField(
                  controller: _password,
                  hint: AppText.passwordMinHint,
                  icon: AppIcons.lock,
                  obscure: true,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 10.h),
                FieldHint(AppText.passwordRule),
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
                SizedBox(height: 10.h),
                // التصميم يجعل هذا السطر مرآةً لحالة التطابق: يحمرّ حين
                // تختلف الكلمتان ويخضرّ حين تتطابقان.
                FieldHint(
                  _confirm.text.isEmpty
                      ? AppText.confirmPasswordRule
                      : (_passwordsMatch
                          ? 'الكلمتان متطابقتان.'
                          : 'الكلمتان غير متطابقتين.'),
                  color: _confirm.text.isEmpty
                      ? AppColors.textFaint
                      : (_passwordsMatch
                          ? AppColors.success
                          : AppColors.danger),
                ),
                SizedBox(height: 30.h),
                PrimaryButton(
                  label: AppText.createAccount,
                  enabled: _canSubmit && state is! AuthLoading,
                  onTap: () => context.read<AuthBloc>().add(
                        CreateAccountEvent(
                          entity: CreateAccountEntity(
                            phone: widget.phone,
                            username: _username.text.trim(),
                            email: _email.text.trim(),
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
