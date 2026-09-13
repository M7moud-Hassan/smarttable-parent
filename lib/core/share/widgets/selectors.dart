import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';
import '../../conts/icons.dart';

/// شريحة اختيار بيضاوية — أسباب الغياب، الأمراض المزمنة، نوع الملاحظة.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 36,
    this.filledStyle = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  /// شرائح المادة والمعلم في تقرير السلوك لا تحمل حدّاً: المختارة بلون
  /// primary-dark وغير المختارة على خلفية رمادية.
  final bool filledStyle;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final Color? border;

    if (filledStyle) {
      background = selected ? AppColors.primaryDark : AppColors.fill;
      foreground = selected ? Colors.white : AppColors.text;
      border = null;
    } else {
      background = selected ? AppColors.primary : Colors.transparent;
      foreground = selected ? Colors.white : AppColors.primaryDark;
      border = AppColors.primary;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(25.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(25.r),
        onTap: onTap,
        child: Container(
          height: height.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
            border: border == null ? null : Border.all(color: border),
          ),
          // الشريحة تلتفّ حول نصّها في `Wrap`، وتتوسّط حين تُفرض عليها عرضاً
          // داخل `Expanded`. أما `alignment` على `Container` فيمدّها دائماً.
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppTextStyles.smallButton.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

/// تبويبان داخل إطار بيضاوي واحد — «الملاحظات / الإحصائية» و«الكل / يتطلب
/// اطلاعك».
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: AppColors.primary),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: AppTextStyles.s14,
                      fontWeight: FontWeight.w500,
                      color: i == selectedIndex ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// خانة اختيار مربّعة 22 داخل صفّ — أيام الفترة في شاشة تقديم العذر.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
            border: Border.all(
              color: checked ? AppColors.primary : AppColors.primaryLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: checked ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(
                    color: checked ? AppColors.primary : AppColors.primaryLight,
                  ),
                ),
                alignment: Alignment.center,
                child: checked
                    ? Icon(AppIcons.check, size: 14.sp, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(child: Text(label, style: AppTextStyles.body)),
            ],
          ),
        ),
      ),
    );
  }
}

/// مفتاح 44×26 بمقبض 20 — شاشة إعدادات التنبيهات.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 44.w,
        height: 26.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.switchOff,
          borderRadius: BorderRadius.circular(13.r),
        ),
        alignment: value ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0x47000000),
                blurRadius: 3,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
