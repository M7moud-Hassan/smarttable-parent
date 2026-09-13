import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../data/models/behavior_model.dart';

/// تبويب «الإحصائية» في شاشة ج٤: ثلاثة أعداد، وشريط توزيع، ومخطّط أعمدة
/// لأربعة أسابيع.
class BehaviorStatisticsView extends StatelessWidget {
  const BehaviorStatisticsView({super.key, required this.statistics});

  final BehaviorStatistics statistics;

  static const Color _positive = AppColors.successStrong;
  static const Color _negative = AppColors.orange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _stat('${statistics.total}', AppText.total, AppColors.text),
            SizedBox(width: 10.w),
            _stat('${statistics.positive}', 'إيجابية', AppColors.success),
            SizedBox(width: 10.w),
            _stat('${statistics.needsWork}', 'بحاجة إلى تحسين', AppColors.warning),
          ],
        ),
        SizedBox(height: 22.h),
        SectionTitle(AppText.notesDistribution),
        SizedBox(height: 14.h),
        _distributionCard(),
        // «حسب المادة» و«حسب المعلم» مرفوعان: سجلّ السلوك لا يحفظ معلّم
        // الملاحظة، والمادة تُقرأ من جدول الفصل فتغيب حين لا يكون للفصل صفٌّ
        // فيه — فكانت البطاقتان تظهران فارغتين.
        SizedBox(height: 22.h),
        SectionTitle(AppText.fourWeekChange),
        SizedBox(height: 14.h),
        _weeksCard(),
      ],
    );
  }

  Widget _stat(String value, String label, Color color) => Expanded(
        child: AppCard(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                    fontSize: AppTextStyles.s20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
              SizedBox(height: 6.h),
              Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption),
            ],
          ),
        ),
      );

  Widget _distributionCard() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                height: 16.h,
                child: Row(
                  children: [
                    Expanded(
                      flex: statistics.positivePercent.clamp(0, 100),
                      child: Container(color: _positive),
                    ),
                    Expanded(
                      flex: statistics.needsWorkPercent.clamp(0, 100),
                      child: Container(color: _negative),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _legend(_positive, 'إيجابية', statistics.positivePercent),
                _legend(_negative, 'بحاجة إلى تحسين', statistics.needsWorkPercent),
              ],
            ),
          ],
        ),
      );

  Widget _legend(Color color, String label, int percent) => Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text('$label $percent%',
              style: TextStyle(fontSize: AppTextStyles.s10, color: AppColors.text)),
        ],
      );

  Widget _weeksCard() {
    final weeks = statistics.weeks;
    final max = weeks.fold<int>(1, (m, w) => w.total > m ? w.total : m);

    return AppCard(
      child: Column(
        children: [
          SizedBox(
            height: 104.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < weeks.length; i++) ...[
                  if (i > 0) SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${weeks[i].total}',
                            style: TextStyle(
                              fontSize: AppTextStyles.s10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            )),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: SizedBox(
                            height: (76 * weeks[i].total / max).h,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: weeks[i].needsWork,
                                  child:
                                      Container(width: double.infinity, color: _negative),
                                ),
                                Expanded(
                                  flex: weeks[i].positive,
                                  child:
                                      Container(width: double.infinity, color: _positive),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              for (var i = 0; i < weeks.length; i++) ...[
                if (i > 0) SizedBox(width: 12.w),
                Expanded(
                  child: Text(weeks[i].label,
                      textAlign: TextAlign.center, style: AppTextStyles.caption),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
