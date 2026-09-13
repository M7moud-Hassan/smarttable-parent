/// عنوان خادم Smartble — الموضع الوحيد الذي يُعرَف منه.
///
/// كان العنوان في موضعين — هنا وفي `AppConstants` — فيضبط كلٌّ منهما `baseUrl`
/// على dio، ويفوز الأخير. فكان تغيير العنوان هنا لا يصل إلى الطلبات ويظهر
/// «لا يوجد اتصال بالخادم» بلا سبب ظاهر. فصار المصدر واحدًا.
class Api {
  Api._();

  /// نطاق الخادم. يُضبط عند البناء ليُبدَّل بلا تعديل الملف:
  ///
  /// ```
  /// flutter run --dart-define=API_DOMAIN=http://10.0.2.2:8000/
  /// ```
  ///
  /// القيم المعتادة:
  ///
  /// | ما يشغّل التطبيق | النطاق |
  /// |---|---|
  /// | خادم الاختبار | `https://test.smartble.net/` |
  /// | محاكي أندرويد على خادم محلّي | `http://10.0.2.2:8000/` |
  /// | جهاز حقيقي على خادم محلّي | `http://192.168.x.x:8000/` |
  static const String domain = String.fromEnvironment(
    'API_DOMAIN',
    defaultValue: 'https://test.smartble.net/',
  );

  /// مسار واجهة تطبيق وليّ الأمر — وحدة `st_follower/parent_api` في الخادم.
  static const String prefix = 'follower-student/api/v1/';

  /// ما يُضبط على dio: النطاق ومسار الواجهة معًا، بشرطة مائلة واحدة بينهما.
  static String get baseUrl =>
      domain.endsWith('/') ? '$domain$prefix' : '$domain/$prefix';

  static const Duration timeout = Duration(seconds: 30);
}
