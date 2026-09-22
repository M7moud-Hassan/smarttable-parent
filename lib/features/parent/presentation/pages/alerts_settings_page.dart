import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_constants.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/share/widgets/selectors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../../../core/conts/ui_content.dart';
import '../../data/models/home_model.dart';
import '../bloc/settings/settings_bloc.dart';
import 'main_shell.dart';

/// هـ3 إعدادات التنبيهات — معاينة شكل التنبيه على الجهاز، ثم ستة مفاتيح.
class AlertsSettingsPage extends StatelessWidget {
  const AlertsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<SettingsBloc>()..add(GetSettingsEvent()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.alertsTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(AppText.alertPreview),
                SizedBox(height: 14.h),
                _preview(),
                SizedBox(height: 22.h),
                SectionTitle(AppText.whatToReceive),
                SizedBox(height: 8.h),
                FieldHint(AppText.alertsKeptHint),
                SizedBox(height: 18.h),
                if (state is SettingsLoadedState)
                  for (final setting in state.settings) ...[
                    _switchRow(context, setting),
                    SizedBox(height: 12.h),
                  ]
                else
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// معاينة الإشعار فوق لوح داكن يمثّل شاشة الجهاز — كما في التصميم.
  Widget _preview() => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.deviceSheet,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            for (var i = 0; i < UiContent.notificationPreviews.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              _previewCard(UiContent.notificationPreviews[i]),
            ],
          ],
        ),
      );

  Widget _previewCard(NotificationPreview preview) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xF0FFFFFF),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: const [
            BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(9.r),
              ),
              alignment: Alignment.center,
              child: Icon(AppIcons.school, size: 22.sp, color: AppColors.primaryDark),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: AppTextStyles.s11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(preview.age,
                          style: TextStyle(
                            fontSize: AppTextStyles.s10,
                            color: AppColors.notificationTime,
                          )),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    preview.title,
                    style: TextStyle(
                      fontSize: AppTextStyles.s12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    preview.body,
                    style: TextStyle(
                      fontSize: AppTextStyles.s11,
                      color: AppColors.notificationBody,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _switchRow(BuildContext context, NotificationSetting setting) => AppCard(
        radius: 8,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(setting.title, style: AppTextStyles.cardTitle),
                  SizedBox(height: 7.h),
                  Text(setting.subtitle,
                      style: AppTextStyles.caption.copyWith(height: 1.5)),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            AppSwitch(
              value: setting.enabled,
              onChanged: (_) =>
                  context.read<SettingsBloc>().add(ToggleSettingEvent(key: setting.key)),
            ),
          ],
        ),
      );
}
