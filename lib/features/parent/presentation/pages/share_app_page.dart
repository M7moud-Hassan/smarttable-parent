import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_constants.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/conts/ui_content.dart';
import 'main_shell.dart';

/// هـ9 مشاركة التطبيق — رابط المتجر، ومنصات المشاركة.
class ShareAppPage extends StatelessWidget {
  const ShareAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentScaffold(
      title: AppText.shareTitle,
      onBack: AppUtils.back,
      showBottomNav: false,
      onTabSelected: MainShell.openTab,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _linkCard(),
          SizedBox(height: 22.h),
          SectionTitle(AppText.shareVia),
          SizedBox(height: 14.h),
          _platformsCard(),
          SizedBox(height: 14.h),
          FieldHint(AppText.shareIconsHint),
        ],
      ),
    );
  }

  Widget _linkCard() => AppCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.center,
              child: Icon(AppIcons.school, size: 40.sp, color: AppColors.primaryDark),
            ),
            SizedBox(height: 16.h),
            Text(AppConstants.appName, style: AppTextStyles.cardTitle),
            SizedBox(height: 12.h),
            Text(
              AppText.shareSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(height: 1.7),
            ),
            SizedBox(height: 18.h),
            Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppConstants.storeLink,
                      style: TextStyle(
                        fontSize: AppTextStyles.s12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      )),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: AppConstants.storeLink));
                      AppUtils.showCustomSnackbar(AppText.copied, SnackType.SUCESS);
                    },
                    child: Text(AppText.copy,
                        style: AppTextStyles.smallButton
                            .copyWith(color: AppColors.primaryDark)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// الدوائر مواضع مؤقتة لأيقونات المنصات كما ينصّ التصميم، والضغط على أيّها
  /// يفتح ورقة المشاركة الأصلية للنظام.
  Widget _platformsCard() => AppCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: UiContent.sharePlatforms.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 18.h,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (_, index) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Share.share(
              '${AppConstants.appName}\n${AppConstants.storeLink}',
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.dashed),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppText.iconPlaceholder,
                    style: TextStyle(
                      fontSize: AppTextStyles.s10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  UiContent.sharePlatforms[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTextStyles.s10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
