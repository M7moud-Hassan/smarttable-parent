import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/base_entity.dart';
import '../../domain/entities/service_entities.dart';
import '../models/admin_action_model.dart';
import '../models/attendance_model.dart';
import '../models/behavior_model.dart';
import '../models/circular_model.dart';
import '../models/exam_model.dart';
import '../models/health_model.dart';
import '../models/home_model.dart';
import '../models/notification_model.dart';
import '../models/parent_model.dart';
import '../models/schedule_model.dart';
import '../models/school_model.dart';
import '../models/student_model.dart';

/// كل ما يقرأه التطبيق أو يكتبه. حالات الاستخدام لا تعرف من أين تأتي البيانات —
/// تمرّر دالةً من هنا إلى المستودع، فيصحّ تبديل التنفيذ بلا لمس أي شاشة.
abstract class Db {
  // ─── المصادقة ────────────────────────────────────────────────────────────
  Future<ParentUser> Function(LoginEntity) get login;
  Future<String> Function(PhoneEntity) get requestOtp;
  Future<bool> Function(OtpEntity) get verifyOtp;
  Future<ParentUser> Function(CreateAccountEntity) get createAccount;
  Future<String> Function(PhoneEntity) get forgotPassword;
  Future<bool> Function(ResetPasswordEntity) get resetPassword;
  Future<bool> Function(ChangePasswordEntity) get changePassword;
  Future<bool> Function() get deleteAccount;

  // ─── الحساب والأبناء ─────────────────────────────────────────────────────
  Future<ParentUser> Function() get me;
  Future<ParentUser> Function(ProfileEntity) get updateProfile;
  Future<List<Student>> Function() get students;

  // ─── الرئيسية والإشعارات ─────────────────────────────────────────────────
  Future<HomeSummary> Function(StudentEntity) get home;
  Future<List<ParentNotification>> Function() get notifications;
  Future<bool> Function() get markAllRead;
  Future<List<NotificationSetting>> Function() get notificationSettings;
  Future<bool> Function(NotificationSettingsEntity) get saveNotificationSettings;

  // ─── الخدمات ─────────────────────────────────────────────────────────────
  Future<WeekSchedule> Function(StudentEntity) get schedule;
  Future<AttendanceReport> Function(StudentEntity) get attendance;
  Future<ExcuseForm> Function(IdEntity) get absencePeriod;
  Future<bool> Function(ExcuseEntity) get submitExcuse;
  Future<BehaviorReport> Function(BehaviorFilterEntity) get behavior;
  Future<HealthRecord> Function(StudentEntity) get health;
  Future<bool> Function(HealthEntity) get saveHealth;
  Future<List<Exam>> Function(StudentEntity) get exams;
  Future<Exam> Function(IdEntity) get examDetails;
  Future<List<Circular>> Function(StudentEntity) get circulars;
  Future<Circular> Function(IdEntity) get circularDetails;
  Future<List<AdminAction>> Function(StudentEntity) get adminActions;
  Future<bool> Function(ActionResponseEntity) get respondToAction;

  // ─── محتوى ثابت ──────────────────────────────────────────────────────────
  Future<SchoolInfo> Function(StudentEntity) get school;
  Future<SchoolInfo> Function() get support;
  Future<List<FaqItem>> Function() get faq;
  Future<StaticPage> Function(StaticPageEntity) get staticPage;
}
