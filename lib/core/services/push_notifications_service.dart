import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart' show Level;

import '../../features/parent/presentation/pages/admin_actions_page.dart';
import '../../features/parent/presentation/pages/attendance_page.dart';
import '../../features/parent/presentation/pages/behavior_page.dart';
import '../../features/parent/presentation/pages/circulars_page.dart';
import '../../features/parent/presentation/pages/exams_page.dart';
import '../conts/api.dart';
import '../utils/app_utils.dart';

/// إشعارات تطبيق وليّ الأمر.
///
/// الخادم يرسل عند كل ما تسجّله المدرسة على الابن — غياب أو تأخّر، ملاحظة
/// سلوك، إجراء إداري، تعميم، موعد اختبار، ونتيجة عذر — من
/// `st_follower/parent_api/notify.py`، ويستهدف الجهاز بـ`fcm_token` المحفوظ
/// على `UserParent`.
///
/// فما ينقص هنا طرفُ الجهاز: الإذن، والرمز، وإرساله إلى
/// `auth/fcm-token/`، وعرض الإشعار وفتح شاشته. وبلا إرسال الرمز يبقى الحقل
/// فارغًا في قاعدة البيانات فلا يصل شيء مهما أرسل الخادم.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // خيط منفصل بلا حاقن ولا واجهة: النظام يعرض الإشعار بنفسه في الخلفية.
  debugPrint('FCM background: ${message.notification?.title}');
}

class PushNotificationsService {
  PushNotificationsService._();

  static final PushNotificationsService instance = PushNotificationsService._();

  /// سقفٌ لكل نداء يعبر قناة المنصّة أو الشبكة: الخدمة تعمل بعد ظهور الشاشة،
  /// ولا يصحّ أن يبقى نداءٌ منها معلّقًا يستهلك الجهاز بلا نهاية.
  static const Duration _timeout = Duration(seconds: 15);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'parent_high_importance',
    'إشعارات المدرسة',
    description: 'الغياب والسلوك والإجراءات والتعاميم ومواعيد الاختبارات',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _token;
  bool _initialized = false;
  bool _syncing = false;

  String? get token => _token;

  /// تُستدعى مرة واحدة بعد الإقلاع.
  ///
  /// لا ترمي: تطبيقٌ بلا إشعارات أهون من تطبيقٍ لا يفتح لأن ملف إعدادات
  /// Firebase ناقص أو الجهاز بلا خدمات Google.
  Future<void> init() async {
    if (_initialized) return;
    try {
      // بمهلة: على جهاز بلا خدمات Google لا ترمي التهيئة بل تتعلّق، وبلا
      // مهلة يبقى المستدعي معلّقًا معها.
      await Firebase.initializeApp().timeout(_timeout);

      // الإذن أولًا وعبر Firebase وحده: `flutter_local_notifications` يطلب
      // على iOS إذن عرضٍ محلّي لا يستدعي `registerForRemoteNotifications`،
      // فإن سبق طلبَ Firebase وجده ممنوحًا فلم يسجّل الجهاز لدى APNs — فتظهر
      // النافذة، ويوافق المستخدم، ولا يصل إشعارٌ واحد.
      await _requestPermission().timeout(_timeout);
      await _initLocalNotifications().timeout(_timeout);
      await _initHandlers().timeout(_timeout);
      _initialized = true;

      // لا يُنتظر: تسجيل الرمز طلبُ شبكةٍ خلفيّ، وانتظاره يطيل الإقلاع.
      unawaited(syncToken());
    } catch (error) {
      AppUtils.log('تعذّرت تهيئة الإشعارات: $error', levelLog: Level.error);
    }
  }

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppUtils.log('إذن الإشعارات: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // بلا طلب إذن: Firebase طلبه قبل قليل، وهو وحده من يسجّل لدى APNs.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) =>
          _openTarget(response.payload),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _initHandlers() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _openTarget(message.data['action_id']?.toString()),
    );

