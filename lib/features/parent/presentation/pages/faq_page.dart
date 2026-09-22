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
import '../../data/models/school_model.dart';
import '../bloc/content/content_bloc.dart';
import 'main_shell.dart';

/// هـ7 الأسئلة الشائعة — كل سؤال قابل للفتح.
class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  /// السؤال المفتوح. واحد في كل مرة، فلا تطول الشاشة بفتح الجميع.
  int? _open;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<ContentBloc>()..add(GetFaqEvent()),
      child: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.faqTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: state is FaqLoadedState
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < state.items.length; i++) ...[
                        _card(state.items[i], i),
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

  Widget _card(FaqItem item, int index) {
    final open = _open == index;

    return AppCard(
      radius: 8,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      onTap: () => setState(() => _open = open ? null : index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.question,
                    style: AppTextStyles.cardTitle.copyWith(height: 1.5)),
              ),
              SizedBox(width: 10.w),
              Icon(
                open ? AppIcons.collapse : AppIcons.expand,
                size: 20.sp,
                color: AppColors.primaryDark,
              ),
            ],
          ),
          if (open) ...[
            SizedBox(height: 12.h),
            const Divider(color: AppColors.divider, height: 1),
            SizedBox(height: 12.h),
            Text(item.answer, style: AppTextStyles.paragraph.copyWith(height: 1.9)),
          ],
        ],
      ),
    );
  }
}
