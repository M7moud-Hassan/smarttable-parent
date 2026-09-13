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
import '../../data/models/circular_model.dart';
import '../bloc/circulars/circulars_bloc.dart';
import 'circular_details_page.dart';
import 'main_shell.dart';

/// د3 التعاميم الإدارية — أي تعميم يفتح نصّه.
class CircularsPage extends StatelessWidget {
  const CircularsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) => bloc<CircularsBloc>()..add(GetCircularsEvent(studentId: studentId)),
      child: BlocBuilder<CircularsBloc, CircularsState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.circularsTitle,
            onBack: AppUtils.back,
            showBottomNav: true,
            onTabSelected: MainShell.openTab,
            body: state is CircularsLoadedState
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final circular in state.circulars) ...[
                        _card(circular),
                        SizedBox(height: 12.h),
                      ],
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }

  Widget _card(Circular circular) => AppCard(
        radius: 8,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        onTap: () => AppUtils.go(CircularDetailsPage(circularId: circular.id)),
        child: Row(
          children: [
            const IconTile(
              icon: AppIcons.circulars,
              background: AppColors.primarySoft,
              foreground: AppColors.primaryDark,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(circular.title,
                      style: AppTextStyles.cardTitle.copyWith(height: 1.45)),
                  SizedBox(height: 7.h),
                  Text(circular.date, style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(AppIcons.chevron, size: 18.sp, color: AppColors.primaryDark),
          ],
        ),
      );
}
