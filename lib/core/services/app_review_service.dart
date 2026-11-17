import 'dart:async';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart' show Level;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_utils.dart';

/// طلب التقييم من داخل التطبيق: `SKStoreReviewController` في iOS وواجهة
/// `In-App Review` في أندرويد، تستدعيهما حزمة `in_app_review`.
///
/// ما لا يُفعل هنا مقصودٌ كالمفعول:
///
/// * **لا سؤال قبلها** من نوع «هل أنت راضٍ؟» ثم تُعرض النافذة للراضي وحده.
///   هذا ترشيحٌ للمقيّمين، وهو ممنوع في الشرط 1.1.1 من مراجعة آبل وفي سياسة
///   جوجل للتقييمات.
/// * **لا مكافأة** ولا نقاط ولا ميزة تُفتح بالتقييم، للسبب نفسه.
/// * **لا نافذة من عندنا** بأي شكل: النافذة التي تظهر هي نافذة المتجر نفسها،
///   لا نملك نصّها ولا أزرارها ولا نعرف ما اختاره المستخدم فيها.
///
/// والمتجران يحدّان عدد مرات الظهور — آبل ثلاثًا في السنة، وجوجل بحصّةٍ لا
/// تُعلن — ويتجاهلان ما زاد **بلا أي إشعار للتطبيق**. فالطلب رصيدٌ شحيح لا
/// يُصرف إلا في لحظة رضا: بعد ثلاثة أيام مختلفة من الاستخدام، وعقب مهمة تمّت
/// بنجاح، ولا بعد خطأ، ولا في أول فتح.
///
/// في التطوير لا تظهر النافذة عادةً: أندرويد يشترط نسخةً مثبّتة من Play،
/// وiOS لا يعرضها في بناء Debug إلا أحيانًا. فاختبارها يكون من TestFlight ومن
/// مسار الاختبار الداخلي في Play Console.
class AppReviewService with WidgetsBindingObserver {
  AppReviewService._();

  /// نسخةٌ واحدة: الحالة التي تُقرأ هنا — آخر خطأ، وحال التطبيق — عابرةٌ بين
  /// الشاشات، فلا تصلح أن تُبنى مع كل شاشة من جديد.
  static final AppReviewService instance = AppReviewService._();

  final InAppReview _review = InAppReview.instance;

  // ─── مفاتيح التخزين ──────────────────────────────────────────────────────
  // لا تُمحى مع الخروج من الحساب: هي سجلّ هذا الجهاز لا سجلّ الجلسة، ومحوها
  // يجعل الخروجَ والدخولَ طريقًا لإعادة عرض النافذة.
  static const _keyOpenDays = 'review_open_days';
  static const _keyFirstDay = 'review_first_open_day';
  static const _keyLastRequestDay = 'review_last_request_day';
  static const _keyLastRequestBuild = 'review_last_request_build';

  /// «ثلاثة أيام مختلفة» — لا ثلاث مرات في يوم واحد.
  static const _requiredOpenDays = 3;

  /// ما بين طلبين. آبل تسمح بثلاثة في السنة، ونحن نطلب أقلّ: من رأى النافذة
  /// ولم يقيّم اختار ألّا يفعل، وإلحاحٌ كل شهر يُقرأ مضايقةً لا دعوة.
  static const _minDaysBetweenRequests = 120;

  /// نافذة صمتٍ بعد أي خطأ. مَن رأى رسالة فشل قبل دقائق لم يخرج بعدُ من
  /// أثرها، ولو نجحت مهمته التالية.
  static const _silenceAfterFailure = Duration(minutes: 10);

  /// يُترك للنجاح وقتٌ يُرى فيه: رسالة «تم الإرسال» تظهر، والشاشة تستقرّ، ثم
  /// تأتي نافذة المتجر. وبلا هذه المهلة تتصادم النافذتان فلا تظهر إحداهما.
  static const _settleDelay = Duration(milliseconds: 900);

  DateTime? _lastFailureAt;
  AppLifecycleState? _lifecycle;
  bool _attached = false;
  bool _busy = false;

  // ─── التركيب ─────────────────────────────────────────────────────────────

  /// يُنادى مرّة واحدة عند الإقلاع، بعد تهيئة الـ binding.
  ///
  /// يسجّل يوم الفتح، ويراقب حال التطبيق لأمرين: تسجيل يوم جديد لمن أبقى
  /// التطبيق في الخلفية ليالٍ ثم عاد إليه، ومنعُ إطلاق النافذة ونحن في
  /// الخلفية — فـ iOS يُسقطها صامتةً ويُحسب الطلب مصروفًا.
  void attach() {
    if (_attached) return;
    _attached = true;
    _lifecycle = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
    unawaited(recordOpen());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final returning = _lifecycle != AppLifecycleState.resumed &&
        state == AppLifecycleState.resumed;
    _lifecycle = state;
    if (returning) unawaited(recordOpen());
  }

  // ─── ما تنادِيه بقيّة الشاشات ────────────────────────────────────────────

  /// يسجّل أن التطبيق فُتح اليوم. تكراره في اليوم نفسه لا يزيد شيئًا.
  Future<void> recordOpen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _stamp(DateTime.now());
      final days = prefs.getStringList(_keyOpenDays) ?? const <String>[];
      if (days.contains(today)) return;

      // أول يوم يُحفظ وحده ولا يُمسّ بعدها: به وحده نعرف أن اليوم ليس أول
      // فتحٍ للتطبيق.
      if (prefs.getString(_keyFirstDay) == null) {
        await prefs.setString(_keyFirstDay, today);
      }

