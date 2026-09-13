import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/share/widgets/student_avatar.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/student_model.dart';
import '../bloc/students/students_bloc.dart';
import 'main_shell.dart';

/// A7 اختيار الطالب — أي بطاقة تنقل إلى الرئيسية وتثبّت الطالب المختار.
class SelectStudentPage extends StatelessWidget {
  const SelectStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<StudentsBloc>()..add(GetStudentsEvent()),
      child: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.selectStudentTitle,
            onBack: AppUtils.back,
            showAvatarInHeader: false,
            bodyPadding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 32.h),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppText.yourChildren, style: AppTextStyles.screenTitle),
                SizedBox(height: 10.h),
                Text(AppText.selectStudentSubtitle, style: AppTextStyles.bodyMuted),
                SizedBox(height: 22.h),
                if (state is StudentsLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state is StudentsLoadedState)
                  for (final student in state.students) ...[
                    _card(context, student),
                    SizedBox(height: 16.h),
                  ],
                SizedBox(height: 8.h),
                InfoBanner(
                  message: AppText.missingChildHint,
                  background: AppColors.warningSoft,
                  foreground: AppColors.warning,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, Student student) {
    return AppCard(
      onTap: () {
        context.read<StudentsBloc>().add(SelectStudentEvent(student: student));
        AppUtils.goAndReplace(const MainShell());
      },
      child: Row(
        children: [
          StudentAvatar(name: student.name, photo: student.photo, size: 55),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTextStyles.cardTitle),
                SizedBox(height: 7.h),
                Text(student.classLabel, style: AppTextStyles.bodyMuted),
                SizedBox(height: 7.h),
                Text(
                  student.school,
                  style: TextStyle(
                    fontSize: AppTextStyles.s10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
                // الشارة تظهر فقط لمن عليه غياب بدون عذر، فلا يرى ولي الأمر
                // شارة فارغة على ابن منتظم.
                if (student.unexcusedAbsences > 0) ...[
                  SizedBox(height: 7.h),
                  StatusPill(
                    label: '${student.unexcusedAbsences} غياب بدون عذر',
                    background: AppColors.dangerSoft,
                    foreground: AppColors.dangerText,
                    height: 24,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(AppIcons.chevron, size: 18.sp, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
