import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../data/models/home_model.dart';

/// لون وأيقونة كل خدمة كما في شبكة الرئيسية — كلٌّ بلونه لا بلون واحد.
class ServiceStyle {
  const ServiceStyle(this.icon, this.background, this.foreground);

  final IconData icon;
  final Color background;
  final Color foreground;

  static const Map<HomeService, ServiceStyle> map = {
    HomeService.schedule: ServiceStyle(
        AppIcons.schedule, AppColors.primarySoft, AppColors.primaryDark),
    HomeService.attendance: ServiceStyle(
        AppIcons.attendance, AppColors.warningDeep, AppColors.orange),
    HomeService.behavior:
        ServiceStyle(AppIcons.behavior, AppColors.infoSoft, AppColors.info),
    HomeService.adminActions: ServiceStyle(
        AppIcons.adminActions, AppColors.purpleSoft, AppColors.purple),
    HomeService.exams: ServiceStyle(
        AppIcons.exams, AppColors.warningSoft, AppColors.warningIcon),
    HomeService.circulars: ServiceStyle(
        AppIcons.circulars, AppColors.primarySoft, AppColors.primaryDark),
    HomeService.health:
        ServiceStyle(AppIcons.health, AppColors.dangerSoft, AppColors.danger),
  };

  static ServiceStyle of(HomeService service) =>
      map[service] ?? map[HomeService.schedule]!;
}

/// بطاقة خدمة في الشبكة: الأيقونة أعلى اليمين ثم العنوان ثم العدّاد.
class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.card, required this.onTap});

  final ServiceCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = ServiceStyle.of(card.service);
    return AppCard(
      onTap: onTap,
      child: Column(
        // الأيقونة والنصّ في جهة البدء — اليمين في الواجهة العربية.
        //
        // لقطة التصميم تضعها يسارًا (`align-items: flex-end`)، وهذا اختيارٌ
        // مقصود بخلافها: البطاقة تُقرأ من اليمين، فتبدأ بالأيقونة لا تنتهي بها.
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(
            icon: style.icon,
            background: style.background,
            foreground: style.foreground,
            size: 50,
          ),
          SizedBox(height: 8.h),
          Text(card.title,
              style: AppTextStyles.cardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 8.h),
          Text(card.subtitle,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// بطاقة الخدمة العريضة التي تشغل الصفّ كاملاً — «الحالة الصحية» في التصميم.
class WideServiceTile extends StatelessWidget {
  const WideServiceTile({super.key, required this.card, required this.onTap});

  final ServiceCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = ServiceStyle.of(card.service);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconTile(
            icon: style.icon,
            background: style.background,
            foreground: style.foreground,
            size: 50,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: AppTextStyles.cardTitle),
                SizedBox(height: 7.h),
                Text(card.subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(AppIcons.chevron, size: 18.sp, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