      // لا يُحفظ من الأيام أكثر ممّا يُسأل عنه: ثلاثة تكفي للشرط، فلا تنمو
      // القائمة بلا حدّ مع السنين.
      final updated = [...days, today];
      await prefs.setStringList(
        _keyOpenDays,
        updated.length > _requiredOpenDays
            ? updated.sublist(updated.length - _requiredOpenDays)
            : updated,
      );
    } catch (error) {
      // تخزينٌ تعذّر لا يصحّ أن يُسقط شاشة: أسوأ ما يحدث أن يتأخّر الطلب.
      AppUtils.log('تعذّر تسجيل يوم الفتح للتقييم: $error');
    }
  }

  /// يُعلم الخدمة أن المستخدم رأى خطأً أو فشلًا الآن.
  ///
  /// مربوطة بمعرض رسائل الفشل وبمُعالِجَي الأخطاء في `main`، فلا يبقى على كل
  /// شاشةٍ أن تتذكّر ذلك عن نفسها.
  void noteFailure() => _lastFailureAt = DateTime.now();

  /// لحظة الرضا: مهمةٌ تمّت بنجاح. تُنادى بعد نجاحٍ مؤكَّد لا بعد إرسال الطلب.
  ///
  /// [task] للسجلّ وحده، ليُعرف أي مهمة فتحت الباب عند قراءة اللوج.
  Future<void> requestAfterSuccess({required String task}) async {
    // نداءان متقاربان من شاشتين لا يصرفان طلبين.
    if (_busy) return;
    _busy = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final blocker = await _blocker(prefs);
      if (blocker != null) {
        AppUtils.log('تقييم: لا طلب بعد «$task» — $blocker');
        return;
      }

      await Future.delayed(_settleDelay);
      // قد يغيب التطبيق خلال المهلة، أو يظهر خطأ في أثنائها.
      if (_lifecycle != AppLifecycleState.resumed) return;
      if (_recentFailure) return;

      // يُسجَّل الصرف قبل العرض لا بعده: النافذة قد تُستهلك من حصّة المتجر ولا
      // تظهر ولا يُخبرنا أحد، فلو انتظرنا جوابًا لا يأتي لأعدنا الطلب مع كل
      // مهمة ناجحة تالية.
      await prefs.setString(_keyLastRequestDay, _stamp(DateTime.now()));
      await prefs.setString(_keyLastRequestBuild, await _build());
      await _review.requestReview();
      AppUtils.log('تقييم: طُلب بعد «$task»');
    } catch (error) {
      AppUtils.log('تعذّر طلب التقييم: $error', levelLog: Level.error);
    } finally {
      _busy = false;
    }
  }

  // ─── الشروط ──────────────────────────────────────────────────────────────

  /// يعود بسبب المنع، أو `null` إن كان الطلب مستحقًّا.
  ///
  /// سببٌ مكتوب لا `bool`: قراءة «أيام الفتح 2/3» في اللوج تُغني عن تتبّع
  /// الشروط واحدًا واحدًا عند السؤال: لِمَ لا تظهر النافذة؟
  Future<String?> _blocker(SharedPreferences prefs) async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return 'منصّة بلا نافذة تقييم';
    }

    // غير الداخل ليس عنده ما يُقيَّم: لم يرَ من التطبيق إلا شاشة الدخول.
    if (AppUtils.instance.getLogin() == null) return 'لا جلسة';

    if (_recentFailure) return 'خطأ قريب';

    final today = _stamp(DateTime.now());
    final days = prefs.getStringList(_keyOpenDays) ?? const <String>[];
    if (days.length < _requiredOpenDays) {
      return 'أيام الفتح ${days.length}/$_requiredOpenDays';
    }

    // شرطٌ مستقلّ عن العدّ: لو مُحيت بيانات التطبيق أو نُقل إلى جهاز جديد فهذا
    // أول فتحٍ هنا، ولا تُستقبل النافذة في أول فتح.
    if ((prefs.getString(_keyFirstDay) ?? today) == today) return 'أول فتح';

    final last = _parse(prefs.getString(_keyLastRequestDay));
    if (last != null) {
      // الساعة قد تُؤخَّر في الجهاز فيصير الفرق سالبًا: يُمنع لا يُسمح.
      final passed = DateTime.now().difference(last).inDays;
      if (passed < _minDaysBetweenRequests) return 'طُلب قبل $passed يومًا';
    }

    // ولا مرّتين على البناء نفسه: من رأى النافذة على هذه النسخة رآها على كل
    // ما فيها.
    final build = await _build();
    if (build.isNotEmpty && prefs.getString(_keyLastRequestBuild) == build) {
      return 'طُلب على البناء $build';
    }

    if (!await _review.isAvailable()) return 'النافذة غير متاحة';

    return null;
  }

  bool get _recentFailure {
    final at = _lastFailureAt;
    if (at == null) return false;
    return DateTime.now().difference(at) < _silenceAfterFailure;
  }

  /// رقم البناء من المنصّة — عدّادٌ لا يتكرّر، بخلاف رقم الإصدار الذي قد
  /// يُبنى مرّات.
  Future<String> _build() async {
    try {
      return (await PackageInfo.fromPlatform()).buildNumber;
    } catch (_) {
      return '';
    }
  }

  /// `yyyy-MM-dd` بالتوقيت المحلّي: «يوم مختلف» عند المستخدم هو يومُ تقويمه.
  static String _stamp(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime? _parse(String? stamp) =>
      stamp == null ? null : DateTime.tryParse(stamp);
}
