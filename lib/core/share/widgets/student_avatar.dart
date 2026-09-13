import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';

/// صورة الطالب مع شارة عدد التنبيهات غير المقروءة.
///
/// الشارة في التصميم على الحافة العليا اليسرى من الدائرة، ولأن الواجهة كلها
/// RTL تُوضع هنا بـ `Positioned` صريح لا `start/end` كي لا تنقلب مع الاتجاه.
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    required this.name,
    this.photo,
    this.size = 56,
    this.badgeCount = 0,
    this.selected = false,
    this.badgeBorderColor = Colors.white,
  });

  final String name;
  final String? photo;
  final double size;
  final int badgeCount;

  /// حلقة بلون الهوية حول الطالب المختار.
  final bool selected;
  final Color badgeBorderColor;

  @override
  Widget build(BuildContext context) {
    final dimension = size.w;
    final badgeSize = (size * .36).w;

    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: dimension,
            height: dimension,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 3 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _photo(),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -2.h,
              left: -2.w,
              child: Container(
                constraints: BoxConstraints(minWidth: badgeSize),
                height: badgeSize,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(badgeSize / 2),
                  border: Border.all(color: badgeBorderColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: (size * .18).sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _photo() {
    if (photo != null && photo!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: photo!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _initial(),
        placeholder: (_, __) => _initial(),
      );
    }
    return _initial();
  }

  Widget _initial() => Center(
        child: Text(
          name.trim().isEmpty ? '؟' : name.trim()[0],
          style: TextStyle(
            fontSize: (size * .36).sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      );
}
