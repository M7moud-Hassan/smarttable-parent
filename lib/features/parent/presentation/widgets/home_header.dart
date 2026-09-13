import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/parent_avatar.dart';
import '../../../../core/utils/app_utils.dart';

/// ترويسة الرئيسية الملوّنة: أفاتار ولي الأمر يميناً، «الرئيسية» في الوسط،
/// جرس الإشعارات يساراً بنقطة حمراء، ثم سطرا التحية واسم المدرسة.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onBell, this.hasUnread = false});

  final VoidCallback onBell;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final user = AppUtils.appUser;
    final school = AppUtils.selectedStudent?.school ?? user?.schoolName ?? '';

    return Container(
      // الارتفاع من المحتوى لا رقماً ثابتاً: سطر التحية قد يلتفّ على اسم
      // طويل، ورقمٌ ثابت يقصّه.
      padding: EdgeInsets.symmetric(horizontal: Dimensions.screenPadding, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38.h,
            child: Row(
              children: [
                const ParentAvatar(size: 38, borderColor: Color(0x99FFFFFF)),
                Expanded(
                  child: Text(
                    AppText.home,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.screenTitleOnPrimary,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBell,
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(AppIcons.bell, size: 24.sp, color: Colors.white),
                        if (hasUnread)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 9.w,
                              height: 9.w,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            '${AppText.welcome}${_firstNameOf(user?.name)}',
            style: TextStyle(
              fontSize: AppTextStyles.s14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          Text(
            school,
            style: TextStyle(
              fontSize: AppTextStyles.s14,
              fontWeight: FontWeight.w400,
              color: const Color(0xD9FFFFFF),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// التحية في التصميم بالكنية لا بالاسم الكامل: «مرحباً بك، أبو عبدالرحمن».
  String _firstNameOf(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(' ');
    return parts.length >= 2 ? '${parts[0]} ${parts[1]}' : parts.first;
  }
}
