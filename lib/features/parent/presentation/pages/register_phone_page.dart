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
import 'static_content_page.dart';

/// A4 التسجيل لأول مرة — رقم الجوال المسجَّل لدى المدرسة، مرة واحدة فقط.
class RegisterPhonePage extends StatefulWidget {
  const RegisterPhonePage({super.key});

  @override
  State<RegisterPhonePage> createState() => _RegisterPhonePageState();
}

class _RegisterPhonePageState extends State<RegisterPhonePage> {
  final _phone = TextEditingController();

  bool get _canSubmit => _phone.text.trim().length == 10;

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
          if (state is OtpRequestedState) {
            AppUtils.go(OtpPage(phone: state.phone));
          } else if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.firstTimeRegister,
            onBack: AppUtils.back,
            showAvatarInHeader: false,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoBanner(
                  message: AppText.registerHint,
                  icon: AppIcons.info,
                  lineHeight: 1.8,
                ),
                SizedBox(height: 26.h),
                FieldLabel(AppText.enterLinkedPhone),
                SizedBox(height: 16.h),
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
                  label: AppText.sendOtp,
                  enabled: _canSubmit && state is! AuthLoading,
                  onTap: () => context.read<AuthBloc>().add(
                      RequestOtpEvent(entity: PhoneEntity(phone: _phone.text.trim()))),
                ),
                SizedBox(height: 20.h),
                _terms(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _terms() => Text.rich(
        TextSpan(
          text: AppText.termsPrefix,
          style: TextStyle(
            fontSize: AppTextStyles.s12,
            color: AppColors.textFaint,
            height: 1.8,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => AppUtils.go(const StaticContentPage.terms()),
                child: Text(
                  AppText.termsLink,
                  style: TextStyle(
                    fontSize: AppTextStyles.s12,
                    color: AppColors.primaryDark,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
}
