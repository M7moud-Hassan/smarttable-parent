import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';
import '../../conts/icons.dart';
import 'parent_avatar.dart';

/// ترويسة الشاشات الداخلية: ارتفاع 48، أفاتار ولي الأمر على اليمين، العنوان في
/// الوسط، وسهم الرجوع على اليسار — كما في كل شاشة من A4 إلى هـ10.
///
/// حين لا يكون للشاشة سهم رجوع يبقى الأفاتار مخفياً محجوزاً للمساحة
/// (`visibility: hidden` في التصميم) ليظل العنوان في منتصف الشاشة تماماً.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showAvatar = true,
    this.trailing,
  });

  final String title;

  /// `null` يخفي سهم الرجوع ويترك مكانه فارغاً.
  final VoidCallback? onBack;

  /// إخفاء الأفاتار مع الإبقاء على مساحته — لتوسيط العنوان.
  final bool showAvatar;

  /// بديل سهم الرجوع حين تحتاج الشاشة زراً آخر.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimensions.headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            Dimensions.screenPadding, 4.h, Dimensions.screenPadding, 10.h),
        child: Row(
          children: [
            Opacity(
              opacity: showAvatar ? 1 : 0,
              child: const ParentAvatar(size: 38),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.screenTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: trailing ??
                  (onBack == null
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: onBack,
                          child: Icon(
                            AppIcons.back,
                            size: 18.sp,
                            color: AppColors.primaryDark,
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
