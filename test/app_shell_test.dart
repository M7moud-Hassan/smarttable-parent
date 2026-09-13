import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartble_parent/core/conts/app_constants.dart';
import 'package:smartble_parent/core/conts/text.dart';
import 'package:smartble_parent/core/utils/app_utils.dart';
import 'package:smartble_parent/features/parent/presentation/pages/forgot_password_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/login_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/otp_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/register_phone_page.dart';
import 'package:smartble_parent/features/parent/data/datasources/db.dart';
import 'package:smartble_parent/injections/injection_main.dart';

import 'fixtures/db_fake.dart';
import 'package:smartble_parent/main.dart';

/// رحلة داخل تركيب التطبيق الكامل — `ParentApp` بمُوجِّهه وطبقاته.
///
/// رحلة واحدة متّصلة لا عدة اختبارات: حالة `Get` عامّة تعيش بعد انتهاء
/// الاختبار — مفتاح المُوجِّه وكوم المسارات — فبناء التطبيق مرتين في ملف واحد
/// يجعل الثاني يرث مُوجِّه الأول.
///
/// والعبرة في تجاوز الانتقال الأول: هو ينجح في كل حال، وإنما يسقط ما بعده حين
/// تتساوى أسماء المسارات. فاختبار يبني شاشة واحدة بمفردها لا يكشف العطل.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // قبل أي تهيئة: `EasyLocalization` نفسها تقرأ التخزين المحلي.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    if (!AppUtils.sl.isRegistered<AppUtils>()) {
      await init();
      await AppUtils.sl.allReady();
    }
    // بيئة الاختبار لا تنفّذ طلبات شبكة، فيُستبدل مصدر البيانات بتجهيزة.
    // موضوع الاختبار هو التنقّل لا الخادم.
    AppUtils.sl.unregister<Db>();
    AppUtils.sl.registerLazySingleton<Db>(DbFake.new);
    // الشاشات التعريفية مرئية سلفاً، فتنتقل شاشة البداية إلى الدخول.
    await AppUtils.instance.setOnboardingSeen();
  });

  testWidgets('رحلة الدخول والتسجيل تعبر الشاشات ذهاباً ورجوعاً', (tester) async {
    await _pumpApp(tester);

    // A1 ← A3: شاشة البداية تنتقل تلقائياً بعد مهلتها.
    expect(find.byType(LoginPage), findsOneWidget);

    // A3 ← A4: الانتقال الأول.
    await tester.tap(find.text(AppText.firstTimeRegister));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPhonePage), findsOneWidget);

    // A4 ← A5: الانتقال الثاني — وهو ما يسقط حين تتساوى أسماء المسارات.
    await tester.enterText(find.byType(TextField).first, '0551234567');
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppText.sendOtp));
    await tester.pumpAndSettle();
    expect(find.byType(OtpPage), findsOneWidget, reason: 'الانتقال الثاني هو موضع العطل');

    // الرجوع يعود خطوة واحدة لا إلى الجذر.
    AppUtils.back();
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPhonePage), findsOneWidget);

    AppUtils.back();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    // A3 ← A8: انتقال ثالث من الشاشة نفسها إلى وجهة أخرى.
    await tester.tap(find.text(AppText.forgotPassword));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordPage), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(375, 812);
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() async {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(EasyLocalization(
    supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
    path: AppConstants.pathTranslate,
    startLocale: const Locale('ar', 'SA'),
    fallbackLocale: const Locale('ar', 'SA'),
    child: const ParentApp(),
  ));

  // ثلاث خطوات بترتيبها: تُحمَّل الترجمة أولاً فتُبنى شاشة البداية ويبدأ
  // مؤقّتها، ثم يُقدَّم الزمن بقدر المهلة — إذ لا يستنفد `pumpAndSettle` مؤقّتاً
  // لا يجدول إطاراً، ووسيطه فاصل بين النبضات لا مدة انتظار — ثم يُتمّ الانتقال.
  await tester.pumpAndSettle();
  await tester.pump(AppConstants.splashDelay + const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}
