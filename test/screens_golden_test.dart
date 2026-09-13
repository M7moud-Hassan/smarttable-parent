import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartble_parent/core/share/widgets/app_bottom_nav.dart';
import 'package:smartble_parent/core/theme/theme_app.dart';
import 'package:smartble_parent/core/utils/app_utils.dart';
import 'package:smartble_parent/features/parent/presentation/pages/admin_actions_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/alerts_settings_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/attendance_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/behavior_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/change_password_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/circular_details_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/circulars_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/contact_school_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/create_account_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/delete_account_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/exam_details_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/exams_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/excuse_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/faq_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/forgot_password_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/health_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/language_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/login_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/main_shell.dart';
import 'package:smartble_parent/features/parent/presentation/pages/onboarding_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/otp_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/personal_data_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/register_phone_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/reset_password_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/schedule_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/select_student_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/share_app_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/static_content_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/support_page.dart';
import 'package:smartble_parent/features/parent/data/datasources/db.dart';
import 'package:smartble_parent/injections/injection_main.dart';

import 'fixtures/db_fake.dart';
import 'fixtures/design_data.dart';
import 'package:smartble_parent/splash_page.dart';

/// يرسم كل شاشة بمقاس التصميم (375×812) ويكتبها صورة في `test/goldens`.
///
/// الغرض مقارنة بصرية بلقطات حزمة التسليم، لا اختبار انحدار: التشغيل بـ
/// `flutter test --update-goldens test/screens_golden_test.dart`.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await _loadTranslations();
    await _loadFonts();
    if (!AppUtils.sl.isRegistered<AppUtils>()) {
      await init();
      await AppUtils.sl.allReady();
    }
    // الشاشات تُرسم بمحتوى حزمة التسليم لا بنداءات الخادم: اللقطة تُقارن
    // بلقطة التصميم، فأي فرق فيها فرقٌ في الشاشة لا في البيانات.
    AppUtils.sl.unregister<Db>();
    AppUtils.sl.registerLazySingleton<Db>(DbFake.new);
    AppUtils.appUser = DesignData.parent;
    AppUtils.students = DesignData.students;
    AppUtils.selectedStudent = DesignData.students.first;
  });

  final screens = <String, Widget>{
    '01_A1_splash': const SplashPage(),
    '02_A2_onboarding': const OnboardingPage(),
    '03_A3_login': const LoginPage(),
    '04_A4_register': const RegisterPhonePage(),
    '05_A5_otp': const OtpPage(phone: '0551234567'),
    '06_A6_create_account':
        const CreateAccountPage(phone: '0551234567', studentsCount: 3),
    '07_A7_select_student': const SelectStudentPage(),
    '08_A8_forgot': const ForgotPasswordPage(),
    '09_A9_reset': const ResetPasswordPage(),
    '10_B1_home': const MainShell(),
    '11_B2_notifications': const MainShell(initialTab: ParentTab.notifications),
    '12_B3_account': const MainShell(initialTab: ParentTab.account),
    '14_C1_schedule': const SchedulePage(),
    '15_C2_attendance': const AttendancePage(),
    '16_C3_excuse': const ExcusePage(periodId: 'period-1'),
    '17_C4_behavior': const BehaviorPage(),
    '18_C5_health': const HealthPage(),
    '19_D1_exams': const ExamsPage(),
    '20_D2_exam_details': const ExamDetailsPage(examId: 'e1'),
    '21_D3_circulars': const CircularsPage(),
    '22_D4_circular_details': const CircularDetailsPage(circularId: 'c1'),
    '23_D5_actions': const AdminActionsPage(),
    '24_E1_personal_data': const PersonalDataPage(),
    '25_E2_password': const ChangePasswordPage(),
    '26_E3_alerts': const AlertsSettingsPage(),
    '27_E4_language': const LanguagePage(),
    '28_E5_school': const ContactSchoolPage(),
    '29_E6_support': const SupportPage(),
    '30_E7_faq': const FaqPage(),
    '31_E8_about': const StaticContentPage.about(),
    '32_E9_share': const ShareAppPage(),
    '33_E10_delete': const DeleteAccountPage(),
  };

  screens.forEach((name, page) {
    testWidgets(name, (tester) async {
      await _size(tester, const Size(375, 812));

      await tester.pumpWidget(_Harness(child: page));
      // `EasyLocalization` تعرض فراغًا حتى تُحمَّل ملفّات اللغة، فبلا إتمام
      // التحميل تُلتقط لقطةٌ سوداء لا شاشة.
      await tester.pumpAndSettle();
      // نداءات مصدر البيانات مؤجَّلة 350ms، فتُستنفد المؤقّتات قبل اللقطة.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(_Harness),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  });

  testWidgets('13_B4_home_tablet', (tester) async {
    await _size(tester, const Size(834, 1108));
    await tester.pumpWidget(const _Harness(tablet: true, child: MainShell()));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(_Harness),
      matchesGoldenFile('goldens/13_B4_home_tablet.png'),
    );
  });
}

/// ScreenUtil يقرأ مقاس الشاشة من `View` لا من مقاس السطح الذي يفرضه الاختبار،
/// فلو ضُبط أحدهما دون الآخر خرج مقياس `.w` و`.h` عن الحقيقة وانهار التخطيط.
Future<void> _size(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.binding.setSurfaceSize(null);
  });
}

