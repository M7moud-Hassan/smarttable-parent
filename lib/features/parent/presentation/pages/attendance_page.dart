import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/attendance_status.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/attendance_model.dart';
import '../bloc/attendance/attendance_bloc.dart';
import 'excuse_page.dart';
import 'main_shell.dart';

/// ج2 تقرير المواظبة — أيام الغياب المتصلة مجموعة في فترة واحدة.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) =>
          bloc<AttendanceBloc>()..add(GetAttendanceEvent(studentId: studentId)),
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.attendanceTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: state is AttendanceLoadedState
                ? _content(context, state.report, studentId)
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, AttendanceReport report, String studentId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _summaryCard(report),
        if (report.warning != null) ...[
          SizedBox(height: 16.h),
          InfoBanner(
            message: report.warning!,
            icon: AppIcons.warning,
            background: AppColors.dangerSoft,
            foreground: AppColors.warning,
            lineHeight: 1.6,
          ),
        ],
        SizedBox(height: 22.h),
        SectionTitle(AppText.attendanceLog),
        SizedBox(height: 6.h),
        FieldHint(AppText.attendanceLogHint),
        SizedBox(height: 14.h),
        for (final entry in report.entries) ...[
          _entryCard(context, entry, studentId),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _summaryCard(AttendanceReport report) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(report.termLabel,
                  style: TextStyle(
                    fontSize: AppTextStyles.s12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  )),
              Text('${report.percentage}%',
                  style: TextStyle(
                    fontSize: AppTextStyles.s20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successStrong,
                  )),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: report.percentage / 100,
              minHeight: 8.h,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successStrong),
            ),
          ),
          SizedBox(height: 16.h),
          IntrinsicHeight(
            child: Row(
              children: [
                _stat('${report.presentDays}', AppText.daysPresent, AppColors.text),
                const VerticalDivider(color: AppColors.border, width: 1),
                _stat('${report.lateDays}', AppText.daysLate, AppColors.warningIcon),
                const VerticalDivider(color: AppColors.border, width: 1),
                _stat('${report.absentDays}', AppText.daysAbsent, AppColors.danger),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: AppTextStyles.s16,
                  fontWeight: FontWeight.w600,
                  color: color,
                )),
            SizedBox(height: 6.h),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      );

  Widget _entryCard(BuildContext context, AttendanceEntry entry, String studentId) {
    return AppCard(
      radius: 8,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: AppTextStyles.cardTitle),
                    SizedBox(height: 7.h),
                    Text(
                      entry.status.label,
                      style: TextStyle(
                        fontSize: AppTextStyles.s12,
                        fontWeight: FontWeight.w500,
                        color: entry.status.color,
                      ),
                    ),
                    SizedBox(height: 7.h),
                    Text(entry.detail,
                        style: AppTextStyles.caption.copyWith(height: 1.6)),
                  ],
                ),
              ),
              // شارة عدد الأيام تخصّ الفترات المتصلة وحدها؛ اليوم المفرد لا
              // يحمل «1 أيام».
              if (entry.days.length > 1) ...[
                SizedBox(width: 10.w),
                StatusPill(
                  label: '${entry.dayCount} أيام',
                  background: AppColors.dangerSoft,
                  foreground: AppColors.dangerText,
                ),
              ],
            ],
          ),
          if (entry.excuseStatus != ExcuseStatus.none) ...[
            SizedBox(height: 12.h),
            StatusPill(
              label: entry.excuseStatus.label!,
              background: entry.excuseStatus.background!,
              foreground: entry.excuseStatus.foreground!,
              height: 28,
              fontWeight: FontWeight.w500,
            ),
          ],
          if (entry.canSubmitExcuse) ...[
            SizedBox(height: 12.h),
            SmallPillButton(
              label: AppText.submitExcuseForPeriod,
              height: 34,
              onTap: () async {
                await AppUtils.goWait(ExcusePage(periodId: entry.id));
                if (context.mounted) {
                  context
                      .read<AttendanceBloc>()
                      .add(GetAttendanceEvent(studentId: studentId));
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
