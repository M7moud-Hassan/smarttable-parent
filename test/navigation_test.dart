import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartble_parent/core/conts/text.dart';
import 'package:smartble_parent/core/theme/theme_app.dart';
import 'package:smartble_parent/core/utils/app_utils.dart';
import 'package:smartble_parent/features/parent/presentation/pages/forgot_password_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/login_page.dart';
import 'package:smartble_parent/features/parent/presentation/pages/register_phone_page.dart';
import 'package:smartble_parent/features/parent/data/datasources/db.dart';
import 'package:smartble_parent/injections/injection_main.dart';

import 'fixtures/db_fake.dart';

/// انتقالات شاشة الدخول.
///
/// الزر يُرسم صحيحاً ولا ينتقل إن لم يكن `Get` موصولاً بمُوجِّه التطبيق، وهو
/// عطل لا يظهر في لقطة شاشة — فيلزمه ضغط حقيقي.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    if (!AppUtils.sl.isRegistered<AppUtils>()) {
      await init();
      await AppUtils.sl.allReady();
    }
    AppUtils.sl.unregister<Db>();
    AppUtils.sl.registerLazySingleton<Db>(DbFake.new);
  });

  testWidgets('«التسجيل لأول مرة» ينقل إلى شاشة رقم الجوال', (tester) async {
    await _pumpLogin(tester);

    await tester.tap(find.text(AppText.firstTimeRegister));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPhonePage), findsOneWidget);
  });

  testWidgets('«نسيت كلمة المرور؟» ينقل إلى شاشة الاستعادة', (tester) async {
    await _pumpLogin(tester);

    await tester.tap(find.text(AppText.forgotPassword));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
  });
}

Future<void> _pumpLogin(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(375, 812);
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() async {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeApp.lightTheme,
        locale: const Locale('ar', 'SA'),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: LoginPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
