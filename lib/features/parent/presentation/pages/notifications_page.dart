import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/conts/app_colors.dart';
import '../../../../core/conts/app_text_styles.dart';
import '../../../../core/conts/icons.dart';
import '../../../../core/conts/text.dart';
import '../../../../core/share/widgets/app_bottom_nav.dart';
import '../../../../core/share/widgets/app_card.dart';
import '../../../../core/share/widgets/buttons.dart';
import '../../../../core/share/widgets/parent_scaffold.dart';
import '../../../../core/utils/app_utils.dart';
import '../../data/models/notification_model.dart';
import '../bloc/notifications/notifications_bloc.dart';
import '../bloc/students/students_bloc.dart';
import 'admin_actions_page.dart';
import 'attendance_page.dart';
import 'behavior_page.dart';
import 'circular_details_page.dart';
import 'circulars_page.dart';
import 'exam_details_page.dart';

/// B2 الإشعارات — كل إشعار ينقل إلى شاشته ويبدّل الطالب المعنيّ.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.tab, required this.onTab});

  final ParentTab tab;
  final ValueChanged<ParentTab> onTab;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unread =
            state is NotificationsLoadedState ? state.unreadCount : 0;

        return ParentScaffold(
          title: AppText.notifications,
          showBottomNav: true,
          currentTab: tab,
          onTabSelected: onTab,
          hasUnreadNotifications: unread > 0,
          scrollable: false,
          body: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$unread${AppText.unreadCount}',
                        style: TextStyle(
                          fontSize: AppTextStyles.s12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      TextLinkButton(
                        label: AppText.markAllRead,
                        onTap: () => context
                            .read<NotificationsBloc>()
                            .add(MarkAllReadEvent()),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (state is NotificationsLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (state is NotificationsLoadedState)
                    if (state.notifications.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 60.h),
                        child: Text(
                          AppText.noNotifications,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                      )
                    else
                      for (final item in state.notifications) ...[
                        _card(context, item),
                        SizedBox(height: 12.h),
                      ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// يطلب قائمة جديدة وينتظر اكتمال المحاولة (لا تغيّر الحالة) كي يعرف
  /// `RefreshIndicator` متى يُخفي دائرة التحميل. الاعتماد على تدفّق الحالة
  /// (`bloc.stream.firstWhere`) كان يُعلّق المؤشر إلى الأبد حين تعود نفس
  /// الإشعارات دون جديد: عندها لا يبثّ `emit` شيئًا لأن الحالة الجديدة تساوي
  /// الحالية (`Equatable`).
  Future<void> _refresh(BuildContext context) {
    final completer = Completer<void>();
    context
        .read<NotificationsBloc>()
        .add(GetNotificationsEvent(onDone: completer.complete));
    return completer.future;
  }

  Widget _card(BuildContext context, ParentNotification item) {
    final style = _StyleOf(item.target);

    return AppCard(
      radius: 8,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      onTap: () => _open(context, item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: style.icon,
            background: style.background,
            foreground: style.foreground,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.cardTitle.copyWith(height: 1.45)),
                SizedBox(height: 6.h),
                Text(item.body,
                    style: AppTextStyles.caption.copyWith(height: 1.6)),
                SizedBox(height: 6.h),
                Text(item.age, style: AppTextStyles.captionFaint),
              ],
            ),
          ),
          // النقطة الحمراء تختفي بمجرد القراءة، فيبقى العدّاد وشكل البطاقة
          // متّسقين.
          if (!item.read) ...[
            SizedBox(width: 8.w),
            Container(
              margin: EdgeInsets.only(top: 5.h),
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// فتح الإشعار يبدّل الطالب المعنيّ أولاً، وإلا فُتحت شاشة الخدمة على
  /// بيانات ابن آخر.
  void _open(BuildContext context, ParentNotification item) {
    final match = AppUtils.students.where((s) => s.id == item.studentId);
    if (match.isNotEmpty) {
      context
          .read<StudentsBloc>()
          .add(SelectStudentEvent(student: match.first));
    }

    switch (item.target) {
      case NotificationTarget.attendance:
      case NotificationTarget.excuseResult:
        AppUtils.go(const AttendancePage());
      case NotificationTarget.behavior:
        AppUtils.go(const BehaviorPage());
      case NotificationTarget.exam:
        AppUtils.go(ExamDetailsPage(examId: item.targetId ?? ''));
      case NotificationTarget.circular:
        item.targetId == null
            ? AppUtils.go(const CircularsPage())
            : AppUtils.go(CircularDetailsPage(circularId: item.targetId!));
      case NotificationTarget.adminAction:
        AppUtils.go(const AdminActionsPage());
    }
  }
}

/// لون الإشعار وأيقونته بحسب وجهته — كما في التصميم: الغياب أحمر، نتيجة العذر
/// خضراء، السلوك أزرق، الاختبار أصفر، والتعميم بلون الهوية.
class _StyleOf {
  factory _StyleOf(NotificationTarget target) {
    switch (target) {
      case NotificationTarget.attendance:
        return const _StyleOf._(
            AppIcons.absence, AppColors.dangerSoft, AppColors.danger);
      case NotificationTarget.excuseResult:
        return const _StyleOf._(
            AppIcons.excuseAccepted, AppColors.successSoft, AppColors.success);
      case NotificationTarget.behavior:
        return const _StyleOf._(
            AppIcons.behavior, AppColors.infoSoft, AppColors.info);
      case NotificationTarget.exam:
        return const _StyleOf._(
            AppIcons.exams, AppColors.warningSoft, AppColors.warningIcon);
      case NotificationTarget.circular:
        return const _StyleOf._(
            AppIcons.circulars, AppColors.primarySoft, AppColors.primaryDark);
      case NotificationTarget.adminAction:
        return const _StyleOf._(
            AppIcons.summons, AppColors.warningDeep, AppColors.warning);
    }
  }

  const _StyleOf._(this.icon, this.background, this.foreground);

  final IconData icon;
  final Color background;
  final Color foreground;
}
