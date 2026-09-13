import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../features/parent/data/models/parent_model.dart';
import '../../features/parent/data/models/student_model.dart';
import '../../features/parent/domain/entities/login_entity.dart';
import '../enums/snack_bar_type_enum.dart';

/// الواجهة التي تمرّ منها حالة التطبيق العامّة: المستخدم، اللغة، الطالب
/// المختار، والسجل. تنفيذها في `AppUtilsImp`.
abstract class AppUtils {
  static bool netConnect = true;
  static final GetIt sl = GetIt.instance;
  static AppUtils get instance => sl<AppUtils>();

  static late BuildContext contextApp;

  /// ولي الأمر الحالي — يُقرأ مرة عند الإقلاع.
  static ParentUser? appUser;

  /// أبناء ولي الأمر. تُملأ مرة عند الدخول وتقرأها الشاشات والشريط الجانبي.
  static List<Student> students = [];

  /// الطالب المعروضة بياناته الآن. كل شاشة خدمة تقرأ منه.
  static Student? selectedStudent;

  /// رقم الجوال الذي يمرّ بين شاشات التسجيل واستعادة كلمة المرور.
  ///
  /// يعيش في الذاكرة لا في التخزين: هو خطوةٌ في مسارٍ يبدأ وينتهي في الجلسة،
  /// وحفظه يجعل رقمًا أُدخل بالخطأ يبقى بعد إغلاق التطبيق.
  static String pendingPhone = '';

  /// يثبّت الطالب المختار ويحفظ اختياره ليعود إليه التطبيق بعد إغلاقه.
  static Future<void> selectStudent(Student student) async {
    selectedStudent = student;
    await instance.setSelectedStudentId(student.id);
  }

  static final logger = Logger();

  static void log(String log, {Level levelLog = Level.info}) {
    logger.log(levelLog, log);
  }

  /// يعزل نصّاً لاتينيّ الاتجاه داخل فقرة عربية.
  ///
  /// بلا العزل ينقلب «+966 55 123 4567» إلى «4567 123 55 966+» لأن خوارزمية
  /// الاتجاه تقرأ الرقم في سياق الفقرة لا في سياقه. والحزمة المُسلَّمة تفعل
  /// الشيء نفسه: نصوصها تحيط الأرقام بعلامات عزل.
  static String ltr(String text) => '\u2066$text\u2069';

  /// يعزل نصّاً قادماً من الخادم ويترك اتجاهه لأول حرف قويّ فيه.
  ///
  /// يصلح لقيمة لا يُعرف اتجاهها سلفاً — رقم هاتف أو بريد أو عنوان — فلا
  /// تُفرض عليها جهة خاطئة ولا تتسرّب إلى ترتيب ما حولها.
  static String isolate(String text) => '\u2068$text\u2069';

  /// يحوّل الأرقام العربية الشرقية إلى غربية ليقبلها `int.parse`.
  static String convertToWesternNumerals(String input) {
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    const western = '0123456789';
    return input.split('').map((char) {
      final index = eastern.indexOf(char);
      return index != -1 ? western[index] : char;
    }).join();
  }

  static List<T> generateList<T>(List<dynamic> data, Function fromJson) {
    final list = <T>[];
    for (final item in data) {
      list.add(fromJson(item));
    }
    return list;
  }

  /// اسم المسار مشتقّاً من نوع الشاشة نفسها.
  ///
  /// لولا تمريره لسمّى `Get.to(() => page)` المسار بنوع الدالة المغلقة، وهو
  /// `Widget Function()` في كل نداء لأن الوسيط معلَن `Widget` فيضيع نوع الشاشة
  /// عند الترجمة. فتتساوى أسماء المسارات كلها عند `/Widget`، ويرى
  /// `preventDuplicates` أن الوجهة هي الشاشة المعروضة فيُلغي الانتقال ويعيد
  /// `null` صامتاً — فلا تُفتح أي شاشة بعد أول انتقال.
  static String _routeName(Widget page) => '/${page.runtimeType}';

  static void go(Widget page) => Get.to(() => page, routeName: _routeName(page));

  /// كـ `go` لكنها تُنتظر إلى أن تُغلق الشاشة — لمن يحدّث حالته بعد العودة.
  static Future<T?> goWait<T>(Widget page) async =>
      await Get.to<T>(() => page, routeName: _routeName(page));

  static void goAndReplace(Widget page) =>
      Get.offAll(() => page, routeName: _routeName(page));

  static void back<T>([T? result]) => Get.back<T>(result: result);

  static String formatTime(String time) {
    final parts = time.split(':');
    final dateTime = DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String latestMessage = '';

  static void showCustomSnackbar(String message, SnackType type, {String title = ''}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // نفس الرسالة مرتين متتاليتين تُعرض مرة واحدة، وإلا تراكمت الإشعارات
      // على الشاشة عند تكرار الفشل.
      if (latestMessage == message) {
        Future.delayed(const Duration(seconds: 10), () => latestMessage = '');
        return;
      }
      latestMessage = message;
      Get.snackbar(
        title,
        message,
        titleText: title.isEmpty
            ? const SizedBox.shrink()
            : Text(title, style: const TextStyle(color: Colors.white)),
        snackPosition: SnackPosition.TOP,
        forwardAnimationCurve: Curves.easeInOutCubic,
        reverseAnimationCurve: Curves.easeInOutCubic,
        backgroundColor: type == SnackType.FAILURE ? Colors.red : Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        icon: Icon(
          type == SnackType.FAILURE ? Icons.error : Icons.check_circle,
          color: Colors.white,
        ),
        duration: const Duration(milliseconds: 3000),
      );
    });
  }

  // ─── ما تنفّذه `AppUtilsImp` ─────────────────────────────────────────────
  Future<void> setUser(ParentUser user);
  ParentUser? getUser();

  Locale getLocale();
  void setLocale(String languageCode, String countryCode);

  Future<void> login(LoginEntity entity);
  LoginEntity? getLogin();
  Future<void> logout();

  Future<void> setSelectedStudentId(String id);
  String? getSelectedStudentId();

  Future<void> setOnboardingSeen();
  bool getOnboardingSeen();

  /// رمزا الوصول والتحديث — يُرسل الأول في ترويسة كل طلب.
  Future<void> setTokens({required String access, required String refresh});
  String? getAccessToken();
  String? getRefreshToken();
  Future<void> clearTokens();

  Future<void> setNotificationSettings(Map<String, bool> settings);
  Map<String, bool>? getNotificationSettings();
}
