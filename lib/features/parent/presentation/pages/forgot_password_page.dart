import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
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
import 'otp_page.dart';

/// A8 استعادة كلمة المرور.
///
/// الشاشة حالتان في ملف واحد كما في التصميم: إدخال الرقم، ثم «تم إرسال
/// الرابط» — لا شاشة ثانية.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          final sent = state is ResetLinkSentState;
          return ParentScaffold(
            title: AppText.forgotTitle,
            onBack: AppUtils.back,
            showAvatarInHeader: false,
            body: sent ? _sentState(context, state.phone) : _formState(context, state),
          );
        },
      ),
    );
  }

  Widget _formState(BuildContext context, AuthState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppText.forgotSubtitle,
              style: AppTextStyles.bodyMuted.copyWith(height: 1.8)),
          SizedBox(height: 26.h),
          FieldLabel(AppText.phoneNumber),
          SizedBox(height: 10.h),
          AppTextField(
            controller: _phone,
            hint: AppText.phoneHint,
            icon: AppIcons.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 26.h),
          PrimaryButton(
            label: AppText.sendResetLink,
            enabled: _phone.text.trim().length == 10 && state is! AuthLoading,
            onTap: () => context.read<AuthBloc>().add(
                  ForgotPasswordEvent(entity: PhoneEntity(phone: _phone.text.trim())),
                ),
          ),
        ],
      );

  Widget _sentState(BuildContext context, String phone) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),
          Center(
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                color: AppColors.successSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(AppIcons.checkCircle, size: 30.sp, color: AppColors.success),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            AppText.linkSent,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextStyles.s16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 14.h),
          Text.rich(
            TextSpan(
              text: AppText.linkSentTo,
              style: AppTextStyles.bodyMuted.copyWith(height: 1.9),
              children: [TextSpan(text: phone, style: AppTextStyles.body)],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 22.h),
          InfoBanner(
            message: AppText.linkValidity,
            background: AppColors.warningDeep,
            foreground: AppColors.warning,
            lineHeight: 1.8,
          ),
          SizedBox(height: 24.h),
          PrimaryButton(
            label: AppText.openLink,
            fontSize: AppTextStyles.s16,
            onTap: () => AppUtils.go(OtpPage(phone: phone, forReset: true)),
          ),
          SizedBox(height: 12.h),
          OutlinedPillButton(
            label: AppText.resendLink,
            borderColor: AppColors.textFaint,
            textColor: AppColors.text,
            fontSize: AppTextStyles.s12,
            onTap: () => context.read<AuthBloc>().add(
                  ForgotPasswordEvent(entity: PhoneEntity(phone: phone)),
                ),
          ),
        ],
      );
}
