import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/note_type.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/share/widgets/selectors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/behavior_model.dart';
import '../../domain/entities/service_entities.dart';
import '../bloc/behavior/behavior_bloc.dart';
import '../widgets/behavior_statistics_view.dart';
import 'main_shell.dart';

/// ج4 تقرير السلوك — تبويبا الملاحظات والإحصائية، وتصفية بأربعة محاور.
class BehaviorPage extends StatelessWidget {
  const BehaviorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) => bloc<BehaviorBloc>()
        ..add(GetBehaviorEvent(filter: BehaviorFilterEntity(studentId: studentId))),
      child: BlocBuilder<BehaviorBloc, BehaviorState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.behaviorTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: state is BehaviorLoadedState
                ? _content(context, state)
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, BehaviorLoadedState state) {
    final bloc = context.read<BehaviorBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedTabs(
          labels: [AppText.tabNotes, AppText.tabStatistics],
          selectedIndex: state.tab.index,
          onSelect: (index) => bloc.add(
            ChangeBehaviorTabEvent(tab: BehaviorTab.values[index]),
          ),
        ),
        SizedBox(height: 20.h),
        _periodFilter(bloc, state.filter),
        if (state.tab == BehaviorTab.notes) ...[
          SizedBox(height: 18.h),
          _typeFilter(bloc, state.filter),
          // فلترا المادة والمعلم مرفوعان: سجلّ السلوك لا يحفظ معلّم الملاحظة،
          // والمادة تُقرأ من جدول الفصل فتغيب حين لا يكون للفصل صفٌّ فيه.
          // فكان الفلتران يعرضان «الكل» وحده بلا خيارٍ ثانٍ.
          SizedBox(height: 22.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.countLabel,
                  style: TextStyle(
                    fontSize: AppTextStyles.s12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  )),
              // زر إلغاء التصفية لا يظهر إلا حين تكون هناك تصفية فعلاً.
              if (state.filter.hasActiveFilter)
                TextLinkButton(
                  label: AppText.clearFilters,
                  onTap: () => bloc.add(GetBehaviorEvent(
                    filter: BehaviorFilterEntity(studentId: state.filter.studentId),
                  )),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          if (state.report.notes.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Text(
                AppText.noMatchingNotes,
                style: TextStyle(
                  fontSize: AppTextStyles.s12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            for (final note in state.report.notes) ...[
              _noteCard(note),
              SizedBox(height: 12.h),
            ],
        ] else ...[
          SizedBox(height: 20.h),
          BehaviorStatisticsView(statistics: state.report.statistics),
        ],
      ],
    );
  }

  Widget _periodFilter(BehaviorBloc bloc, BehaviorFilterEntity filter) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(AppText.period),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (final period in BehaviorPeriod.values) ...[
                if (period != BehaviorPeriod.values.first) SizedBox(width: 8.w),
                Expanded(
                  child: ChoicePill(
                    label: period.label,
                    selected: filter.period == period,
                    onTap: () => bloc
                        .add(GetBehaviorEvent(filter: filter.copyWith(period: period))),
                  ),
                ),
              ],
            ],
          ),
        ],
      );

  Widget _typeFilter(BehaviorBloc bloc, BehaviorFilterEntity filter) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(AppText.noteType),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ChoicePill(
                label: AppText.all,
                selected: filter.type == null,
                height: 34,
                onTap: () =>
                    bloc.add(GetBehaviorEvent(filter: filter.copyWith(clearType: true))),
              ),
              for (final type in BehaviorNoteType.values)
                ChoicePill(
                  label: type.label,
                  selected: filter.type == type,
                  height: 34,
                  onTap: () =>
                      bloc.add(GetBehaviorEvent(filter: filter.copyWith(type: type))),
                ),
            ],
          ),
        ],
      );

  Widget _noteCard(BehaviorNote note) => AppCard(
        radius: 8,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: note.type.background,
                borderRadius: BorderRadius.circular(5.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                note.type == BehaviorNoteType.positive
                    ? Icons.thumb_up_outlined
                    : Icons.error_outline,
                size: 20.sp,
                color: note.type.foreground,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusPill(
                        label: note.type.label,
                        background: note.type.background,
                        foreground: note.type.foreground,
                      ),
                      Text(note.date, style: AppTextStyles.captionFaint),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(note.body, style: AppTextStyles.cardTitle.copyWith(height: 1.5)),
                  SizedBox(height: 10.h),
                  Text(note.byline, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      );
}
