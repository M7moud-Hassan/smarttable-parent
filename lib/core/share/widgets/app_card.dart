import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';

/// البطاقة البيضاء ذات الظل `0 4px 10px rgba(0,0,0,.25)` — العنصر الأكثر
/// تكراراً في التطبيق.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color = AppColors.surface,
    this.onTap,
    this.borderColor,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color color;
  final VoidCallback? onTap;

  /// حدّ بدل الظل — بطاقات الحصص في الجدول المدرسي.
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius ?? Dimensions.cardRadius);
    final content = Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: shadow ? AppColors.cardShadow : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: content),
    );
  }
}

/// لوح ملوّن بلا ظل يحمل نصّ إرشاد أو تحذير — يتكرّر في أعلى أغلب الشاشات.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.background = AppColors.primarySoft,
    this.foreground = AppColors.primaryDark,
    this.icon,
    this.lineHeight = 1.7,
    this.child,
  });

  final String message;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final double lineHeight;

  /// محتوى إضافي أسفل النص.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20.sp, color: foreground),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: AppTextStyles.s12,
                    fontWeight: FontWeight.w500,
                    color: foreground,
                    height: lineHeight,
                  ),
                ),
              ),
            ],
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// شارة حالة بيضاوية — «3 غياب بدون عذر»، «العذر مقبول»، «بعد 5 أيام».
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.height,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double? height;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 26.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Dimensions.pillRadius),
      ),
      // `Center` بمعامل عرض 1: يلتفّ حول النص حين تكون القيود فضفاضة —
      // وهو الحال في عمود البطاقة — ويتوسّط حين تُفرض عليه عرضاً.
      // أما `alignment` على `Container` فيتمدّد إلى أقصى العرض المتاح.
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(color: foreground, fontWeight: fontWeight),
        ),
      ),
    );
  }
}

/// مربّع أيقونة ملوّن 40 أو 50 بزوايا 5 — يسبق عنوان البطاقة في كل القوائم.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 40,
    this.iconSize,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5.r),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: (iconSize ?? size * .48).sp, color: foreground),
    );
  }
}

/// عنوان قسم داخل الشاشة — 14/600 محاذى لليمين.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (trailing == null) {
      return SizedBox(
        width: double.infinity,
        child: Text(title, style: AppTextStyles.sectionTitle),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        trailing!,
      ],
    );
  }
}

/// تسمية حقل — 12/500 بلون primary-dark.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Text(label, style: AppTextStyles.label),
      );
}

/// سطر تلميح تحت الحقل — 10/400 رمادي.
class FieldHint extends StatelessWidget {
  const FieldHint(this.hint, {super.key, this.color});

  final String hint;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Text(
          hint,
          style: AppTextStyles.captionFaint
              .copyWith(color: color ?? AppColors.textFaint, height: 1.8),
        ),
      );
}