/// إطار يضع الشاشة في بيئة التطبيق نفسها: السمة، الاتجاه، ومقاس التصميم.
class _Harness extends StatelessWidget {
  const _Harness({required this.child, this.tablet = false});

  final Widget child;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: tablet ? const Size(834, 1108) : const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeApp.lightTheme,
        locale: const Locale('ar', 'SA'),
        home: Directionality(textDirection: TextDirection.rtl, child: child),
      ),
    );
  }
}

/// يحمّل النصوص العربية في `Localization` مباشرةً.
///
/// لا تُستعمل ودجة `EasyLocalization` هنا: هي تقرأ ملفّ اللغة قراءةً غير
/// متزامنة وتعرض فراغًا حتى ينتهي، ولا يستنفد `pumpAndSettle` تلك القراءة في
/// بيئة الاختبار — فتخرج كل لقطةٍ سوداء. والقراءة من القرص مباشرةً تُغني
/// عنها: النصّ هو النصّ، والمقصود رسمُ الشاشة لا اختبار آلية التحميل.
Future<void> _loadTranslations() async {
  final raw = File('assets/lang/ar-SA.json').readAsStringSync();
  final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
  Localization.load(
    const Locale('ar', 'SA'),
    translations: Translations(map),
  );
}

/// خطوط الاختبار تكون فارغة ما لم تُحمَّل من الأصول، فتخرج اللقطة مربّعات.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  }

  await load('IBMPlexSansArabic', [
    'assets/fonts/IBMPlexSansArabic-300.ttf',
    'assets/fonts/IBMPlexSansArabic-400.ttf',
    'assets/fonts/IBMPlexSansArabic-500.ttf',
    'assets/fonts/IBMPlexSansArabic-600.ttf',
    'assets/fonts/IBMPlexSansArabic-700.ttf',
  ]);
  await load('Cairo', [
    'assets/fonts/Cairo-700.ttf',
    'assets/fonts/Cairo-800.ttf',
  ]);

  // خطّ أيقونات Material لا يُحمَّل في الاختبار تلقائياً، فتخرج كل أيقونة
  // مربّعاً فارغاً ولا تُقارن اللقطة بالتصميم.
  final icons = File('${Platform.environment['FLUTTER_ROOT'] ?? 'D:/src/flutter'}'
      '/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(icons.readAsBytes().then((b) => ByteData.view(b.buffer)));
    await loader.load();
  }
}
