import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/school_model.dart';
import '../bloc/content/content_bloc.dart';
import '../widgets/contact_rows.dart';
import 'main_shell.dart';

/// هـ6 الدعم الفني — للمشكلات التقنية في التطبيق فقط.
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<ContentBloc>()..add(GetSupportEvent()),
      child: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.supportTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: state is SchoolLoadedState
                ? _content(state.info)
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _content(SchoolInfo info) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoBanner(message: AppText.supportScope),
          SizedBox(height: 18.h),
          for (final row in info.rows) ...[
            ContactRowCard(row: row),
            SizedBox(height: 12.h),
          ],
          SizedBox(height: 14.h),
          PrimaryButton(
            label: AppText.openSupportChat,
            fontSize: AppTextStyles.s16,
            onTap: () => _chat(info.phone),
          ),
        ],
      );

  Future<void> _chat(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      AppUtils.showCustomSnackbar('تعذّر فتح قناة الدعم.', SnackType.FAILURE);
    }
  }
}
