import 'package:smartble_parent/core/enums/attendance_status.dart';
import 'package:smartble_parent/core/enums/note_type.dart';
import 'package:smartble_parent/core/errors/exceptions.dart';
import 'package:smartble_parent/core/utils/app_utils.dart';
import 'package:smartble_parent/features/parent/domain/entities/auth_entities.dart';
import 'package:smartble_parent/features/parent/domain/entities/base_entity.dart';
import 'package:smartble_parent/features/parent/domain/entities/service_entities.dart';
import 'package:smartble_parent/features/parent/data/models/admin_action_model.dart';
import 'package:smartble_parent/features/parent/data/models/attendance_model.dart';
import 'package:smartble_parent/features/parent/data/models/behavior_model.dart';
import 'package:smartble_parent/features/parent/data/models/circular_model.dart';
import 'package:smartble_parent/features/parent/data/models/exam_model.dart';
import 'package:smartble_parent/features/parent/data/models/health_model.dart';
import 'package:smartble_parent/features/parent/data/models/home_model.dart';
import 'package:smartble_parent/features/parent/data/models/notification_model.dart';
import 'package:smartble_parent/features/parent/data/models/parent_model.dart';
import 'package:smartble_parent/features/parent/data/models/schedule_model.dart';
import 'package:smartble_parent/features/parent/data/models/school_model.dart';
import 'package:smartble_parent/features/parent/data/models/student_model.dart';
import 'package:smartble_parent/features/parent/data/datasources/db.dart';
import 'design_data.dart';

/// تنفيذ `Db` فوق بيانات التصميم — للاختبار وحده.
///
/// اختبار اللقطات يسجّله بدل `DbRemote` كي تُرسم الشاشات بمحتوى الحزمة نفسه
/// بلا خادم. والتطبيق لا يعرفه: هو في `test/` لا في `lib/`.
class DbFake implements Db {
  /// تأخير قصير يحاكي زمن الشبكة، فتظهر حالات التحميل في الشاشات كما ستظهر
  /// مع الخادم الحقيقي.
  static Future<T> _delayed<T>(T value) =>
      Future.delayed(const Duration(milliseconds: 350), () => value);

  // ─── المصادقة ────────────────────────────────────────────────────────────
  @override
  Future<ParentUser> Function(LoginEntity) get login => (entity) async {
        if (entity.username.trim().isEmpty || entity.password.isEmpty) {
          throw ValidationException('أدخل اسم المستخدم وكلمة المرور.');
        }
        return _delayed(DesignData.parent);
      };

  @override
  Future<String> Function(PhoneEntity) get requestOtp => (entity) async {
        _ensurePhone(entity.phone);
        return _delayed(entity.phone);
      };

  @override
  Future<bool> Function(OtpEntity) get verifyOtp => (entity) async {
        if (entity.code.length != 4) {
          throw ValidationException('أدخل الرمز المكوّن من أربعة أرقام.');
        }
        return _delayed(true);
      };

  @override
  Future<ParentUser> Function(CreateAccountEntity) get createAccount => (entity) async {
        return _delayed(DesignData.parent.copyWith(
          username: entity.username,
          email: entity.email,
          phone: entity.phone,
        ));
      };

  @override
  Future<String> Function(PhoneEntity) get forgotPassword => (entity) async {
        _ensurePhone(entity.phone);
        return _delayed(entity.phone);
      };

  @override
  Future<bool> Function(ResetPasswordEntity) get resetPassword =>
      (entity) => _delayed(true);

  @override
  Future<bool> Function(ChangePasswordEntity) get changePassword => (entity) async {
        if (entity.currentPassword.isEmpty) {
          throw ValidationException('أدخل كلمة المرور الحالية.');
        }
        return _delayed(true);
      };

  @override
  Future<bool> Function() get deleteAccount => () => _delayed(true);

  // ─── الحساب والأبناء ─────────────────────────────────────────────────────
  @override
  Future<ParentUser> Function() get me => () => _delayed(DesignData.parent);

  @override
  Future<ParentUser> Function(ProfileEntity) get updateProfile => (entity) async {
        DesignData.parent = DesignData.parent.copyWith(
          name: entity.name,
          nationalId: entity.nationalId,
          email: entity.email,
          workplace: entity.workplace,
          phone: entity.phone,
          avatar: entity.avatarPath,
        );
        return _delayed(DesignData.parent);
      };

  @override
  Future<List<Student>> Function() get students => () => _delayed(DesignData.students);

  // ─── الرئيسية والإشعارات ─────────────────────────────────────────────────
  @override
  Future<HomeSummary> Function(StudentEntity) get home =>
      (entity) => _delayed(DesignData.home(entity.studentId));

  @override
  Future<List<ParentNotification>> Function() get notifications =>
      () => _delayed(DesignData.notifications);

  @override
  Future<bool> Function() get markAllRead => () async {
        DesignData.notifications =
            DesignData.notifications.map((n) => n.copyWith(read: true)).toList();
        return _delayed(true);
      };

  @override
  Future<List<NotificationSetting>> Function() get notificationSettings => () async {
        // ما حفظه المستخدم محلياً يسبق الافتراضي، فلا يعود المفتاح إلى وضعه
        // الأول عند كل فتح للشاشة.
        final saved = AppUtils.instance.getNotificationSettings();
        if (saved == null) return _delayed(DesignData.notificationSettings);
        return _delayed(DesignData.notificationSettings
            .map((s) => s.copyWith(enabled: saved[s.key] ?? s.enabled))
            .toList());
      };