    // التطبيق كان مغلقًا وفُتح من الإشعار: الشجرة لم تُبنَ بعد، فيؤجَّل
    // الانتقال إلى ما بعد أول إطار وإلا ضاع في الفراغ.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(
          const Duration(seconds: 1),
          () => _openTarget(initial.data['action_id']?.toString()),
        );
      });
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fresh) {
      _token = fresh;
      unawaited(syncToken());
    });
  }

  /// أندرويد لا يعرض إشعار FCM والتطبيق مفتوح، فيُبنى محليًّا.
  void _showForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    // iOS يعرضه بنفسه بعد `setForegroundNotificationPresentationOptions`،
    // فبناء إشعارٍ محلّي فوقه يُظهره مرّتين.
    if (Platform.isIOS) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['action_id']?.toString(),
    );
  }

  /// `action_id` يصل بالصيغة `<موضوع>_<معرّف>`، ولكلٍّ شاشته:
  ///
  ///   `attendance_<id>` · `excuse_<id>` → تقرير المواظبة
  ///   `behavior_<id>`                   → تقرير السلوك
  ///   `procedure_<id>`                  → الإجراءات الإدارية
  ///   `circular_<id>`                   → التعاميم
  ///   `exam_<id>`                       → مواعيد الاختبارات
  ///
  /// تُفتح الشاشات على قوائمها لا على السجلّ بعينه: وليّ الأمر يصل إليه منها،
  /// وفتحه مباشرةً يحتاج جلبَه أوّلًا وقد يكون حُذف قبل فتح الإشعار.
  void _openTarget(String? actionId) {
    if (actionId == null || actionId.isEmpty) return;
    if (actionId.startsWith('attendance_') || actionId.startsWith('excuse_')) {
      AppUtils.go(const AttendancePage());
    } else if (actionId.startsWith('behavior_')) {
      AppUtils.go(const BehaviorPage());
    } else if (actionId.startsWith('procedure_')) {
      AppUtils.go(const AdminActionsPage());
    } else if (actionId.startsWith('circular_')) {
      AppUtils.go(const CircularsPage());
    } else if (actionId.startsWith('exam_')) {
      AppUtils.go(const ExamsPage());
    }
  }

  /// يرسل رمز الجهاز إلى الخادم.
  ///
  /// تُستدعى عند الإقلاع وبعد تسجيل الدخول وعند تجديد الرمز — والرمز يتغيّر
  /// بإعادة تثبيت التطبيق أو مسح بياناته.
  Future<void> syncToken() async {
    // `init` و«الدخول» كلاهما يستدعيها، وقد يتزامنان عند أول دخول.
    if (_syncing) return;
    _syncing = true;
    try {
      await _syncToken();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncToken() async {
    final access = AppUtils.instance.getAccessToken();
    if (access == null || access.isEmpty) {
      // بلا جلسة لا يُعرف صاحب الجهاز، فيُؤجَّل إلى ما بعد الدخول.
      return;
    }

    try {
      if (Platform.isIOS) {
        final apns = await _awaitApnsToken();
        if (apns == null) {
          // أشهر أسبابه: خاصية Push غير مفعّلة على الـ App ID، أو الـ
          // provisioning profile بلا الـ entitlement. ونافذة الإذن تظهر في
          // الحالتين، فظهورها ليس دليلًا على نجاح التسجيل.
          AppUtils.log('رمز APNs لم يصدر — تسجيل الجهاز لدى أبل فشل.',
              levelLog: Level.error);
          return;
        }
      }

      _token ??= await FirebaseMessaging.instance
          .getToken()
          .timeout(_timeout, onTimeout: () => null);
      if (_token == null || _token!.isEmpty) {
        AppUtils.log('Firebase لم يُصدر رمز FCM.', levelLog: Level.error);
        return;
      }

      // Dio مستقلّ عن `DioConfig`: ذاك يُظهر مؤشّر التحميل ورسائل الخطأ لكل
      // طلبٍ غير GET، ولا يصحّ أن يُغرق المستخدمَ تسجيلٌ صامت في الخلفية.
      final dio = Dio(BaseOptions(
        baseUrl: Api.baseUrl,
        connectTimeout: Api.timeout,
        receiveTimeout: Api.timeout,
        headers: {'Authorization': 'Bearer $access'},
      ));

      await dio.post<dynamic>('auth/fcm-token/', data: {
        'fcm_token': _token,
        'lang_code': AppUtils.instance.getLocale().languageCode,
      });
      AppUtils.log('سُجّل رمز الإشعارات لدى الخادم.');
    } catch (error) {
      AppUtils.log('تعذّر تسجيل رمز الإشعارات: $error', levelLog: Level.error);
    }
  }

  /// ينتظر رمز APNs بمحاولاتٍ قصيرة متتابعة.
  ///
  /// النظام لا يسلّمه فور الإذن: يحتاج ذهابًا وإيابًا مع خوادم أبل قد يتجاوز
  /// الثواني على شبكةٍ بطيئة. وانتظارٌ واحدٌ ثابت كان يمرّ قبل وصوله فيعود
  /// `getToken` بـ null ولا يُسجَّل الجهاز حتى تُشغَّل النسخة مرة أخرى.
  Future<String?> _awaitApnsToken() async {
    for (var attempt = 0; attempt < 6; attempt++) {
      final token = await FirebaseMessaging.instance
          .getAPNSToken()
          .timeout(_timeout, onTimeout: () => null);
      if (token != null && token.isNotEmpty) return token;
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }
}
