import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/school_model.dart';
import '../../domain/entities/service_entities.dart';
import '../bloc/content/content_bloc.dart';
import 'main_shell.dart';

/// هـ8 من نحن / سياسة الخصوصية / الشروط والأحكام.
///
/// قالب واحد بثلاثة محتويات كما ينصّ التصميم، فلا ثلاث شاشات متطابقة.
class StaticContentPage extends StatelessWidget {
  const StaticContentPage({super.key, required this.kind});

  const StaticContentPage.about({super.key}) : kind = StaticPageKind.about;

  const StaticContentPage.privacy({super.key}) : kind = StaticPageKind.privacy;

  const StaticContentPage.terms({super.key}) : kind = StaticPageKind.terms;

  final StaticPageKind kind;

  /// العنوان يُشتقّ من النوع وقت البناء لا في المُنشئ: النصوص صارت تُقرأ حسب
  /// اللغة النشطة، وقراءتها في مُنشئٍ ثابت تُجمّدها على لغة أول بناء.
  String get title => switch (kind) {
        StaticPageKind.about => AppText.aboutTitle,
        StaticPageKind.privacy => AppText.privacyTitle,
        StaticPageKind.terms => AppText.termsTitle,
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc<ContentBloc>()..add(GetStaticPageEvent(kind: kind)),
      child: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          return ParentScaffold(
            title: title,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            bodyPadding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 32.h),
            body: state is StaticPageLoadedState
                ? _content(state.page)
                : state is ContentFailureState
                    ? _error(context, state)
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.h),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
          );
        },
      ),
    );
  }

  Widget _error(BuildContext context, ContentFailureState state) => Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 44.sp, color: AppColors.danger),
            SizedBox(height: 12.h),
            Text(
              state.failure.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            SizedBox(height: 18.h),
            ElevatedButton(
              onPressed: () => context
                  .read<ContentBloc>()
                  .add(GetStaticPageEvent(kind: kind)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(160.w, 44.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(AppText.retry),
            ),
          ],
        ),
      );

  Widget _content(StaticPage page) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${AppText.lastUpdated}${page.updatedAt} · الإصدار 1.0.0',
            style: AppTextStyles.captionFaint,
          ),
          SizedBox(height: 18.h),
          for (var i = 0; i < page.paragraphs.length; i++) ...[
            if (i > 0) SizedBox(height: 16.h),
            Text(page.paragraphs[i], style: AppTextStyles.paragraph),
          ],
        ],
      );
}
