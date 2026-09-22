import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../bloc/settings/settings_bloc.dart';
import 'main_shell.dart';

/// هـ4 اللغة — العربية أو الإنجليزية.
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<SettingsBloc>(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final current = state is LanguageChangedState
              ? state.languageCode
              : AppUtils.instance.getLocale().languageCode;

          return ParentScaffold(
            title: AppText.languageTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _option(
                  context,
                  title: AppText.arabic,
                  subtitle: AppText.arabicSubtitle,
                  selected: current == 'ar',
                  languageCode: 'ar',
                  countryCode: 'SA',
                ),
                SizedBox(height: 12.h),
                _option(
                  context,
                  title: AppText.english,
                  subtitle: AppText.englishSubtitle,
                  selected: current == 'en',
                  languageCode: 'en',
                  countryCode: 'US',
                ),
                SizedBox(height: 16.h),
                FieldHint(AppText.languageHint),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool selected,
    required String languageCode,
    required String countryCode,
  }) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
        onTap: () => context.read<SettingsBloc>().add(ChangeLanguageEvent(
              languageCode: languageCode,
              countryCode: countryCode,
            )),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
            border: Border.all(
              color: selected ? AppColors.primaryDark : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    SizedBox(height: 7.h),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(
                selected ? AppIcons.checkCircle : AppIcons.chevron,
                size: 18.sp,
                color: AppColors.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
