import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_constants.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_bottom_nav.dart';
import '../../../../core/share/widgets/parent_avatar.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/notifications/notifications_bloc.dart';
import 'alerts_settings_page.dart';
import 'change_password_page.dart';
import 'contact_school_page.dart';
import 'delete_account_page.dart';
import 'faq_page.dart';
import 'language_page.dart';
import 'login_page.dart';
import 'personal_data_page.dart';
import 'select_student_page.dart';
import 'share_app_page.dart';
import 'static_content_page.dart';
import 'support_page.dart';

/// B3 حسابي — أربعة عشر رابطاً إلى مسار هـ، وتسجيل الخروج.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.tab, required this.onTab});

  final ParentTab tab;
  final ValueChanged<ParentTab> onTab;

  @override
  Widget build(BuildContext context) {
    final user = AppUtils.appUser;

    return BlocProvider(
      create: (_) => bloc<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoggedOutState) AppUtils.goAndReplace(const LoginPage());
        },
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, notificationsState) {
            return ParentScaffold(
              title: AppText.account,
              showBottomNav: true,
              currentTab: tab,
              onTabSelected: onTab,
              backgroundColor: AppColors.accountBackground,
              hasUnreadNotifications: notificationsState is NotificationsLoadedState &&
                  notificationsState.unreadCount > 0,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      const ParentAvatar(size: 75),
                      SizedBox(height: 16.h),
                      Text(
                        user?.name ?? '',
                        style: TextStyle(
                          fontSize: AppTextStyles.s16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        user?.displayPhone ?? '',
                        style: TextStyle(
                          fontSize: AppTextStyles.s12,
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      _editPhotoButton(),
                    ],
                  ),
                  SizedBox(height: 28.h),
                  ..._links(context),
                  SizedBox(height: 30.h),
                  Text(
                    '${AppConstants.appName} · الإصدار ${AppConstants.version}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionFaint,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _editPhotoButton() => Center(
        child: GestureDetector(
          onTap: () => AppUtils.go(const PersonalDataPage()),
          child: Container(
            height: 27.h,
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                AppText.editPhoto,
                style: AppTextStyles.smallButton.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      );

  List<Widget> _links(BuildContext context) {
    final items = <_Link>[
      _Link(AppIcons.profile, AppText.personalDataTitle,
          () => AppUtils.go(const PersonalDataPage())),
      _Link(AppIcons.children, AppText.myChildren,
          () => AppUtils.go(const SelectStudentPage())),
      _Link(AppIcons.password, AppText.passwordTitle,
          () => AppUtils.go(const ChangePasswordPage())),
      _Link(AppIcons.notificationSettings, AppText.alertsTitle,
          () => AppUtils.go(const AlertsSettingsPage())),
      _Link(AppIcons.language, AppText.languageTitle,
          () => AppUtils.go(const LanguagePage())),
      _Link(AppIcons.school, AppText.contactSchoolTitle,
          () => AppUtils.go(const ContactSchoolPage())),
      _Link(
          AppIcons.support, AppText.supportTitle, () => AppUtils.go(const SupportPage())),
      _Link(AppIcons.about, AppText.aboutTitle,
          () => AppUtils.go(const StaticContentPage.about())),
      _Link(AppIcons.faq, AppText.faqTitle, () => AppUtils.go(const FaqPage())),
      _Link(AppIcons.privacy, AppText.privacyTitle,
          () => AppUtils.go(const StaticContentPage.privacy())),
      _Link(AppIcons.terms, AppText.termsTitle,
          () => AppUtils.go(const StaticContentPage.terms())),
      _Link(AppIcons.share, AppText.shareTitle, () => AppUtils.go(const ShareAppPage())),
      _Link(AppIcons.deleteAccount, AppText.deleteAccountTitle,
          () => AppUtils.go(const DeleteAccountPage()),
          danger: true),
      _Link(AppIcons.logout, AppText.logout,
          () => context.read<AuthBloc>().add(LogoutEvent()),
          danger: true),
    ];

    return [
      for (final link in items) ...[
        _row(link),
        SizedBox(height: 16.h),
      ],
    ];
  }

  Widget _row(_Link link) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: link.onTap,
        child: Row(
          children: [
            Icon(link.icon, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                link.label,
                style: AppTextStyles.body.copyWith(
                  color: link.danger ? AppColors.danger : AppColors.text,
                ),
              ),
            ),
            Icon(AppIcons.chevron, size: 18.sp, color: AppColors.textMuted),
          ],
        ),
      );
}

class _Link {
  const _Link(this.icon, this.label, this.onTap, {this.danger = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
}
