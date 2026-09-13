import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/schedule_model.dart';
import '../bloc/schedule/schedule_bloc.dart';
import 'main_shell.dart';

/// ج1 الجدول المدرسي — أيام الأسبوع قابلة للتبديل، والحصة الجارية مميّزة.
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) =>
          bloc<ScheduleBloc>()..add(GetScheduleEvent(studentId: studentId)),
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.scheduleTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: state is ScheduleLoadedState
                ? _content(context, state)
                : state is ScheduleFailureState
                    ? Center(
                        child: Text(
                          state.failure.message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                      )
                    : _loading(),
          );
        },
      ),
    );
  }

  Widget _loading() => Padding(
        padding: EdgeInsets.symmetric(vertical: 80.h),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget _content(BuildContext context, ScheduleLoadedState state) {
    final day = state.selectedDay;
    final current = day?.currentLesson;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (current != null) _currentLessonCard(current, state.week),
        SizedBox(height: 20.h),
        Text(state.week.hijriMonth,
            style: TextStyle(
              fontSize: AppTextStyles.s12,
              fontWeight: FontWeight.w500,
              color: AppColors.info,
            )),
        SizedBox(height: 12.h),
        _daysRow(context, state),
        SizedBox(height: 18.h),
        if (day == null || day.lessons.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(AppText.noClassesToday,
                textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
          )
        else
          for (final lesson in day.lessons) ...[
            _lessonRow(lesson),
            SizedBox(height: 16.h),
          ],
      ],
    );
  }

  /// بطاقة «الحصة الحالية» بلون الهوية الغامق، وإلى جانبها عدّاد ما تبقّى منها.
  Widget _currentLessonCard(Lesson lesson, WeekSchedule week) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.cardRadius),
                      border: Border.all(color: Colors.white, width: .5),
                    ),
                    child: Text(
                      AppText.currentPeriodLabel,
                      style: TextStyle(
                        fontSize: AppTextStyles.s17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '${lesson.order} : ${lesson.subject}',
                    style: TextStyle(
                      fontSize: AppTextStyles.s14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 89.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.cardRadius),
                border: Border.all(color: Colors.white, width: .5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppText.remaining,
                      style: TextStyle(
                        fontSize: AppTextStyles.s17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      )),
                  SizedBox(height: 8.h),
                  Text(week.remainingInCurrentLesson,
                      style: TextStyle(
                        fontSize: AppTextStyles.s17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daysRow(BuildContext context, ScheduleLoadedState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final day in state.week.days)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.read<ScheduleBloc>().add(SelectDayEvent(dayId: day.id)),
            child: Column(
              children: [
                Text(
                  day.weekday,
                  style: TextStyle(
                    fontSize: AppTextStyles.s14,
                    fontWeight: FontWeight.w500,
                    color: day.id == state.selectedDayId
                        ? AppColors.primaryDark
                        : AppColors.info,
                  ),
                ),
                SizedBox(height: 11.h),
                Text(
                  day.dayNumber,
                  style: TextStyle(
                    fontSize: AppTextStyles.s14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: day.id == state.selectedDayId
                        ? AppColors.primaryDark
                        : AppColors.info,
                  ),
                ),
                SizedBox(height: 11.h),
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: day.id == state.selectedDayId
                        ? AppColors.primaryDark
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _lessonRow(Lesson lesson) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: lesson.isCurrent ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
        border: Border.all(
          color: lesson.isCurrent ? AppColors.primaryDark : AppColors.primary,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(lesson.order, style: AppTextStyles.label),
              SizedBox(height: 8.h),
              Text(
                lesson.timeRange,
                style:
                    AppTextStyles.label.copyWith(fontWeight: FontWeight.w300),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Text(lesson.subject, style: AppTextStyles.label),
                SizedBox(height: 8.h),
                Text(lesson.teacher, style: AppTextStyles.label),
              ],
            ),
          ),
          Opacity(
            opacity: .55,
            child: Icon(AppIcons.chevron, size: 18.sp, color: AppColors.text),
          ),
        ],
      ),
    );
  }
}
