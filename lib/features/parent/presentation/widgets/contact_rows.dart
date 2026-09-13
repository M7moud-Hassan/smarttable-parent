import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/utils/app_utils.dart';
import '../../data/models/school_model.dart';

/// بطاقة سطر تواصل — تخدم «تواصل مع المدرسة» و«الدعم الفني» معاً، فالشاشتان
/// في التصميم قالب واحد بمحتويين.
class ContactRowCard extends StatelessWidget {
  const ContactRowCard({super.key, required this.row});

  final ContactRow row;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 8,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      onTap: row.action == null ? null : () => _open(row.action!),
      child: Row(
        children: [
          IconTile(
            icon: _icons[row.kind]!,
            background: AppColors.primarySoft,
            foreground: AppColors.primaryDark,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label, style: AppTextStyles.caption),
                SizedBox(height: 7.h),
                // القيمة تأتي من الخادم وقد تكون رقماً أو بريداً، فتُعزَل كي
                // لا ينقلب ترتيب مقاطعها داخل الواجهة العربية.
                Text(AppUtils.isolate(row.value), style: AppTextStyles.cardTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const Map<ContactKind, IconData> _icons = {
    ContactKind.phone: AppIcons.call,
    ContactKind.email: AppIcons.mail,
    ContactKind.hours: AppIcons.clock,
    ContactKind.address: AppIcons.location,
  };

  Future<void> _open(String action) async {
    final uri = Uri.tryParse(action);
    if (uri == null || !await launchUrl(uri)) {
      AppUtils.showCustomSnackbar('تعذّر فتح هذا الإجراء.', SnackType.FAILURE);
    }
  }
}
