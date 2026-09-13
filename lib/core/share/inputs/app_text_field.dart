import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';
import '../../conts/icons.dart';

/// حقل الإدخال القياسي: ارتفاع 48، زوايا 8، حدّ 1px بلون primary-dark،
/// أيقونة على اليمين، ونصّ محاذى لليمين.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.enabled = true,
    this.textAlign = TextAlign.right,
  });

  final TextEditingController? controller;
  final String? hint;

  /// `null` يحذف الأيقونة ويترك النص ملاصقاً للحافة — كحقول شاشة هـ١.
  final IconData? icon;

  /// حقل كلمة مرور: يبدأ مخفياً ويحمل زر إظهار.
  final bool obscure;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextAlign textAlign;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.fieldHeight,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
        border: Border.all(color: AppColors.primaryDark),
      ),
      child: Row(
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              obscureText: _hidden,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              textAlign: widget.textAlign,
              style: AppTextStyles.body,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: AppTextStyles.s12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPlaceholder,
                ),
              ),
            ),
          ),
          if (widget.obscure)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _hidden = !_hidden),
              child: Icon(
                _hidden ? AppIcons.eye : AppIcons.eyeOff,
                size: 16.sp,
                color: AppColors.textFaint,
              ),
            ),
        ],
      ),
    );
  }
}

/// مربّع نصّ متعدّد الأسطر — ملاحظة ولي الأمر وتعليمات الحالة الصحية.
class AppTextArea extends StatelessWidget {
  const AppTextArea({
    super.key,
    this.controller,
    this.hint,
    this.height = 96,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? hint;
  final double height;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
        border: Border.all(color: AppColors.primaryDark),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: null,
        expands: true,
        textAlign: TextAlign.right,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: AppColors.primary,
        style: AppTextStyles.body.copyWith(height: 1.8),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: AppTextStyles.s12,
            fontWeight: FontWeight.w400,
            color: AppColors.textPlaceholder,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}
