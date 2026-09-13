import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/inputs/app_text_field.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/share/widgets/selectors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../bloc/excuse/excuse_bloc.dart';
import 'main_shell.dart';

/// ج3 عذر غياب — اختيار أيام الفترة، السبب، ملاحظة، ومرفق.
class ExcusePage extends StatefulWidget {
  const ExcusePage({super.key, required this.periodId});

  final String periodId;

  @override
  State<ExcusePage> createState() => _ExcusePageState();
}

class _ExcusePageState extends State<ExcusePage> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) =>
          bloc<ExcuseBloc>()..add(GetAbsencePeriodEvent(periodId: widget.periodId)),
      child: BlocConsumer<ExcuseBloc, ExcuseState>(
        listener: (context, state) {
          if (state is ExcuseSubmittedState) {
            AppUtils.showCustomSnackbar(AppText.excuseSent, SnackType.SUCESS);
            AppUtils.back();
          } else if (state is ExcuseFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.excuseTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: state is ExcuseFormState
                ? _form(context, state, studentId)
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _form(BuildContext context, ExcuseFormState state, String studentId) {
    final bloc = context.read<ExcuseBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoBanner(
          message: '${AppText.absencePeriod}${state.period.detail}',
          background: AppColors.dangerSoft,
          foreground: AppColors.warning,
        ),
        SizedBox(height: 22.h),
        FieldLabel(AppText.coveredDays),
        SizedBox(height: 6.h),
        FieldHint(AppText.coveredDaysHint),
        SizedBox(height: 12.h),
        for (final day in state.days) ...[
          CheckRow(
            label: day.label,
            checked: day.selected,
            onTap: () => bloc.add(ToggleExcuseDayEvent(dayId: day.id)),
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 2.h),
        Text(
          state.selectionLabel,
          style: TextStyle(
            fontSize: AppTextStyles.s12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        // التنبيه لا يظهر إلا حين يُستثنى يوم من وسط الفترة، فيبقى بلا عذر
        // بين يومين معذورين.
        if (state.hasGap) ...[
          SizedBox(height: 6.h),
          Text(
            AppText.gapWarning,
            style: AppTextStyles.captionFaint.copyWith(color: AppColors.warning),
          ),
        ],
        SizedBox(height: 22.h),
        FieldLabel(AppText.absenceReason),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final reason in state.reasons)
              ChoicePill(
                label: reason,
                selected: state.reason == reason,
                onTap: () => bloc.add(SelectExcuseReasonEvent(reason: reason)),
              ),
          ],
        ),
        SizedBox(height: 22.h),
        FieldLabel(AppText.parentNote),
        SizedBox(height: 12.h),
        AppTextArea(
          controller: _note,
          hint: AppText.excuseNoteHint,
          onChanged: (value) => bloc.add(ChangeExcuseNoteEvent(note: value)),
        ),
        SizedBox(height: 22.h),
        FieldLabel(AppText.attachment),
        SizedBox(height: 12.h),
        _attachButton(context, state),
        SizedBox(height: 28.h),
        PrimaryButton(
          label: AppText.sendExcuse,
          enabled: state.canSubmit,
          onTap: () => bloc.add(SubmitExcuseEvent(studentId: studentId)),
        ),
        SizedBox(height: 14.h),
        Text(
          AppText.excuseReviewHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.captionFaint,
        ),
      ],
    );
  }

  Widget _attachButton(BuildContext context, ExcuseFormState state) {
    final name = state.attachment?.split(RegExp(r'[\\/]')).last;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final picked = await FilePicker.platform.pickFiles();
        final path = picked?.files.single.path;
        if (path != null && context.mounted) {
          context.read<ExcuseBloc>().add(AttachExcuseFileEvent(path: path));
        }
      },
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
          border: Border.all(color: AppColors.primaryLight),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.attach, size: 16.sp, color: AppColors.primaryDark),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                name == null ? AppText.attachFile : '$name${AppText.attachedSuffix}',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
