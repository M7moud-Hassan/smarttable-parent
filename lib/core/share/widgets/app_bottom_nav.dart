import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';
import '../../conts/icons.dart';
import '../../conts/text.dart';

/// تبويبات الشريط السفلي بترتيب التصميم: الإشعارات ثم الرئيسية ثم حسابي.
/// في RTL يقع أولها يميناً، فالإشعارات على اليمين وحسابي على اليسار.
enum ParentTab { notifications, home, account }

/// الشريط السفلي — ارتفاع 58، مؤشّر بعرض 36 ينزل من الحافة العليا للتبويب النشط.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    this.current,
    required this.onSelect,
    this.hasUnreadNotifications = false,
  });

  /// التبويب النشط، و`null` حين لا تبويب نشطاً — وهي حال الشاشات الداخلية
  /// في التصميم: الشريط ظاهر وكل تبويباته رمادية.
  final ParentTab? current;
  final ValueChanged<ParentTab> onSelect;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.bottomBarHeight,
      padding: EdgeInsets.symmetric(horizontal: Dimensions.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Tab(
            tab: ParentTab.notifications,
            icon: AppIcons.bell,
            label: AppText.notifications,
            active: current == ParentTab.notifications,
            dot: hasUnreadNotifications,
            onTap: onSelect,
          ),
          _Tab(
            tab: ParentTab.home,
            icon: AppIcons.home,
            label: AppText.home,
            active: current == ParentTab.home,
            onTap: onSelect,
          ),
          _Tab(
            tab: ParentTab.account,
            icon: AppIcons.account,
            label: AppText.account,
            active: current == ParentTab.account,
            onTap: onSelect,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.dot = false,
  });

  final ParentTab tab;
  final IconData icon;
  final String label;
  final bool active;
  final bool dot;
  final ValueChanged<ParentTab> onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.tabActive : AppColors.textFaint;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(tab),
      child: SizedBox(
        width: 55.w,
        height: Dimensions.bottomBarHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // المؤشّر يلتصق بالحافة العليا للشريط لا بالأيقونة.
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: active ? AppColors.tabActive : Colors.transparent,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.r)),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(icon, size: 24.sp, color: color),
                        if (dot)
                          Positioned(
                            top: -1.h,
                            left: -2.w,
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(label, style: AppTextStyles.tab.copyWith(color: color)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
