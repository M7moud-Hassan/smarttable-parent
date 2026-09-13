import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/share/widgets/student_avatar.dart';
import '../../data/models/student_model.dart';

/// شريط الأبناء أفقياً أعلى الرئيسية. يمتدّ إلى حافتي الشاشة رغم هامش الجسم،
/// فتظهر البطاقة التالية مقتطعة عند الحافة وتدعو إلى السحب.
class StudentStrip extends StatelessWidget {
  const StudentStrip({
    super.key,
    required this.students,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Student> students;
  final String? selectedId;
  final ValueChanged<Student> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.screenPadding),
        itemCount: students.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (_, index) {
          final student = students[index];
          final selected = student.id == selectedId;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(student),
            child: SizedBox(
              width: 64.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StudentAvatar(
                    name: student.name,
                    photo: student.photo,
                    size: 56,
                    badgeCount: student.unreadCount,
                    selected: selected,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    student.firstName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTextStyles.s12,
                      height: 1.3,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.primaryDark : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
