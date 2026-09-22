import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/enums/snack_bar_type_enum.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/school_model.dart';
import '../bloc/content/content_bloc.dart';
import '../widgets/contact_rows.dart';
import 'main_shell.dart';

/// هـ5 تواصل مع المدرسة.
class ContactSchoolPage extends StatelessWidget {
  const ContactSchoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) => bloc<ContentBloc>()..add(GetSchoolEvent(studentId: studentId)),
      child: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.contactSchoolTitle,
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: AppColors.primaryDeep,
              borderRadius: BorderRadius.circular(Dimensions.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.name,
                    style: TextStyle(
                      fontSize: AppTextStyles.s17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
                SizedBox(height: 8.h),
                Text(info.office,
                    style: TextStyle(
                      fontSize: AppTextStyles.s12,
                      color: const Color(0xE6FFFFFF),
                    )),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          for (final row in info.rows) ...[
            ContactRowCard(row: row),
            SizedBox(height: 12.h),
          ],
          SizedBox(height: 14.h),
          PrimaryButton(
            label: AppText.callSchool,
            icon: AppIcons.call,
            fontSize: AppTextStyles.s16,
            onTap: () => _call(info.phone),
          ),
        ],
      );

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      AppUtils.showCustomSnackbar('تعذّر بدء الاتصال.', SnackType.FAILURE);
    }
  }
}
