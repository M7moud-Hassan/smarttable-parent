import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';

/// الزر الرئيسي: ارتفاع 50، زوايا 24 (pill)، نص 20/500 أبيض.
///
/// الزر المعطّل في التصميم لا يبهت بل يصير بلون `primary-light` — وهي حالته
/// الافتراضية في شاشات النماذج قبل اكتمال الإدخال.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.color,
    this.height,
    this.fontSize,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? color;
  final double? height;
  final double? fontSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    return SizedBox(
      width: double.infinity,
      height: height ?? Dimensions.buttonHeight,
      child: Material(
        color: active ? (color ?? AppColors.primary) : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(Dimensions.pillRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.pillRadius),
          onTap: active ? onTap : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18.sp, color: Colors.white),
                  SizedBox(width: 10.w),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.primaryButton
                        .copyWith(fontSize: fontSize ?? AppTextStyles.s20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// زر بحدّ داخلي وخلفية شفّافة — «التسجيل لأول مرة»، «إلغاء»، «طلب تغيير الموعد».
class OutlinedPillButton extends StatelessWidget {
  const OutlinedPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primaryDark,
    this.background = Colors.transparent,
    this.height,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onTap;
  final Color borderColor;
  final Color textColor;
  final Color background;
  final double? height;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 44.h,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(Dimensions.pillRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.pillRadius),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.pillRadius),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize ?? AppTextStyles.s14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر صغير داخل البطاقات — ارتفاع 34 أو 36، نص 12/500.
class SmallPillButton extends StatelessWidget {
  const SmallPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.filled = true,
    this.color = AppColors.primary,
    this.textColor,
    this.height,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;

  /// ممتلئ بلون الهوية، أو محدَّد فقط.
  final bool filled;
  final Color color;
  final Color? textColor;
  final double? height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height ?? Dimensions.smallButtonHeight,
      child: Material(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.pillRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.pillRadius),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.pillRadius),
              border: filled ? null : Border.all(color: color),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.smallButton.copyWith(
                  color: textColor ?? (filled ? Colors.white : AppColors.primaryDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// رابط نصّي بلا خلفية — «نسيت كلمة المرور؟»، «تعليم الكل كمقروء»، «تخطي».
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = AppColors.primaryDark,
    this.fontSize,
    this.fontWeight = FontWeight.w500,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double? fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize ?? AppTextStyles.s12,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}
