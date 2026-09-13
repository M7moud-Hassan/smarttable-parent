import 'package:get/get.dart';

import '../../../core/share/widgets/app_bottom_nav.dart';
import '../presentation/pages/admin_actions_page.dart';
import '../presentation/pages/alerts_settings_page.dart';
import '../presentation/pages/attendance_page.dart';
import '../presentation/pages/behavior_page.dart';
import '../presentation/pages/change_password_page.dart';
import '../presentation/pages/circular_details_page.dart';
import '../presentation/pages/circulars_page.dart';
import '../presentation/pages/contact_school_page.dart';
import '../presentation/pages/create_account_page.dart';
import '../presentation/pages/delete_account_page.dart';
import '../presentation/pages/exam_details_page.dart';
import '../presentation/pages/exams_page.dart';
import '../presentation/pages/excuse_page.dart';
import '../presentation/pages/faq_page.dart';
import '../presentation/pages/forgot_password_page.dart';
import '../presentation/pages/health_page.dart';
import '../presentation/pages/language_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/main_shell.dart';
import '../presentation/pages/onboarding_page.dart';
import '../presentation/pages/otp_page.dart';
import '../presentation/pages/personal_data_page.dart';
import '../presentation/pages/register_phone_page.dart';
import '../presentation/pages/reset_password_page.dart';
import '../presentation/pages/schedule_page.dart';
import '../presentation/pages/select_student_page.dart';
import '../presentation/pages/share_app_page.dart';
import '../presentation/pages/static_content_page.dart';
import '../presentation/pages/support_page.dart';

/// أسماء المسارات وصفحاتها.
///
/// التنقّل داخل التطبيق يجري بـ `AppUtils.go` لأنه يمرّر الوسائط بأنواعها، وهذه
/// الأسماء لروابط الإشعارات والروابط العميقة التي تصل من خارج التطبيق.
class RouteHelper {
  RouteHelper._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String createAccount = '/create-account';
  static const String selectStudent = '/select-student';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String account = '/account';

  static const String schedule = '/schedule';
  static const String attendance = '/attendance';
  static const String excuse = '/excuse';
  static const String behavior = '/behavior';
  static const String health = '/health';

  static const String exams = '/exams';
  static const String examDetails = '/exam-details';
  static const String circulars = '/circulars';
  static const String circularDetails = '/circular-details';
  static const String adminActions = '/admin-actions';

  static const String personalData = '/personal-data';
  static const String changePassword = '/change-password';
  static const String alerts = '/alerts';
  static const String language = '/language';
  static const String contactSchool = '/contact-school';
  static const String support = '/support';
  static const String faq = '/faq';
  static const String about = '/about';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String shareApp = '/share';
  static const String deleteAccount = '/delete-account';

  /// مسار شاشة تفصيل بمعرّف: `/exam-details?id=e1`.
  static String withId(String route, String id) => '$route?id=$id';

  static String get _id => Get.parameters['id'] ?? '';
  static String get _phone => Get.parameters['phone'] ?? '';

  static List<GetPage> get routes => [
        GetPage(name: onboarding, page: () => const OnboardingPage()),
        GetPage(name: login, page: () => const LoginPage()),
        GetPage(name: register, page: () => const RegisterPhonePage()),
        GetPage(name: otp, page: () => OtpPage(phone: _phone)),
        GetPage(name: createAccount, page: () => CreateAccountPage(phone: _phone)),
        GetPage(name: selectStudent, page: () => const SelectStudentPage()),
        GetPage(name: forgotPassword, page: () => const ForgotPasswordPage()),
        GetPage(name: resetPassword, page: () => const ResetPasswordPage()),
        GetPage(name: home, page: () => const MainShell()),
        GetPage(
            name: notifications,
            page: () => const MainShell(initialTab: ParentTab.notifications)),
        GetPage(
            name: account, page: () => const MainShell(initialTab: ParentTab.account)),
        GetPage(name: schedule, page: () => const SchedulePage()),
        GetPage(name: attendance, page: () => const AttendancePage()),
        GetPage(name: excuse, page: () => ExcusePage(periodId: _id)),
        GetPage(name: behavior, page: () => const BehaviorPage()),
        GetPage(name: health, page: () => const HealthPage()),
        GetPage(name: exams, page: () => const ExamsPage()),
        GetPage(name: examDetails, page: () => ExamDetailsPage(examId: _id)),
        GetPage(name: circulars, page: () => const CircularsPage()),
        GetPage(name: circularDetails, page: () => CircularDetailsPage(circularId: _id)),
        GetPage(name: adminActions, page: () => const AdminActionsPage()),
        GetPage(name: personalData, page: () => const PersonalDataPage()),
        GetPage(name: changePassword, page: () => const ChangePasswordPage()),
        GetPage(name: alerts, page: () => const AlertsSettingsPage()),
        GetPage(name: language, page: () => const LanguagePage()),
        GetPage(name: contactSchool, page: () => const ContactSchoolPage()),
        GetPage(name: support, page: () => const SupportPage()),
        GetPage(name: faq, page: () => const FaqPage()),
        GetPage(name: about, page: () => const StaticContentPage.about()),
        GetPage(name: privacy, page: () => const StaticContentPage.privacy()),
        GetPage(name: terms, page: () => const StaticContentPage.terms()),
        GetPage(name: shareApp, page: () => const ShareAppPage()),
        GetPage(name: deleteAccount, page: () => const DeleteAccountPage()),
      ];
}
