import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/dimensions.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_bottom_nav.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../injections/injection_main.dart';
import '../../data/models/home_model.dart';
import '../../data/models/student_model.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/notifications/notifications_bloc.dart';
import '../bloc/students/students_bloc.dart';
import '../widgets/home_header.dart';
import '../widgets/service_tile.dart';
import '../widgets/student_strip.dart';
import 'admin_actions_page.dart';
import 'attendance_page.dart';
import 'behavior_page.dart';
import 'circulars_page.dart';
import 'exams_page.dart';
import 'excuse_page.dart';
import 'health_page.dart';
import 'schedule_page.dart';
import 'stats_page.dart';

/// B1 الرئيسية — وB4 نسخة التابلت، وهما الشاشة نفسها بشريط جانبي بدل السفلي
/// وثلاثة أعمدة بدل عمودين.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.tab, required this.onTab});

  final ParentTab tab;
  final ValueChanged<ParentTab> onTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // البلوك حقلٌ لا يُنشأ داخل `build`: الرئيسية تعيش في `IndexedStack` فلا
  // تُبنى من جديد عند العودة إليها. وكان هذا يعني أن ما قُرئ أول مرة يبقى
  // معروضًا طول الجلسة — غيابٌ سجّلته المدرسة بعدها، أو موعد اختبارٍ
  // أضافته، يصل إشعارًا وتبقى بطاقته تقول «لا غياب بدون عذر» و«لا اختبارات
  // قادمة» حتى يُقتل التطبيق ويُفتح. شاشاتُ الخدمات لا يصيبها هذا لأنها
  // تُدفع مساراتٍ جديدة ببلوكاتٍ جديدة، فتُظهر ما لا تُظهره بطاقتها.
  late final HomeBloc _homeBloc = bloc<HomeBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // العودة إلى تبويب الرئيسية تُعيد قراءتها، كما يفعل تبويب الإشعارات.
    if (widget.tab == ParentTab.home && oldWidget.tab != ParentTab.home) {
      _reload();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // ما وصل إشعارًا والتطبيق في الخلفية يكون قد غيّر العدّادات بالفعل،
    // فتُقرأ من جديد عند العودة إليه لا عند فتحه من الصفر.
    if (state == AppLifecycleState.resumed && widget.tab == ParentTab.home) {
      _reload();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // `BlocProvider.value` لا يُغلق ما لم يُنشئه، فيُغلق هنا.
    _homeBloc.close();
    super.dispose();
  }

  /// يطلب رئيسية الطالب المختار. تُنتظر المحاولةُ لا تغيّرُ الحالة كي يعرف
  /// `RefreshIndicator` متى يتوقّف: الحالة لا تتغيّر حين تعود العدّادات نفسها.
  Future<void> _reload() {
    final selected = AppUtils.selectedStudent;
    if (selected == null) return Future<void>.value();
    final completer = Completer<void>();
    _homeBloc.add(
      GetHomeEvent(studentId: selected.id, onDone: completer.complete),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: BlocListener<StudentsBloc, StudentsState>(
        // شريط الأبناء يبدّل الطالب، فتُعاد قراءة الرئيسية وحدها. بقية
        // الشاشات تقرأ الطالب المختار عند فتحها.
        listener: (context, state) {
          if (state is StudentsLoadedState && state.selected != null) {
            context
                .read<HomeBloc>()
                .add(GetHomeEvent(studentId: state.selected!.id));
          }
        },
        child: BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, studentsState) {
            final students = studentsState is StudentsLoadedState
                ? studentsState.students
                : <Student>[];
            final selected = AppUtils.selectedStudent;

            if (studentsState is StudentsLoadedState && selected != null) {
              if (_homeBloc.state is HomeInitial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _homeBloc.state is HomeInitial) {
                    _homeBloc.add(GetHomeEvent(studentId: selected.id));
                  }
                });
              }
            }

            return BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, notificationsState) {
                final unread = notificationsState is NotificationsLoadedState &&
                    notificationsState.unreadCount > 0;

                return ParentScaffold(
                  showBottomNav: true,
                  currentTab: widget.tab,
                  onTabSelected: widget.onTab,
                  hasUnreadNotifications: unread,
                  customHeader: HomeHeader(
                    hasUnread: unread,
                    onBell: () => widget.onTab(ParentTab.notifications),
                  ),
                  bodyPadding: EdgeInsets.only(bottom: 28.h),
                  // التمرير هنا لا في `ParentScaffold`، ليُلفّ بـ
                  // `RefreshIndicator`: سحبةٌ إلى أسفل تُعيد قراءة العدّادات
                  // متى شكّ وليّ الأمر في أنها تأخّرت عن خبرٍ وصله.
                  scrollable: false,
                  body: RefreshIndicator(
                    onRefresh: _reload,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      // شريط الأبناء يبقى ظاهراً بصرف النظر عن حال الرئيسية:
                      // فشل جلبها (مثلاً مدرسة الطالب المختار غير مشتركة) لا
                      // يمنع وليّ الأمر من اختيار ابنٍ آخر مدرسته مشتركة.
                      child: studentsState is StudentsFailureState
                          ? Center(
                              child: Text(
                                studentsState.failure.message,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMuted,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!Responsive.isTablet(context) &&
                                    students.length > 1)
                                  _studentSelector(context, students, selected),
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    if (state is HomeLoading ||
                                        state is HomeInitial) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 80.h),
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }
                                    if (state is HomeFailureState) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 40.h),
                                        child: Center(
                                          child: Text(
                                            state.failure.message,
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.bodyMuted,
                                          ),
                                        ),
                                      );
                                    }
                                    if (state is! HomeLoadedState) {
                                      return const SizedBox.shrink();
                                    }
                                    return _content(
                                        context, state.summary, selected);
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// شريط اختيار الطالب — يظهر بصرف النظر عن نجاح تحميل الرئيسية أو فشله،
  /// فهو وسيلة الخروج حين تكون مدرسة المختار غير مشتركة.
  Widget _studentSelector(
    BuildContext context,
    List<Student> students,
    Student? selected,
  ) {
    final horizontal =
        EdgeInsets.symmetric(horizontal: Dimensions.screenPadding);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: horizontal.copyWith(top: 20.h),
          child: SectionTitle(
            'اختر الطالب (${students.length})',
            trailing: Text(AppText.swipeToSwitch,
                style: AppTextStyles.captionFaint),
          ),
        ),
        SizedBox(height: 12.h),
        StudentStrip(
          students: students,
          selectedId: selected?.id,
          onSelect: (student) => context
              .read<StudentsBloc>()
              .add(SelectStudentEvent(student: student)),
        ),
      ],
    );
  }

  Widget _content(
    BuildContext context,
    HomeSummary summary,
    Student? selected,
  ) {
    final horizontal =
        EdgeInsets.symmetric(horizontal: Dimensions.screenPadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16.h),
        if (summary.absenceAlert != null)
          Padding(
            padding: horizontal,
            child: _absenceCard(context, summary.absenceAlert!, selected),
          ),
        Padding(
          padding: horizontal.copyWith(top: 22.h),
          child: _statsCard(),
        ),
        Padding(
          padding: horizontal.copyWith(top: 22.h),
          child: SectionTitle(AppText.availableServices),
        ),
        SizedBox(height: 14.h),
        Padding(
          padding: horizontal,
          child: _servicesGrid(context, summary.services, selected),
        ),
      ],
    );
  }

  /// مدخل «إحصاءات ابني».
  ///
  /// بطاقةٌ عريضة لا خدمةٌ ثامنة في الشبكة: الشبكة تأتي من الخادم في عمودين،
  /// وثامنةٌ تتركها بسبعة مربّعات فيبقى آخرها وحيداً في سطره.
  Widget _statsCard() => AppCard(
        onTap: () => _openPage(const StatsPage()),
        child: Row(
          children: [
            const IconTile(
              icon: AppIcons.attendance,
              background: AppColors.primarySoft,
              foreground: AppColors.primaryDark,
              size: 50,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppText.statsEntryTitle, style: AppTextStyles.cardTitle),
                  SizedBox(height: 6.h),
                  Text(AppText.statsEntrySubtitle,
                      style: AppTextStyles.captionFaint),
                ],
              ),
            ),
            Icon(AppIcons.chevron, size: 20.sp, color: AppColors.textFaint),
          ],
        ),
      );

  Widget _absenceCard(
      BuildContext context, AbsenceAlert alert, Student? student) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconTile(
                icon: AppIcons.absence,
                background: AppColors.dangerSoft,
                foreground: AppColors.danger,
                size: 50,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title, style: AppTextStyles.cardTitle),
                    SizedBox(height: 6.h),
                    Text(alert.detail,
                        style: AppTextStyles.caption.copyWith(height: 1.6)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: SmallPillButton(
                  label:
                      '${AppText.submitExcuseCurrent}${AppText.currentPeriod}',
                  onTap: () => _openPage(ExcusePage(periodId: alert.periodId)),
                ),
              ),
              SizedBox(width: 10.w),
              SmallPillButton(
                label: AppText.allPeriods,
                filled: false,
                expand: false,
                onTap: () => _openPage(const AttendancePage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _servicesGrid(
    BuildContext context,
    List<ServiceCard> services,
    Student? student,
  ) {
    final columns = Responsive.servicesColumns(context);
    // آخر خدمة في التصميم تشغل الصفّ كاملاً بتخطيط أفقي — «الحالة الصحية».
    final grid = services.length > 1
        ? services.sublist(0, services.length - 1)
        : services;
    final wide = services.length > 1 ? services.last : null;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grid.length,
          // ارتفاع ثابت لا نسبة عرض إلى ارتفاع: النسبة تتغيّر مع عدد
          // الأعمدة، فتقصّ البطاقة سطر العدّاد في التابلت.
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            mainAxisExtent: 148.h,
          ),
          itemBuilder: (_, index) => ServiceTile(
            card: grid[index],
            onTap: () => _open(grid[index].service),
          ),
        ),
        if (wide != null) ...[
          SizedBox(height: 16.h),
          WideServiceTile(card: wide, onTap: () => _open(wide.service)),
        ],
      ],
    );
  }

  void _open(HomeService service) => _openPage(switch (service) {
        HomeService.schedule => const SchedulePage(),
        HomeService.attendance => const AttendancePage(),
        HomeService.behavior => const BehaviorPage(),
        HomeService.adminActions => const AdminActionsPage(),
        HomeService.exams => const ExamsPage(),
        HomeService.circulars => const CircularsPage(),
        HomeService.health => const HealthPage(),
      });

  /// يفتح شاشةً ثم يعيد قراءة الرئيسية عند العودة منها: ما يفعله وليّ الأمر
  /// في الداخل يغيّر العدّادات — عذرٌ يُقدَّم فيسقط الغياب من «بدون عذر»،
  /// وإجراءٌ يُردّ عليه فينقص من «الإجراءات الإدارية». ولا يكفي أن تُحدَّث
  /// الشاشة الداخلية وحدها: البطاقة هي ما يراه بعد خروجه منها.
  Future<void> _openPage(Widget page) async {
    await AppUtils.goWait<void>(page);
    if (mounted) await _reload();
  }
}
