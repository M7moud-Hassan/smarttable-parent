/// ثوابت التطبيق التي لا تخصّ شاشة بعينها.
class AppConstants {
  AppConstants._();

  static const String appName = 'الجدول الذكي — ولي الأمر';
  static const String appNameShort = 'الجدول الذكي';
  static const String appRole = 'تطبيق ولي الأمر';
  static const String wordmark = 'smartble';
  static const String version = '1.0.0';

  static const String storeLink = 'apps.smartble.sa/parent';

  static const String pathTranslate = 'assets/lang';

// عنوان الخادم ومهلته في `Api` — موضع واحد لا يتكرّر.

  // مفاتيح التخزين المحلي
  static const String keyUser = 'parent_user';
  static const String keyLogin = 'parent_login';
  static const String keyLocale = 'parent_locale';
  static const String keySelectedStudent = 'parent_selected_student';
  static const String keyNotificationSettings = 'parent_notification_settings';
  static const String keyOnboardingSeen = 'parent_onboarding_seen';
  static const String keyAccessToken = 'parent_access_token';
  static const String keyRefreshToken = 'parent_refresh_token';

  /// مدة بقاء شاشة البداية قبل الانتقال — «After Delay 2000ms» في التصميم.
  static const Duration splashDelay = Duration(seconds: 2);
}
