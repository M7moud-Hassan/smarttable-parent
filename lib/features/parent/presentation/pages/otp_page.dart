import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/inputs/otp_field.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/phone_format.dart';
import '../../../../injections/injection_main.dart';
import '../../domain/entities/auth_entities.dart';
import '../bloc/auth/auth_bloc.dart';
import 'create_account_page.dart';
import 'reset_password_page.dart';

/// ما الذي يثبّته الرمز.
///
/// نوعٌ معدود لا رايةٌ بوليّة: المسارات صارت ثلاثة، و`forReset` الثانية
/// كانت تعني أربع حالاتٍ اثنتان منها لا معنى لها.
enum OtpPurpose {
  /// التسجيل لأول مرة — ينتهي إلى إنشاء الحساب.
  register,

  /// استعادة كلمة المرور — ينتهي إلى تحديثها.
  resetPassword,

  /// تغيير رقم الجوال من البيانات الشخصية — ينتهي إلى تثبيت الرقم الجديد.
  changePhone,
}

/// A5 رمز التحقق — أربع خانات، ثم إنشاء الحساب أو تحديث كلمة المرور.
///
/// الشاشة واحدة في المسارين: التصميم يرسمها مرة، والرمز يثبت ملكية الرقم في
/// الحالتين. ولا يصحّ تخطّيها في مسار الاستعادة — لولا الرمز لكفى معرفة رقم
/// جوال وليّ الأمر لتغيير كلمة مروره.
class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.phone,
    this.purpose = OtpPurpose.register,
    this.studentsCount = 0,
  });

  final String phone;

  /// ما ينتظر خلف الرمز.
  final OtpPurpose purpose;

  /// عدد الأبناء الذين وجدهم الخادم للرقم — يُمرَّر إلى شاشة إنشاء الحساب.
  final int studentsCount;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _code = '';

  /// أوّلُ إرسالٍ في مسار تغيير الرقم تلقائيّ، فلا تصحّ عليه رسالة «أُعيد
  /// إرسال الرمز» — وهي تصحّ على كل ما بعده.
  bool _awaitingFirstCode = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final auth = bloc<AuthBloc>();
        // المساران الآخران وصلا وقد أُرسل رمزهما من الشاشة السابقة؛ وتغييرُ
        // الرقم يبدأ هنا، فلولا هذا السطر انتظر وليّ الأمر رمزًا لا يأتي.
        if (widget.purpose == OtpPurpose.changePhone) {
          _awaitingFirstCode = true;
          auth.add(RequestPhoneChangeEvent(
              entity: PhoneEntity(phone: widget.phone)));
        }
        return auth;
      },
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerifiedState) {
            AppUtils.go(widget.purpose == OtpPurpose.resetPassword
                ? ResetPasswordPage(token: _code)
                : CreateAccountPage(
                    phone: state.phone,
                    studentsCount: widget.studentsCount,
                  ));
          } else if (state is PhoneChangedState) {
            AppUtils.showCustomSnackbar(AppText.phoneUpdated, SnackType.SUCESS);
            // `true` تُعلم شاشة البيانات الشخصية أن الرقم ثبت، فتتابع حفظ
            // بقية الحقول بدل أن تطلب رمزًا ثانيًا على الرقم نفسه.
            AppUtils.back<bool>(true);
          } else if (state is OtpRequestedState) {
            AppUtils.showCustomSnackbar(AppText.otpResent, SnackType.SUCESS);
          } else if (state is PhoneChangeCodeSentState) {
            if (_awaitingFirstCode) {
              _awaitingFirstCode = false;
            } else {
              AppUtils.showCustomSnackbar(AppText.otpResent, SnackType.SUCESS);
            }
          } else if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.otpTitle,
            onBack: AppUtils.back,
            showAvatarInHeader: false,
            bodyPadding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 32.h),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    text: AppText.otpSentTo,
                    style: AppTextStyles.bodyMuted,
                    children: [
                      TextSpan(
                        text: PhoneFormat.masked(widget.phone),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                OtpField(onChanged: (value) => setState(() => _code = value)),
                SizedBox(height: 32.h),
                PrimaryButton(
                  label: AppText.verify,
                  enabled: _code.length == 4 && state is! AuthLoading,
                  onTap: () => context.read<AuthBloc>().add(
                        widget.purpose == OtpPurpose.changePhone
                            ? ChangePhoneEvent(
                                entity: OtpEntity(
                                    phone: widget.phone, code: _code),
                              )
                            : VerifyOtpEvent(
                                entity: OtpEntity(
                                    phone: widget.phone, code: _code),
                              ),
                      ),
                ),
                SizedBox(height: 18.h),
                _resend(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _resend(BuildContext context) => Text.rich(
        TextSpan(
          text: AppText.otpNotReceived,
          style: TextStyle(fontSize: AppTextStyles.s12, color: AppColors.textFaint),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => context.read<AuthBloc>().add(
                      widget.purpose == OtpPurpose.changePhone
                          ? RequestPhoneChangeEvent(
                              entity: PhoneEntity(phone: widget.phone))
                          : RequestOtpEvent(
                              entity: PhoneEntity(phone: widget.phone)),
                    ),
                child: Text(
                  AppText.resend,
                  style: TextStyle(
                    fontSize: AppTextStyles.s12,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
}
