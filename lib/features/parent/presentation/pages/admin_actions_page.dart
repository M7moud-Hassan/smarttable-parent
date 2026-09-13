import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/note_type.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/share/widgets/selectors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/admin_action_model.dart';
import '../bloc/actions/actions_bloc.dart';
import 'attendance_page.dart';
import 'behavior_page.dart';
import 'main_shell.dart';

/// د5 الإجراءات الإدارية.
///
/// لكل إجراء ملاحظة مرتبطة ورقم تكرارها، والضغط على الملاحظة ينقل إلى سجل
/// المواظبة أو تقرير السلوك بحسب مصدرها.
class AdminActionsPage extends StatelessWidget {
  const AdminActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) =>
          bloc<ActionsBloc>()..add(GetActionsEvent(studentId: studentId)),
      child: BlocConsumer<ActionsBloc, ActionsState>(
        listener: (context, state) {
          if (state is ActionRespondedState) {
            AppUtils.showCustomSnackbar(
              state.confirmedAttendance
                  ? AppText.attendanceConfirmed
                  : AppText.acknowledgeDone,
              SnackType.SUCESS,
            );
          } else if (state is ActionsFailureState) {
            AppUtils.showCustomSnackbar(
                state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.actionsTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: state is ActionsLoadedState
                ? _content(context, state)
                : state is ActionsFailureState
                    ? Center(
                        child: Text(
                          state.failure.message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.h),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, ActionsLoadedState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoBanner(message: AppText.actionsHint, lineHeight: 1.8),
          SizedBox(height: 20.h),
          SegmentedTabs(
            labels: [AppText.all, AppText.needsYourReview],
            selectedIndex: state.tab.index,
            onSelect: (index) => context
                .read<ActionsBloc>()
                .add(ChangeActionsTabEvent(tab: ActionsTab.values[index])),
          ),
          SizedBox(height: 14.h),
          if (state.visible.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              child: Text(
                AppText.noActions,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
            )
          else
            for (final action in state.visible) ...[
              _card(context, action),
              SizedBox(height: 12.h),
            ],
        ],
      );

  Widget _card(BuildContext context, AdminAction action) => AppCard(
        radius: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconTile(
                  icon: action.source == AdminActionSource.attendance
                      ? AppIcons.summons
                      : AppIcons.behavior,
                  background: action.source.background,
                  foreground: action.source.foreground,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.title,
                          style:
                              AppTextStyles.cardTitle.copyWith(height: 1.45)),
                      SizedBox(height: 7.h),
                      Text(action.byline, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                StatusPill(
                  label: action.source.label,
                  background: action.source.background,
                  foreground: action.source.foreground,
                  height: 24,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _linkedNote(action),
            SizedBox(height: 12.h),
            Opacity(
              opacity: .8,
              child: Text(action.body,
                  style: AppTextStyles.paragraph.copyWith(height: 1.8)),
            ),
            if (action.highlight != null) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius:
                      BorderRadius.circular(Dimensions.cardRadiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.deduction,
                        size: 16.sp, color: AppColors.dangerText),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        action.highlight!,
                        style: TextStyle(
                          fontSize: AppTextStyles.s12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dangerText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12.h),
            _statusPill(action),
            if (action.state != AdminActionState.seen) ...[
              SizedBox(height: 12.h),
              _responseButtons(context, action),
            ],
          ],
        ),
      );

  /// الملاحظة المرتبطة داخل لوح رمادي — الضغط عليها ينقل إلى مصدرها.
  Widget _linkedNote(AdminAction action) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => action.source == AdminActionSource.attendance
            ? AppUtils.go(const AttendancePage())
            : AppUtils.go(const BehaviorPage()),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppText.linkedNote, style: AppTextStyles.caption),
              SizedBox(height: 8.h),
              Text(action.linkedNote,
                  style: AppTextStyles.body.copyWith(height: 1.6)),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      action.occurrenceLabel,
                      style: TextStyle(
                        fontSize: AppTextStyles.s10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    action.source == AdminActionSource.attendance
                        ? AppText.viewAttendanceLog
                        : AppText.viewBehaviorReport,
                    style: TextStyle(
                      fontSize: AppTextStyles.s10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _statusPill(AdminAction action) {
    switch (action.state) {
      case AdminActionState.seen:
        return StatusPill(
          label: AppText.acknowledged,
          background: AppColors.successSoft,
          foreground: AppColors.success,
          fontWeight: FontWeight.w500,
        );
      case AdminActionState.needsAcknowledge:
        return StatusPill(
          label: AppText.needsYourReview,
          background: AppColors.dangerSoft,
          foreground: AppColors.dangerText,
          fontWeight: FontWeight.w500,
        );
      case AdminActionState.needsAttendance:
        return StatusPill(
          label: AppText.needsAttendanceConfirm,
          background: AppColors.dangerSoft,
          foreground: AppColors.dangerText,
          fontWeight: FontWeight.w500,
        );
    }
  }

  Widget _responseButtons(BuildContext context, AdminAction action) {
    final bloc = context.read<ActionsBloc>();

    if (action.state == AdminActionState.needsAttendance) {
      return Row(
        children: [
          Expanded(
            child: SmallPillButton(
              label: AppText.confirmAttendance,
              onTap: () => bloc.add(RespondToActionEvent(
                  actionId: action.id, confirmAttendance: true)),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: SmallPillButton(
              label: AppText.requestReschedule,
              filled: false,
              color: AppColors.textFaint,
              textColor: AppColors.text,
              onTap: () => AppUtils.showCustomSnackbar(
                'أُرسل طلب تغيير الموعد إلى الإدارة.',
                SnackType.SUCESS,
              ),
            ),
          ),
        ],
      );
    }

    return SmallPillButton(
      label: AppText.acknowledged,
      height: 34,
      onTap: () => bloc.add(
          RespondToActionEvent(actionId: action.id, confirmAttendance: false)),
    );
  }
}
