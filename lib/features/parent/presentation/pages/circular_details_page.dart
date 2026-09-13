import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/circular_model.dart';
import '../bloc/circulars/circulars_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_shell.dart';

/// د4 تفاصيل التعميم — نصّه كاملاً، وزر تحميل نسخة PDF إن وُجدت.
class CircularDetailsPage extends StatelessWidget {
  const CircularDetailsPage({super.key, required this.circularId});

  final String circularId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          bloc<CircularsBloc>()..add(GetCircularDetailsEvent(circularId: circularId)),
      child: BlocBuilder<CircularsBloc, CircularsState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.circularTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: state is CircularDetailsLoadedState
                ? _content(state.circular)
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _content(Circular circular) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            circular.title,
            style: TextStyle(
              fontSize: AppTextStyles.s16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.6,
            ),
          ),
          SizedBox(height: 10.h),
          Text(circular.byline, style: AppTextStyles.captionFaint),
          SizedBox(height: 20.h),
          Text(circular.body, style: AppTextStyles.paragraph),
          if (circular.pdfUrl != null) ...[
            SizedBox(height: 28.h),
            PrimaryButton(
              label: AppText.downloadPdf,
              icon: AppIcons.download,
              fontSize: AppTextStyles.s16,
              onTap: () => _download(circular.pdfUrl!),
            ),
          ],
        ],
      );

  Future<void> _download(String url) async {
    final uri = Uri.tryParse(url);
    // تعذّر الفتح لا يصحّ أن يمرّ صامتاً: ولي الأمر ضغط الزر وينتظر شيئاً.
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppUtils.showCustomSnackbar('تعذّر فتح ملف التعميم.', SnackType.FAILURE);
    }
  }
}
