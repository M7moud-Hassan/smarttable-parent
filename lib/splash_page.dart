import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/conts/app_colors.dart';
import 'core/conts/app_constants.dart';
import 'core/conts/app_text_styles.dart';
import 'core/conts/icons.dart';
import 'core/utils/app_utils.dart';
import 'features/parent/presentation/pages/login_page.dart';
import 'features/parent/presentation/pages/main_shell.dart';
import 'features/parent/presentation/pages/onboarding_page.dart';

/// A1 شاشة البداية — تنتقل تلقائياً بعد ثانيتين.
///
/// الوجهة تختلف بحسب حال المستخدم: من لم يرَ الشاشات التعريفية يراها، ومن دخل
/// من قبل يذهب إلى الرئيسية مباشرة، وما عداهما إلى شاشة الدخول.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashDelay, _go);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _go() {
    if (!mounted) return;
    if (!AppUtils.instance.getOnboardingSeen()) {
      AppUtils.goAndReplace(const OnboardingPage());
    } else if (AppUtils.instance.getLogin() != null) {
      AppUtils.goAndReplace(const MainShell());
    } else {
      AppUtils.goAndReplace(const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 132.w,
              height: 132.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(34.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    blurRadius: 30,
                    offset: Offset(0, 12.h),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(AppIcons.school, size: 66.sp, color: AppColors.primary),
            ),
            SizedBox(height: 22.h),
            Text(AppConstants.wordmark, style: AppTextStyles.wordmark),
            SizedBox(height: 10.h),
            Text(
              AppConstants.appNameShort,
              style: TextStyle(
                fontSize: AppTextStyles.s20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              AppConstants.appRole,
              style: TextStyle(
                fontSize: AppTextStyles.s14,
                fontWeight: FontWeight.w400,
                color: const Color(0xE6FFFFFF),
              ),
            ),
            SizedBox(height: 36.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.5.w),
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
