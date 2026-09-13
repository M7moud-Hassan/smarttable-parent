import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/icons.dart';
import '../../utils/app_utils.dart';

/// صورة ولي الأمر في الترويسة وشاشة حسابي.
///
/// حزمة التصميم لا تضمّ ملف الأفاتار، فحين لا يرسل الخادم صورة يظهر حرف الاسم
/// الأول على خلفية الهوية بدل مربّع فارغ.
class ParentAvatar extends StatelessWidget {
  const ParentAvatar({super.key, this.size = 38, this.borderColor});

  final double size;

  /// حدّ أبيض شفّاف حول الصورة فوق ترويسة الرئيسية الملوّنة.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final user = AppUtils.appUser;
    final dimension = size.w;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primarySoft,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: _image(user?.avatar, user?.name),
    );
  }

  Widget _image(String? avatar, String? name) {
    if (avatar == null || avatar.isEmpty) return _initial(name);

    if (avatar.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: avatar,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _initial(name),
        placeholder: (_, __) => _initial(name),
      );
    }
    return Image.file(File(avatar),
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initial(name));
  }

  Widget _initial(String? name) {
    final letter = (name == null || name.trim().isEmpty) ? null : name.trim()[0];
    return Center(
      child: letter == null
          ? Icon(AppIcons.user, size: size.w * .5, color: AppColors.primaryDark)
          : Text(
              letter,
              style: TextStyle(
                fontSize: size.sp * .45,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
    );
  }
}
