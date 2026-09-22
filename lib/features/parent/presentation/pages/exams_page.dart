import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/exam_model.dart';
import '../bloc/exams/exams_bloc.dart';
import 'exam_details_page.dart';
import 'main_shell.dart';

/// لون بطاقة الاختبار بحسب قربه: الأحمر لما اقترب، ثم البرتقالي، ثم لون
/// الهوية لما بَعُد.
class ExamUrgency {
  const ExamUrgency(this.background, this.foreground);

  final Color background;
  final Color foreground;

  static ExamUrgency of(int daysAway) {
    if (daysAway <= 5) {
      return const ExamUrgency(AppColors.dangerSoft, AppColors.dangerText);
    }
    if (daysAway <= 7) {
      return const ExamUrgency(AppColors.warningDeep, AppColors.warning);
    }
    return const ExamUrgency(AppColors.primarySoft, AppColors.primaryDark);
  }
}

/// د1 مواعيد الاختبارات — أي موعد يفتح تفاصيله.
class ExamsPage extends StatelessWidget {
  const ExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) => bloc<ExamsBloc>()..add(GetExamsEvent(studentId: studentId)),
      child: BlocBuilder<ExamsBloc, ExamsState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.examsTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: state is ExamsLoadedState
                ? _content(state.exams)
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _content(List<Exam> exams) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldHint(AppText.examsHint),
          SizedBox(height: 14.h),
          for (final exam in exams) ...[
            _card(exam),
            SizedBox(height: 12.h),
          ],
        ],
      );

  Widget _card(Exam exam) {
    final urgency = ExamUrgency.of(exam.daysAway);

    return AppCard(
      radius: 8,
      onTap: () => AppUtils.go(ExamDetailsPage(examId: exam.id)),
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: urgency.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(exam.dayNumber,
                    style: TextStyle(
                      fontSize: AppTextStyles.s18,
                      fontWeight: FontWeight.w700,
                      color: urgency.foreground,
                    )),
                Text(exam.monthName,
                    style: TextStyle(
                      fontSize: AppTextStyles.s10,
                      fontWeight: FontWeight.w500,
                      color: urgency.foreground,
                    )),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.subject, style: AppTextStyles.cardTitle),
                SizedBox(height: 7.h),
                Text(exam.timeLabel, style: AppTextStyles.caption),
                SizedBox(height: 7.h),
                Text(exam.place, style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            children: [
              StatusPill(
                label: exam.countdownLabel,
                background: urgency.background,
                foreground: urgency.foreground,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 8.h),
              Icon(AppIcons.chevron, size: 16.sp, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}
