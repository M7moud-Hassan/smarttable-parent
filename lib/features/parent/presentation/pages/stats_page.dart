import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/share/widgets/selectors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/stats_model.dart';
import '../../domain/entities/service_entities.dart';
import '../bloc/stats/stats_bloc.dart';
import 'main_shell.dart';

/// «إحصاءات ابني» — حصيلة كل ما سجّلته المدرسة عن الطالب في مدى واحد.
///
/// الشاشة لا تحسب شيئاً: كل رقم فيها يصل محسوباً من الخادم بالدالّة التي
/// تحسبه بها شاشة المدرسة نفسها، وكل تقدير ولافتة وجملة تصل نصّاً. فما يراه
/// وليّ الأمر هنا هو ما يراه وكيل المدرسة في كشفه، وهو شرط أن يُسأل عنه.
///
/// وتبديل المدى يعيد النداء ولا يُصفّي ما في اليد، للسبب نفسه.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = AppUtils.selectedStudent?.id ?? '';

    return BlocProvider(
      create: (_) => bloc<StatsBloc>()
        ..add(GetStatsEvent(filter: StatsFilterEntity(studentId: studentId))),
      child: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          return ParentScaffold(
            title: AppText.statsTitle,
            onBack: AppUtils.back,
            showBottomNav: false,
            onTabSelected: MainShell.openTab,
            body: state is StatsLoadedState
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

  Widget _content(BuildContext context, StatsLoadedState state) {
    final stats = state.stats;
    final bloc = context.read<StatsBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _periods(stats.period, state.filter, (key) {
          bloc.add(
              GetStatsEvent(filter: state.filter.copyWith(periodKey: key)));
        }),
        SizedBox(height: 10.h),
        FieldHint(stats.period.label),
        SizedBox(height: 16.h),
        _headline(stats.headline),
        if (stats.highlights.isNotEmpty) ...[
          SizedBox(height: 18.h),
          InfoBanner(
            message: stats.highlights.join('\n'),
            icon: AppIcons.info,
          ),
        ],
        SizedBox(height: 24.h),
        _attendance(stats.attendance),
        SizedBox(height: 24.h),
        _perseverance(stats.perseverance),
        SizedBox(height: 24.h),
        _behavior(stats.behavior),
        SizedBox(height: 24.h),
        _participation(stats.participation),
        SizedBox(height: 24.h),
        _excuses(stats.excuses),
        SizedBox(height: 24.h),
        _procedures(stats.procedures),
        SizedBox(height: 24.h),
        _health(stats.health),
        SizedBox(height: 24.h),
        _exams(stats.exams),
        SizedBox(height: 24.h),
      ],
    );
  }

  // ─── المدى ───────────────────────────────────────────────────────────────

  /// شرائح المدى — لافتاتها ومفاتيحها من الخادم، فلا تُعدّ هنا قائمةٌ ثانية
  /// تحتاج تعديل التطبيق كلّما أضافت المدرسة مدى.
  Widget _periods(
    StatsPeriod period,
    StatsFilterEntity filter,
    ValueChanged<String> onSelect,
  ) =>
      Row(
        children: [
          for (var i = 0; i < period.options.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            Expanded(
              child: ChoicePill(
                label: period.options[i].label,
                selected: period.options[i].key == filter.periodKey,
                onTap: () => onSelect(period.options[i].key),
              ),
            ),
          ],
        ],
      );

  // ─── البطاقات الأربع ─────────────────────────────────────────────────────

  /// صفّان من بطاقتين. القيمة نصٌّ لأن بطاقة السلوك تحمل تقديراً لا رقماً،
  /// واللون يأتي من `tone` الذي قرّره الخادم: حدُّ «الحضور ضعيف» يُقال مرةً
  /// واحدة في موضع واحد، لا هنا وهناك.
  Widget _headline(List<HeadlineStat> cards) => Column(
        children: [
          for (var i = 0; i < cards.length; i += 2) ...[
            if (i > 0) SizedBox(height: 10.h),
            // البطاقتان متساويتا الارتفاع وإن قصر تلميح إحداهما، و`stretch`
            // وحده يطلب ارتفاعاً لا نهائياً داخل قائمةٍ تمرّر.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _headlineCard(cards[i])),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: i + 1 < cards.length
                        ? _headlineCard(cards[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ],
      );

  Widget _headlineCard(HeadlineStat card) {
    final color = _toneColor(card.tone);
    // وحدةٌ كـ«يوم» أو «من 100» كلمةٌ تالية للرقم، أما «٪» فتلتصق به: لو
    // عُوملت كلمةً لقرأها الوالد «92.1 %» هنا و«92.1%» في شريط النسبة تحتها.
    final percent = card.unit == '%';
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title, style: AppTextStyles.caption),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  percent ? '${card.value}%' : card.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTextStyles.s20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              if (card.unit.isNotEmpty && !percent) ...[
                SizedBox(width: 4.w),
                Text(card.unit, style: AppTextStyles.captionFaint),
              ],
            ],
          ),
          if (card.hint.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(card.hint, style: AppTextStyles.captionFaint),
          ],
        ],
      ),
    );
  }

  static Color _toneColor(String tone) {
    switch (tone) {
      case 'bad':
        return AppColors.danger;
      case 'warn':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  // ─── المواظبة ────────────────────────────────────────────────────────────

  Widget _attendance(AttendanceStats attendance) {
    final weekdays = attendance.byWeekday;
    final worstWeekday = weekdays.fold<int>(
      0,
      (m, row) => row.absent + row.late > m ? row.absent + row.late : m,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(AppText.statsAttendance),
        SizedBox(height: 14.h),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rateBar(attendance.rate, attendance.classAverageRate),
              SizedBox(height: 18.h),
              // «غائب» و«متأخر» عنوانان جامعان لا عمودا رقم: من يقرأ ٥ ثم ٣
              // و٢ تحتها يجمع الثلاثة ويقرأ غياباً عشرة أيام. فيُكتب الجامع
              // عنواناً وتُكتب أجزاؤه وحدها.
              _plainRow(AppText.statsPresent, '${attendance.present}'),
              _splitRow(AppText.statsAbsent, [
                _Part(AppText.statsFullDay, '${attendance.absence.fullDay}'),
                _Part(
                  AppText.statsSessionDays,
                  '${attendance.absence.sessionDays}'
                  ' (${attendance.absence.sessions} ${AppText.statsSessionsUnit})',
                ),
              ]),
              _splitRow(AppText.statsLate, [
                _Part(
                    AppText.statsMorning, '${attendance.lateness.morningDays}'),
                _Part(
                  AppText.statsSessionDays,
                  '${attendance.lateness.sessionDays}'
                  ' (${attendance.lateness.sessions} ${AppText.statsSessionsUnit})',
                ),
              ]),
              _plainRow(AppText.statsPermission, '${attendance.permission}'),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: _miniStat(
                      AppText.statsExcused,
                      '${attendance.excusedDays}',
                      AppColors.success,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _miniStat(
                      AppText.statsUnexcused,
                      '${attendance.unexcusedDays}',
                      AppColors.danger,
                    ),
                  ),
                ],
              ),
              if (attendance.longestAbsence != null) ...[
                SizedBox(height: 14.h),
                _longestAbsence(attendance.longestAbsence!),
              ],
            ],
          ),
        ),
        if (weekdays.isNotEmpty) ...[
          SizedBox(height: 18.h),
          SectionTitle(AppText.statsByWeekday),
          SizedBox(height: 14.h),
          AppCard(
            child: Column(
              children: [
                for (final row in weekdays)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _weekdayRow(row, worstWeekday),
                  ),
                _legendRow(const [
                  _LegendItem(AppColors.danger, null),
                  _LegendItem(AppColors.warning, null),
                ], [
                  AppText.statsAbsent,
                  AppText.statsLate,
                ]),
              ],
            ),
          ),
        ],
        if (attendance.months.length > 1) ...[
          SizedBox(height: 18.h),
          SectionTitle(AppText.statsByMonth),
          SizedBox(height: 14.h),
          AppCard(
            child: Column(
              children: [
                for (final month in attendance.months)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(month.label, style: AppTextStyles.body),
                            Text(
                              '${_trim(month.rate)}%',
                              style: TextStyle(
                                fontSize: AppTextStyles.s12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        _bar(month.rate),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// نسبة الحضور، وتحتها متوسّط الفصل حين يكون للطالب فصل: الرقم وحده لا
  /// يقول إن ٩٢٪ جيّدة في هذا الفصل أم دون زملائه.
  Widget _rateBar(double rate, double? classAverage) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppText.statsRate, style: AppTextStyles.body),
              Text(
                '${_trim(rate)}%',
                style: TextStyle(
                  fontSize: AppTextStyles.s18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _bar(rate),
          if (classAverage != null) ...[
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppText.statsClassAverage,
                    style: AppTextStyles.captionFaint),
                Text('${_trim(classAverage)}%', style: AppTextStyles.caption),
              ],
            ),
          ],
        ],
      );

  Widget _bar(double percent) => ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          height: 10.h,
          child: Row(
            children: [
              Expanded(
                flex: percent.round().clamp(0, 100),
                child: Container(color: AppColors.primary),
              ),
              Expanded(
                flex: (100 - percent.round()).clamp(0, 100),
                child: Container(color: AppColors.fill),
              ),
            ],
          ),
        ),
      );

  Widget _plainRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTextStyles.s14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      );

  Widget _splitRow(String label, List<_Part> parts) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: AppTextStyles.body),
            SizedBox(height: 6.h),
            for (final part in parts)
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 14.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(part.label, style: AppTextStyles.captionFaint),
                    Text(part.value, style: AppTextStyles.caption),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _miniStat(String label, String value, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: AppTextStyles.s16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(label,
                textAlign: TextAlign.center, style: AppTextStyles.captionFaint),
          ],
        ),
      );

  Widget _longestAbsence(AbsenceStreak streak) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(AppIcons.absence, size: 18.sp, color: AppColors.warning),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '${AppText.statsLongestAbsence}: ${_days(streak.days)}'
                ' (${streak.fromHijri} — ${streak.toHijri})',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      );

  Widget _weekdayRow(WeekdayRow row, int worst) {
    final total = row.absent + row.late;
    return Row(
      children: [
        SizedBox(
          width: 56.w,
          child: Text(row.day, style: AppTextStyles.caption),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 10.h,
              child: Row(
                children: [
                  Expanded(
                      flex: row.absent,
                      child: Container(color: AppColors.danger)),
                  Expanded(
                      flex: row.late,
                      child: Container(color: AppColors.warning)),
                  Expanded(
                    flex: (worst - total).clamp(0, 1000),
                    child: Container(color: AppColors.fill),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 28.w,
          child: Text(
            '$total',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }

  // ─── درجة المواظبة ───────────────────────────────────────────────────────

  /// الدرجة ومصدر كل حسم. ولا يُطبع المجموع هنا: هو في بطاقة الصدارة، ولو
  /// جلس إلى جانب تفصيله لجُمع معه.
  Widget _perseverance(PerseveranceStats perseverance) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(AppText.statsPerseverance),
          SizedBox(height: 14.h),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // اللافتة تأتي من الخادم وقد تطول («الفصل الدراسي الجاري»)،
                    // فتُعطى ما يفيض عن الدرجة وتلتفّ عند الضيق بدل أن تدفعها.
                    Expanded(
                      child: Text(perseverance.scope,
                          style: AppTextStyles.captionFaint),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${perseverance.grade} / 100',
                      // بغير اتجاهٍ صريح تنعكس «٨٦ / ١٠٠» إلى «١٠٠ / ٨٦»:
                      // المسافتان حول الشرطة محايدتان فتأخذان اتجاه الفقرة.
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: AppTextStyles.s18,
                        fontWeight: FontWeight.w700,
                        color: _toneColor(
                          perseverance.grade >= 90
                              ? 'good'
                              : perseverance.grade >= 75
                                  ? 'warn'
                                  : 'bad',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _bar(perseverance.grade.toDouble()),
                if (perseverance.rows.isEmpty) ...[
                  SizedBox(height: 14.h),
                  Text(AppText.statsNoDeductions,
                      style: AppTextStyles.captionFaint),
                ] else ...[
                  SizedBox(height: 16.h),
                  FieldLabel(AppText.statsDeductions),
                  SizedBox(height: 8.h),
                  for (final row in perseverance.rows)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${row.label} × ${row.occurrences}',
                              style: AppTextStyles.caption,
                            ),
                          ),
                          Text(
                            '− ${row.deducted}',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: AppTextStyles.s12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      );

  // ─── السلوك ──────────────────────────────────────────────────────────────

  Widget _behavior(BehaviorStats behavior) {
    final positive = behavior.positive;
    final negative = behavior.negative;
    final months = behavior.months;
    final maxMonth = months.fold<int>(1, (m, x) => x.total > m ? x.total : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          AppText.statsBehavior,
          trailing: StatusPill(
            label: behavior.band,
            background: AppColors.primarySoft,
            foreground: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 14.h),
        AppCard(
          child: behavior.notes == 0
              ? Text(AppText.statsNoNotes, style: AppTextStyles.captionFaint)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: SizedBox(
                        height: 14.h,
                        child: Row(
                          children: [
                            Expanded(
                              flex: positive,
                              child: Container(color: AppColors.successStrong),
                            ),
                            Expanded(
                              flex: negative,
                              child: Container(color: AppColors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // طرفا الشريط على طرفَي السطر ما وسعهما، وإلا نزل ثانيهما
                    // سطراً: «تحتاج إلى تحسين» لافتةٌ طويلة لا تُقصّ.
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 16.w,
                      runSpacing: 8.h,
                      children: [
                        _dotLabel(
                          AppColors.successStrong,
                          '${AppText.notePositive} $positive',
                        ),
                        _dotLabel(
                          AppColors.orange,
                          '${AppText.noteNeedsWork} $negative',
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppText.statsBehaviorPoints,
                            style: AppTextStyles.captionFaint),
                        Text(
                          '${behavior.points} ${AppText.pointsUnit}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    if (behavior.topNotes.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      FieldLabel(AppText.statsTopNotes),
                      SizedBox(height: 8.h),
                      for (final note in behavior.topNotes)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: note.isPositive
                                      ? AppColors.successStrong
                                      : AppColors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  '${note.title} × ${note.total}',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (months.length > 1) ...[
                      SizedBox(height: 16.h),
                      FieldLabel(AppText.statsBehaviorByMonth),
                      SizedBox(height: 10.h),
                      // بلا ارتفاع مفروض: الأعمدة تحمل ارتفاعها، والصفّ يأخذ
                      // أطولها. وارتفاعٌ ثابت يفيض بتكبير الخط.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < months.length; i++) ...[
                            if (i > 0) SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${months[i].total}',
                                      style: AppTextStyles.captionFaint),
                                  SizedBox(height: 6.h),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: SizedBox(
                                      height:
                                          (62 * months[i].total / maxMonth).h,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: months[i].negative,
                                            child: Container(
                                              width: double.infinity,
                                              color: AppColors.orange,
                                            ),
                                          ),
                                          Expanded(
                                            flex: months[i].positive,
                                            child: Container(
                                              width: double.infinity,
                                              color: AppColors.successStrong,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    months[i].label,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.captionFaint,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  // ─── المشاركة في الحصة ───────────────────────────────────────────────────

  Widget _participation(ParticipationStats participation) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(AppText.statsParticipation),
          SizedBox(height: 14.h),
          AppCard(
            child: participation.picked == 0
                ? Text(AppText.statsNoParticipation,
                    style: AppTextStyles.captionFaint)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _miniStat(
                              AppText.statsPicked,
                              '${participation.picked}',
                              AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _miniStat(
                              AppText.statsRated,
                              '${participation.rated}',
                              AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      if (participation.understoodRate != null) ...[
                        SizedBox(height: 14.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppText.statsUnderstood,
                                style: AppTextStyles.body),
                            Text(
                              '${_trim(participation.understoodRate!)}%',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        _bar(participation.understoodRate!),
                      ],
                      if (participation.rows.isNotEmpty) ...[
                        SizedBox(height: 14.h),
                        for (final row in participation.rows)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(row.label, style: AppTextStyles.caption),
                                Text('${row.total}',
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      );

  // ─── الأعذار ─────────────────────────────────────────────────────────────

  Widget _excuses(ExcusesStats excuses) => _rowsSection(
        title: AppText.statsExcuses,
        rows: excuses.rows,
        emptyText: AppText.statsNoExcuses,
      );

  // ─── الإجراءات ───────────────────────────────────────────────────────────

  Widget _procedures(ProceduresStats procedures) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(AppText.statsProcedures),
          SizedBox(height: 14.h),
          AppCard(
            child: procedures.total == 0
                ? Text(AppText.statsNoProcedures,
                    style: AppTextStyles.captionFaint)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in procedures.rows)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(row.label, style: AppTextStyles.caption),
                              Text('${row.total}',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      // الوحيد في الشاشة كلّها الذي يطلب منه عملاً، فيُلوَّن.
                      if (procedures.awaitingResponse > 0) ...[
                        SizedBox(height: 8.h),
                        InfoBanner(
                          message: '${AppText.statsAwaitingResponse}:'
                              ' ${procedures.awaitingResponse}',
                          background: AppColors.dangerSoft,
                          foreground: AppColors.dangerText,
                          icon: AppIcons.warning,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      );

  // ─── الحالة الصحية ───────────────────────────────────────────────────────

  /// وصفٌ قائم لا حدثٌ في فترة، فلا يتغيّر بتغيّر المدى.
  Widget _health(HealthStats health) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(AppText.statsHealth),
          SizedBox(height: 14.h),
          AppCard(
            child: health.names.isEmpty
                ? Text(AppText.statsNoHealth, style: AppTextStyles.captionFaint)
                : Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final name in health.names)
                        StatusPill(
                          label: name,
                          background: AppColors.dangerSoft,
                          foreground: AppColors.dangerText,
                        ),
                    ],
                  ),
          ),
        ],
      );

  // ─── الاختبارات ──────────────────────────────────────────────────────────

  Widget _exams(ExamsStats exams) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            AppText.statsExams,
            // العدد في لصاقة العنوان لا في البطاقة: بجوار تفصيل الاختبار
            // الأقرب وحده يصير رقماً عارياً لا يُعرف ما يعدّه.
            trailing: exams.upcoming == 0
                ? null
                : StatusPill(
                    label: '${exams.upcoming}',
                    background: AppColors.fill,
                    foreground: AppColors.text,
                  ),
          ),
          SizedBox(height: 14.h),
          AppCard(
            child: exams.upcoming == 0
                ? Text(AppText.statsNoExams, style: AppTextStyles.captionFaint)
                : Row(
                    children: [
                      const IconTile(
                        icon: AppIcons.exams,
                        background: AppColors.primarySoft,
                        foreground: AppColors.primaryDark,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exams.nextSubject ?? AppText.statsExams,
                              style: AppTextStyles.cardTitle,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              [exams.nextDate, exams.nextCountdown]
                                  .whereType<String>()
                                  .where((e) => e.isNotEmpty)
                                  .join(' · '),
                              style: AppTextStyles.captionFaint,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      );

  // ─── مشتركات ─────────────────────────────────────────────────────────────

  Widget _rowsSection({
    required String title,
    required List<LabelledCount> rows,
    required String emptyText,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(title),
          SizedBox(height: 14.h),
          AppCard(
            child: rows.isEmpty
                ? Text(emptyText, style: AppTextStyles.captionFaint)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in rows)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(row.label, style: AppTextStyles.caption),
                              Text('${row.total}',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      );

  Widget _dotLabel(Color color, String label) => Row(
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
          Text(label, style: AppTextStyles.caption),
        ],
      );

  Widget _legendRow(List<_LegendItem> items, List<String> labels) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: 16.w),
            _dotLabel(items[i].color, labels[i]),
          ],
        ],
      );

  /// «92.0%» تُقرأ كأنها دقّة زائدة، و«92%» تكفي. أما «92.1%» فتبقى كما هي.
  static String _trim(double value) {
    final rounded = value.roundToDouble();
    return value == rounded
        ? rounded.toInt().toString()
        : value.toStringAsFixed(1);
  }

  /// صيغة العدد في العربية: واحدٌ ومثنّى وجمعُ قلّة ثم تمييزٌ مفرد منصوب.
  static String _days(int count) {
    if (count == 1) return AppText.statsOneDay;
    if (count == 2) return AppText.statsTwoDays;
    if (count <= 10) return '$count ${AppText.statsFewDays}';
    return '$count ${AppText.statsManyDays}';
  }
}

/// جزءٌ من جامع — «يوم كامل» تحت «غائب».
class _Part {
  const _Part(this.label, this.value);

  final String label;
  final String value;
}

class _LegendItem {
  const _LegendItem(this.color, this.label);

  final Color color;
  final String? label;
}