  @override
  Future<bool> Function(NotificationSettingsEntity) get saveNotificationSettings =>
      (entity) async {
        await AppUtils.instance.setNotificationSettings(entity.settings);
        return _delayed(true);
      };

  // ─── الخدمات ─────────────────────────────────────────────────────────────
  @override
  Future<WeekSchedule> Function(StudentEntity) get schedule =>
      (entity) => _delayed(DesignData.schedule);

  @override
  Future<AttendanceReport> Function(StudentEntity) get attendance =>
      (entity) => _delayed(DesignData.attendance);

  @override
  Future<ExcuseForm> Function(IdEntity) get absencePeriod => (entity) async {
        final match = DesignData.attendance.entries
            .where((e) => e.id == entity.id && e.days.isNotEmpty);
        return _delayed(ExcuseForm(
          period: match.isEmpty ? DesignData.absencePeriod : match.first,
          reasons: DesignData.excuseReasons,
        ));
      };

  @override
  Future<bool> Function(ExcuseEntity) get submitExcuse => (entity) async {
        if (entity.dayIds.isEmpty) {
          throw ValidationException('اختر يوماً واحداً على الأقل.');
        }
        if (entity.reason.isEmpty) {
          throw ValidationException('اختر سبب الغياب.');
        }
        // العذر المُرسل ينقل الفترة إلى «قيد المراجعة» كما ينصّ التصميم.
        DesignData.attendance = AttendanceReport(
          termLabel: DesignData.attendance.termLabel,
          percentage: DesignData.attendance.percentage,
          presentDays: DesignData.attendance.presentDays,
          lateDays: DesignData.attendance.lateDays,
          absentDays: DesignData.attendance.absentDays,
          warning: DesignData.attendance.warning,
          entries: DesignData.attendance.entries
              .map((e) => e.id == entity.periodId
                  ? e.copyWith(excuseStatus: ExcuseStatus.pending, canSubmitExcuse: false)
                  : e)
              .toList(),
        );
        return _delayed(true);
      };

  @override
  Future<BehaviorReport> Function(BehaviorFilterEntity) get behavior => (filter) async {
        var notes = DesignData.behaviorNotes;
        if (filter.type != null) {
          notes = notes.where((n) => n.type == filter.type).toList();
        }
        return _delayed(BehaviorReport(
          notes: notes,
          statistics: DesignData.behaviorStatistics,
        ));
      };

  @override
  Future<HealthRecord> Function(StudentEntity) get health =>
      (entity) => _delayed(DesignData.health);

  @override
  Future<bool> Function(HealthEntity) get saveHealth => (entity) async {
        DesignData.health = DesignData.health.copyWith(
          selected: entity.diseases,
          instructions: entity.instructions,
          reportName: entity.reportPath == null
              ? DesignData.health.reportName
              : entity.reportPath!.split(RegExp(r'[\\/]')).last,
        );
        return _delayed(true);
      };

  @override
  Future<List<Exam>> Function(StudentEntity) get exams =>
      (entity) => _delayed(DesignData.exams);

  @override
  Future<Exam> Function(IdEntity) get examDetails => (entity) async {
        final match = DesignData.exams.where((e) => e.id == entity.id);
        return _delayed(match.isEmpty ? DesignData.exams.first : match.first);
      };

  @override
  Future<List<Circular>> Function(StudentEntity) get circulars =>
      (entity) => _delayed(DesignData.circulars);

  @override
  Future<Circular> Function(IdEntity) get circularDetails => (entity) async {
        final match = DesignData.circulars.where((c) => c.id == entity.id);
        return _delayed(match.isEmpty ? DesignData.circulars.first : match.first);
      };

  @override
  Future<List<AdminAction>> Function(StudentEntity) get adminActions =>
      (entity) => _delayed(DesignData.adminActions);

  @override
  Future<bool> Function(ActionResponseEntity) get respondToAction => (entity) async {
        DesignData.adminActions = DesignData.adminActions
            .map((a) =>
                a.id == entity.actionId ? a.copyWith(state: AdminActionState.seen) : a)
            .toList();
        return _delayed(true);
      };

  // ─── محتوى ثابت ──────────────────────────────────────────────────────────
  @override
  Future<SchoolInfo> Function(StudentEntity) get school =>
      (entity) => _delayed(DesignData.school);

  @override
  Future<SchoolInfo> Function() get support => () => _delayed(DesignData.support);

  @override
  Future<List<FaqItem>> Function() get faq => () => _delayed(DesignData.faq);

  @override
  Future<StaticPage> Function(StaticPageEntity) get staticPage => (entity) async {
        switch (entity.kind) {
          case StaticPageKind.about:
            return _delayed(DesignData.about);
          case StaticPageKind.privacy:
            return _delayed(DesignData.privacy);
          case StaticPageKind.terms:
            return _delayed(DesignData.terms);
        }
      };

  void _ensurePhone(String phone) {
    final digits = AppUtils.convertToWesternNumerals(phone).replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 || !digits.startsWith('05')) {
      throw ValidationException('أدخل رقم جوال سعودي صحيح يبدأ بـ 05.');
    }
  }
}
