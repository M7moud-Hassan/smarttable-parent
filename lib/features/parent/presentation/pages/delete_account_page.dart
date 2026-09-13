import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../bloc/auth/auth_bloc.dart';
import 'login_page.dart';
import 'main_shell.dart';

/// هـ10 حذف الحساب — تأكيد أو إلغاء.
class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AccountDeletedState) {
            AppUtils.showCustomSnackbar(AppText.deleteRequested, SnackType.SUCESS);
            AppUtils.instance.logout();
            AppUtils.goAndReplace(const LoginPage());
          } else if (state is AuthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.deleteAccountTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10.h),
                Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: const BoxDecoration(
                        color: AppColors.dangerSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(AppIcons.deleteAccount,
                          size: 30.sp, color: AppColors.danger),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppText.deleteAccountHeading,
                      style: TextStyle(
                        fontSize: AppTextStyles.s16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppText.deleteAccountBody1,
                          style: AppTextStyles.paragraph.copyWith(height: 2)),
                      SizedBox(height: 12.h),
                      Text(AppText.deleteAccountBody2,
                          style: AppTextStyles.paragraph.copyWith(height: 2)),
                    ],
                  ),
                ),
                SizedBox(height: 26.h),
                PrimaryButton(
                  label: AppText.confirmDelete,
                  color: AppColors.danger,
                  fontSize: AppTextStyles.s16,
                  enabled: state is! AuthLoading,
                  onTap: () => _confirm(context),
                ),
                SizedBox(height: 12.h),
                OutlinedPillButton(
                  label: AppText.cancel,
                  height: 50,
                  borderColor: AppColors.textFaint,
                  textColor: AppColors.text,
                  fontSize: AppTextStyles.s16,
                  onTap: AppUtils.back,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// حذف الحساب لا رجعة فيه، فيسبقه سؤال صريح لا ضغطة واحدة.
  void _confirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(AppText.deleteAccountHeading, style: AppTextStyles.cardTitle),
        content: Text(
          'هل تريد إرسال طلب حذف الحساب؟ لا يمكن التراجع بعد اعتماده.',
          style: AppTextStyles.paragraph.copyWith(height: 1.8),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppText.cancel,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(DeleteAccountEvent());
            },
            child: Text(AppText.confirmDelete,
                style: AppTextStyles.body.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
