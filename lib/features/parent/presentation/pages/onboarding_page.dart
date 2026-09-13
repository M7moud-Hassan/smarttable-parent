import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/conts/ui_content.dart';
import 'login_page.dart';

/// A2 الشاشات التعريفية — ثلاث شرائح، «التالي» يبدّل بينها، و«تخطي» و«ابدأ
/// الآن» ينقلان إلى شاشة الدخول.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const List<IconData> _icons = [
    AppIcons.onboardingOverview,
    AppIcons.onboardingExcuse,
    AppIcons.onboardingAlerts,
  ];

  int _index = 0;

  bool get _isLast => _index == UiContent.onboarding.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      setState(() => _index++);
    }
  }

  void _finish() {
    AppUtils.instance.setOnboardingSeen();
    AppUtils.goAndReplace(const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final slide = UiContent.onboarding[_index];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              Dimensions.screenPadding, 10.h, Dimensions.screenPadding, 32.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(AppIcons.school, size: 32.sp, color: AppColors.primary),
                  TextLinkButton(label: AppText.skip, onTap: _finish),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 132.w,
                      height: 132.w,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(38.r),
                      ),
                      alignment: Alignment.center,
                      child:
                          Icon(_icons[_index], size: 58.sp, color: AppColors.primaryDark),
                    ),
                    SizedBox(height: 26.h),
                    Text(
                      slide[0],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTextStyles.s20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 26.h),
                    Text(
                      slide[1],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTextStyles.s12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  UiContent.onboarding.length,
                  (i) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: (i == _index ? 22 : 8).w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.primary : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              PrimaryButton(
                label: _isLast ? AppText.startNow : AppText.next,
                onTap: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
