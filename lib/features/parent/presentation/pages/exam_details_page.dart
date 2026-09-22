import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/exam_model.dart';
import '../bloc/exams/exams_bloc.dart';
import 'main_shell.dart';

/// د2 تفاصيل الاختبار — محتوى حرّ يكتبه المعلم، فما من بند مضمون الوجود:
/// كل قسم يُخفى إن لم يرسل الخادم محتواه.
class ExamDetailsPage extends StatelessWidget {
  const ExamDetailsPage({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<ExamsBloc>()..add(GetExamDetailsEvent(examId: examId)),
      child: BlocBuilder<ExamsBloc, ExamsState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.examDetailsTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: state is ExamDetailsLoadedState
                ? _content(state.exam)
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _content(Exam exam) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _headerCard(exam),
          SizedBox(height: 16.h),
          _factsCard(exam),
          if (exam.details.isNotEmpty) ...[
            SizedBox(height: 22.h),
            SectionTitle(AppText.teacherWritten),
            SizedBox(height: 14.h),
            _detailsCard(exam),
          ],
          if (exam.topics.isNotEmpty) ...[
            SizedBox(height: 22.h),
            SectionTitle(AppText.examTopics),
            SizedBox(height: 14.h),
            _topicsCard(exam),
          ],
          if (exam.notes != null) ...[
            SizedBox(height: 22.h),
            SectionTitle(AppText.teacherNotes),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
              ),
              child:
                  Text(exam.notes!, style: AppTextStyles.paragraph.copyWith(height: 2)),
            ),
          ],
        ],
      );

  Widget _headerCard(Exam exam) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.primaryDeep,
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 26.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.pillRadius),
                border: Border.all(color: Colors.white, width: .5),
              ),
              child: Center(
                widthFactor: 1,
                child: Text(exam.countdownLabel,
                    style: AppTextStyles.badge.copyWith(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10.h),
            Text(exam.subject, style: AppTextStyles.screenTitleOnPrimary),
            SizedBox(height: 10.h),
            Text(exam.fullDate,
                style: TextStyle(
                  fontSize: AppTextStyles.s12,
                  color: const Color(0xEBFFFFFF),
                )),
          ],
        ),
      );

  Widget _factsCard(Exam exam) => AppCard(
        radius: 8,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          children: [
            _fact(AppText.time, exam.timeLabel),
            _separator(),
            _fact(AppText.place, exam.place),
            if (exam.teacher.isNotEmpty) ...[
              _separator(),
              _fact(AppText.subjectTeacher, exam.teacher),
            ],
          ],
        ),
      );

  Widget _fact(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: AppTextStyles.body),
          ),
        ],
      );

  Widget _separator() => Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: const Divider(color: AppColors.divider, height: 1),
      );

  Widget _detailsCard(Exam exam) => AppCard(
        radius: 8,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          children: [
            for (var i = 0; i < exam.details.length; i++) ...[
              if (i > 0) SizedBox(height: 12.h),
              Row(
                children: [
                  StatusPill(
                    label: exam.details[i].label,
                    background: AppColors.primarySoft,
                    foreground: AppColors.primaryDark,
                    height: 24,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(exam.details[i].value, style: AppTextStyles.body),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _topicsCard(Exam exam) => AppCard(
        radius: 8,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          children: [
            for (var i = 0; i < exam.topics.length; i++) ...[
              if (i > 0) SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.h),
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(exam.topics[i],
                        style: AppTextStyles.body.copyWith(height: 1.6)),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}
