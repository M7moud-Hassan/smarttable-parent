import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart' show Level;

import 'core/conts/app_colors.dart';
import 'core/conts/app_constants.dart';
import 'core/conts/dimensions.dart';
import 'core/services/push_notifications_service.dart';
import 'core/share/widgets/startup_error_screen.dart';
import 'core/theme/theme_app.dart';
import 'core/utils/app_utils.dart';
import 'core/utils/check_internet.dart';
import 'core/utils/dio.dart';
import 'features/parent/helper/route_helper.dart';
import 'injections/injection_main.dart';
import 'splash_page.dart';

/// كل ما يُنتظر قبل `runApp` يحبس الشاشة بيضاء حتى ينتهي — وإن لم ينتهِ بقيت
/// بيضاء إلى الأبد بلا رسالة. فلا يُنتظر هنا إلا ما يلزم أول إطار، وبمهلة،
/// وما عداه يؤجَّل إلى ما بعد ظهور الشاشة.
const _bootTimeout = Duration(seconds: 20);

void main() => runZonedGuarded(_bootstrap, (error, stack) {
      AppUtils.log('خطأ غير ملتقط: $error\n$stack', levelLog: Level.error);
    });

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();

  await EasyLocalization.ensureInitialized();

  // لا يُنتظر: قفل الاتجاهات لا شأن له بأول إطار.
  unawaited(SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]));

  Object? bootError;
  try {
    // `isRegistered` لأن شاشة الخطأ تعيد المحاولة، و get_it يرمي على تسجيل
    // مكرّر.
    if (!AppUtils.sl.isRegistered<AppUtils>()) await init();
    // `init` يسجّل SharedPreferences تسجيلاً غير متزامن ولا ينتظره، بينما
    // `AppUtils.instance` يُبنى منه مباشرة. بلا هذا السطر يصير فتح التطبيق
    // سباقاً مع قناة المنصّة: من يخسره يرى شاشة بيضاء دائمة.
    await AppUtils.sl.allReady(timeout: _bootTimeout);
    AppUtils.sl<DioConfig>().config();
    AppUtils.sl<CheckInternetConnection>().listener();
    // لا تُنتظر: تهيئة Firebase وطلب الإذن نداءان قد يطولان، وحبسُ الإقلاع
    // عليهما يترك الشاشة بيضاء. والخدمة لا ترمي، فتعطّلها لا يمنع الفتح.
    unawaited(PushNotificationsService.instance.init());
  } catch (e, s) {
    bootError = e;
    AppUtils.log('تعذّرت تهيئة التطبيق: $e\n$s', levelLog: Level.error);
  }

  if (bootError != null) {
    runApp(StartupErrorScreen(error: bootError, onRetry: _bootstrap));
    return;
  }

  runApp(EasyLocalization(
    supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
    path: AppConstants.pathTranslate,
    startLocale: _readLocale(),
    saveLocale: true,
    // لا يصلح أن يكون البديل هو اللغة المحفوظة نفسها: إن كانت هي التالفة بقي
    // التطبيق بلا ترجمة يسقط عليها.
    fallbackLocale: const Locale('ar', 'SA'),
    child: const ParentApp(),
  ));
}

void _installErrorHandlers() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    previous?.call(details);
    AppUtils.log('خطأ واجهة: ${details.exception}', levelLog: Level.error);
  };
  // خطأ غير متزامن خارج شجرة الودجات: يُسجَّل ولا يُسقط التطبيق.
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    AppUtils.log('خطأ غير متزامن: $error\n$stack', levelLog: Level.error);
    return true;
  };
}

Locale _readLocale() {
  try {
    return AppUtils.instance.getLocale();
  } catch (e) {
    AppUtils.log('تعذّرت قراءة اللغة المحفوظة: $e', levelLog: Level.error);
    return const Locale('ar', 'SA');
  }
}

class ParentApp extends StatelessWidget {
  const ParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    _configLoading();
    AppUtils.contextApp = context;

    // مخزَّن تالف أو نموذج تغيّر شكله لا يصحّ أن يمنع التطبيق من الفتح.
    try {
      AppUtils.appUser = AppUtils.instance.getUser();
    } catch (e) {
      AppUtils.log('تعذّرت قراءة بيانات المستخدم المحفوظة: $e',
          levelLog: Level.error);
      AppUtils.appUser = null;
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeApp.lightTheme,
      darkTheme: ThemeApp.darkTheme,
      themeMode: ThemeMode.light,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      getPages: RouteHelper.routes,
      transitionDuration: const Duration(milliseconds: 250),
      defaultTransition: Transition.cupertino,
      home: const SplashPage(),
      // ScreenUtil داخل `builder` لا فوق التطبيق: هنا وحده يتوفّر
      // `MediaQuery`، فيُختار مقاس التصميم بحسب الجهاز ويُعاد اختياره عند
      // تغيّر المقاس أو دوران الشاشة.
      builder: (context, child) {
        final tablet = MediaQuery.sizeOf(context).shortestSide >=
            Dimensions.tabletBreakpoint;
        return ScreenUtilInit(
          // حزمة التسليم فيها إطاران: 375×812 للجوال و834×1108 للتابلت،
          // وأحجام المكوّنات فيهما واحدة. فلو قِيس التابلت على إطار الجوال
          // تضخّم كل شيء إلى الضعف وانهار التخطيط.
          designSize: tablet ? const Size(834, 1108) : const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          // الافتراضي `FontSizeResolvers.width` يتجاهل `minTextAdapt` ويجعل
          // كل `.sp` يتمدّد مع عرض الشاشة. فيُشتقّ هنا من أصغر البُعدين
          // ويُحصر في نطاق ضيّق ليبقى للنص التناسب نفسه في كل جهاز.
          fontSizeResolver: (fontSize, instance) {
            final scale = math
                .min(instance.scaleWidth, instance.scaleHeight)
                .clamp(0.90, 1.12);
            return fontSize * scale;
          },
          child: MediaQuery(
            // قفل صارم: إعداد حجم الخط في الجهاز يجب ألّا يعيد قياس نصوص
            // التطبيق ولا يزيح تخطيطه.
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: EasyLoading.init()(context, child),
            ),
          ),
        );
      },
    );
  }

  void _configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..dismissOnTap = false
      ..indicatorColor = AppColors.primary
      ..maskColor = AppColors.primaryLight
      ..backgroundColor = Colors.transparent
      ..boxShadow = <BoxShadow>[]
      ..maskType = EasyLoadingMaskType.clear
      ..indicatorSize = 50
      ..contentPadding = EdgeInsets.zero
      ..textColor = Colors.white
      ..progressColor = AppColors.primary;
  }
}
