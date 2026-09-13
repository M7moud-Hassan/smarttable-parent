import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/parent/data/models/student_model.dart';
import '../../conts/app_colors.dart';
import '../../conts/app_constants.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';
import '../../conts/icons.dart';
import '../../conts/text.dart';
import '../../utils/app_utils.dart';
import 'app_bottom_nav.dart';
import 'parent_avatar.dart';
import 'student_avatar.dart';

/// الشريط الجانبي في نسخة التابلت (شاشة B4): شعار، بطاقة ولي الأمر، قائمة
/// الأبناء، ثم التبويبات الثلاثة نفسها التي في الشريط السفلي.
class ParentSidebar extends StatelessWidget {
  const ParentSidebar({super.key, this.current, required this.onSelect});

  final ParentTab? current;
  final ValueChanged<ParentTab> onSelect;

  @override
  Widget build(BuildContext context) {
    // قائمة الأبناء تُقرأ من الحالة العامّة لا من بلوك بعينه، لأن الشريط
    // يُبنى خارج شجرة أي شاشة.
    final students = AppUtils.students;

    return Container(
      width: Dimensions.sidebarWidth,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(right: BorderSide(color: AppColors.sidebarBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _brand(),
          SizedBox(height: 20.h),
          _parentCard(),
          SizedBox(height: 22.h),
          Text('الأبناء',
              style: AppTextStyles.caption.copyWith(
                fontSize: AppTextStyles.s10,
                fontWeight: FontWeight.w600,
                color: AppColors.textFaint,
              )),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final student in students) ...[
                    _studentRow(student),
                    SizedBox(height: 8.h),
                  ],
                  SizedBox(height: 14.h),
                  const Divider(color: AppColors.sidebarBorder, height: 1),
                  SizedBox(height: 16.h),
                  _navItem(ParentTab.home, AppIcons.home, AppText.home),
                  _navItem(ParentTab.notifications, AppIcons.bell, AppText.notifications),
                  _navItem(ParentTab.account, AppIcons.account, AppText.account),
                ],
              ),
            ),
          ),
          Text(
            'الإصدار ${AppConstants.version}',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: AppTextStyles.s9, color: AppColors.textPlaceholder),
          ),
        ],
      ),
    );
  }

  Widget _brand() => Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Icon(AppIcons.school, size: 20.sp, color: AppColors.primaryDark),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConstants.appNameShort,
                  style: TextStyle(
                    fontSize: AppTextStyles.s14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  )),
              SizedBox(height: 3.h),
              Text(AppConstants.appRole, style: AppTextStyles.caption),
            ],
          ),
        ],
      );

  Widget _parentCard() => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            const ParentAvatar(size: 38),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppUtils.appUser?.name ?? '',
                    style: TextStyle(
                      fontSize: AppTextStyles.s12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text('ولي أمر', style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _studentRow(Student student) {
    final selected = AppUtils.selectedStudent?.id == student.id;
    return Material(
      color: selected ? AppColors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(Dimensions.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        onTap: () {
          AppUtils.selectedStudent = student;
          AppUtils.instance.setSelectedStudentId(student.id);
          Get.forceAppUpdate();
        },
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.cardRadius),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              StudentAvatar(
                name: student.name,
                photo: student.photo,
                size: 38,
                badgeCount: student.unreadCount,
                badgeBorderColor: AppColors.sidebar,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: AppTextStyles.s12,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.primaryDark : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      student.classLabel,
                      style: TextStyle(
                        fontSize: AppTextStyles.s9,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(ParentTab tab, IconData icon, String label) {
    final active = current == tab;
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: active ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
          onTap: () => onSelect(tab),
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Icon(icon,
                    size: 20.sp,
                    color: active ? AppColors.primaryDark : const Color(0xFF6B6B6B)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: AppTextStyles.s13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? AppColors.primaryDark : const Color(0xFF6B6B6B),
                    ),
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
