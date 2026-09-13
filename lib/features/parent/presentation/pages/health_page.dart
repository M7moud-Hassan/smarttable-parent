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
import '../bloc/health/health_bloc.dart';
import 'main_shell.dart';

/// ج5 الحالة الصحية — أمراض مزمنة، تعليمات للمدرسة، وتقرير طبي مرفق.
class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final _instructions = TextEditingController();

  /// النص يُملأ مرة واحدة من الخادم؛ إعادة ملئه في كل بناء تُقفز المؤشّر إلى
  /// أول الحقل مع كل حرف.
  bool _instructionsLoaded = false;

  @override
  void dispose() {
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) => bloc<HealthBloc>()..add(GetHealthEvent(studentId: studentId)),
      child: BlocConsumer<HealthBloc, HealthState>(
        listener: (context, state) {
          if (state is HealthSavedState) {
            AppUtils.showCustomSnackbar(AppText.healthSaved, SnackType.SUCESS);
          } else if (state is HealthFailureState) {
            AppUtils.showCustomSnackbar(state.failure.message, SnackType.FAILURE);
          } else if (state is HealthFormState && !_instructionsLoaded) {
            _instructionsLoaded = true;
            _instructions.text = state.record.instructions;
          }
        },
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.healthTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: state is HealthFormState
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

  Widget _form(BuildContext context, HealthFormState state, String studentId) {
    final bloc = context.read<HealthBloc>();
    final record = state.record;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoBanner(message: AppText.healthPrivacy),
        SizedBox(height: 22.h),
        FieldLabel(AppText.chronicDiseases),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final disease in record.available)
              ChoicePill(
                label: disease,
                selected: record.selected.contains(disease),
                onTap: () => bloc.add(ToggleDiseaseEvent(disease: disease)),
              ),
          ],
        ),
        SizedBox(height: 22.h),
        FieldLabel(AppText.schoolInstructions),
        SizedBox(height: 12.h),
        AppTextArea(
          controller: _instructions,
          hint: AppText.healthInstructionsHint,
          height: 110,
          onChanged: (value) => bloc.add(ChangeInstructionsEvent(instructions: value)),
        ),
        SizedBox(height: 22.h),
        FieldLabel(AppText.medicalReport),
        SizedBox(height: 12.h),
        _reportButton(context, record.reportName),
        SizedBox(height: 28.h),
        PrimaryButton(
          label: AppText.saveHealth,
          onTap: () => bloc.add(SaveHealthEvent(studentId: studentId)),
        ),
      ],
    );
  }

  Widget _reportButton(BuildContext context, String? reportName) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final picked = await FilePicker.platform.pickFiles();
          final path = picked?.files.single.path;
          if (path != null && context.mounted) {
            context.read<HealthBloc>().add(AttachMedicalReportEvent(path: path));
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
              Icon(
                reportName == null ? AppIcons.attach : AppIcons.pdf,
                size: 16.sp,
                color: AppColors.primaryDark,
              ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  reportName == null
                      ? AppText.attachFile
                      : '$reportName${AppText.attachedSuffix}',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
              ),
            ],
          ),
        ),
      );
}
