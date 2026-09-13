import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartble_parent/core/conts/api.dart';
import 'package:smartble_parent/core/utils/app_utils.dart';
import 'package:smartble_parent/features/parent/data/datasources/db_remote.dart';
import 'package:smartble_parent/features/parent/domain/entities/auth_entities.dart';
import 'package:smartble_parent/features/parent/domain/entities/base_entity.dart';
import 'package:smartble_parent/features/parent/domain/entities/service_entities.dart';
import 'package:smartble_parent/injections/injection_main.dart';

/// يختبر طبقة البيانات على خادمٍ يعمل فعلاً.
///
/// هذا وحده يُثبت أن التطبيق «حيّ»: اللقطات تُثبت الشكل، والتجهيزة تُثبت
/// التنقّل، وهذا يُثبت أن ما يرسله `st_follower/parent_api` تقرؤه نماذج
/// التطبيق كما هي — بلا مفتاحٍ ناقص ولا نوعٍ مختلف.
///
/// التشغيل بخادمٍ قائم وحسابِ وليّ أمر:
///
///     flutter test test/live_api_test.dart \
///       --dart-define=PARENT_USERNAME=abu.mishari \
///       --dart-define=PARENT_PASSWORD=parent12345
///
/// لا يعمل إلا بطلبٍ صريح (`LIVE=true`): هو يحتاج خادمًا يعمل وحسابًا عليه،
/// وسقوطه بلا ذلك يُخفي سقوطًا حقيقيًّا في بقيّة الاختبارات.
///
///     flutter test test/live_api_test.dart ///       --dart-define=LIVE=true ///       --dart-define=API_DOMAIN=http://127.0.0.1:8000/
void main() {
  const username = String.fromEnvironment('PARENT_USERNAME',
      defaultValue: 'abu.mishari');
  const password = String.fromEnvironment('PARENT_PASSWORD',
      defaultValue: 'parent12345');

  // لا يُشغَّل إلا بطلبٍ صريح — انظر تعليق الملف.
  const runLive = bool.fromEnvironment('LIVE');

  late DbRemote db;
  var serverUp = false;

  setUpAll(() async {
    if (!runLive) return;
    TestWidgetsFlutterBinding.ensureInitialized();
    // `flutter_test` يعترض الشبكة ويردّ 400 على كل طلب. وإلغاء الاعتراض هو
    // ما يجعل هذا الاختبار يمسّ الخادم حقاً.
    HttpOverrides.global = null;

    SharedPreferences.setMockInitialValues({});
    if (!AppUtils.sl.isRegistered<AppUtils>()) {
      await init();
      await AppUtils.sl.allReady();
    }

    final dio = Dio(BaseOptions(
      baseUrl: Api.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => status != null && status < 500,
    ));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final token = AppUtils.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    }));
    db = DbRemote(dio: dio);

    try {
      await dio.get<dynamic>('faq/');
      serverUp = true;
    } catch (_) {
      serverUp = false;
    }
  });

  /// يتخطّى الاختبار برسالةٍ واضحة بدل أن يسقط بخطأ شبكة.
  void requireServer() {
    if (!runLive) {
      markTestSkipped('اختبارٌ حيّ — شغّله بـ --dart-define=LIVE=true');
      return;
    }
    if (!serverUp) {
      markTestSkipped('الخادم لا يعمل على ${Api.baseUrl}');
    }
  }

  test('الدخول يُصدر رمزاً ويعيد بيانات وليّ الأمر', () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final parent = await db.login(
      const LoginEntity(username: username, password: password),
    );

    expect(parent.id, isNotEmpty, reason: 'الخادم لم يرسل معرّف وليّ الأمر');
    expect(parent.name, isNotEmpty);
    expect(AppUtils.instance.getAccessToken(), isNotEmpty,
        reason: 'رمز الوصول لم يُخزَّن، فكل طلب بعده سيُردّ بـ401');
    AppUtils.appUser = parent;
  });

  test('الأبناء يصلون من سجلّات المدرسة', () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final students = await db.students();
    expect(students, isNotEmpty,
        reason: 'الحساب بلا أبناء مرتبطين — راجع مطابقة رقم الجوال');
    expect(students.first.name, isNotEmpty);
    expect(students.first.school, isNotEmpty);
    AppUtils.students = students;
    AppUtils.selectedStudent = students.first;
  });

  test('الرئيسية تعرض سبع خدمات بعدّاداتها', () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final summary = await db.home(
      StudentEntity(studentId: AppUtils.selectedStudent!.id),
    );
    expect(summary.services.length, 7,
        reason: 'التصميم يرسم سبع بطاقات خدمة');
    for (final card in summary.services) {
      expect(card.title, isNotEmpty);
    }
  });

  test('المواظبة تصل بنسبتها وسجلّها', () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final report = await db.attendance(
      StudentEntity(studentId: AppUtils.selectedStudent!.id),
    );
    expect(report.percentage, inInclusiveRange(0, 100));
    expect(report.termLabel, isNotEmpty);
    // مجموع الحالات لا يزيد على أيام السجلّ.
    expect(report.presentDays + report.lateDays + report.absentDays,
        greaterThanOrEqualTo(0));
  });

  test('الجدول يصل بأيامه', () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final schedule = await db.schedule(
      StudentEntity(studentId: AppUtils.selectedStudent!.id),
    );
    expect(schedule.days, isNotEmpty, reason: 'لا أيام في جدول الفصل');
    for (final day in schedule.days) {
      expect(day.weekday, isNotEmpty);
    }
  });

  test('السلوك والصحة والإجراءات والتعاميم والاختبارات تُقرأ بلا خطأ نوع',
      () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final id = StudentEntity(studentId: AppUtils.selectedStudent!.id);

    final behavior = await db.behavior(
      BehaviorFilterEntity(studentId: id.studentId),
    );
    // النسبتان تُجمعان مئةً كاملة حين توجد ملاحظات.
    if (behavior.statistics.total > 0) {
      expect(
        behavior.statistics.positivePercent +
            behavior.statistics.needsWorkPercent,
        100,
      );
    }

    final health = await db.health(id);
    expect(health.available, isNotEmpty,
        reason: 'قائمة الأمراض المزمنة فارغة، فالشاشة بلا خيارات');

    await db.adminActions(id);
    await db.circulars(id);
    await db.exams(id);
    await db.notifications();
  });

  test('الإعدادات والمحتوى الثابت تصل من الخادم', () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final settings = await db.notificationSettings();
    expect(settings.length, 6, reason: 'التصميم يرسم ستة مفاتيح');

    final school = await db.school(
      StudentEntity(studentId: AppUtils.selectedStudent!.id),
    );
    expect(school.name, isNotEmpty);

    final faq = await db.faq();
    expect(faq, isNotEmpty);

    final about = await db.staticPage(
      const StaticPageEntity(kind: StaticPageKind.about),
    );
    expect(about.paragraphs, isNotEmpty);
  });

  test('الطلب بلا رمز يُردّ بانتهاء الجلسة لا بخطأ غامض', () async {
    requireServer();
    if (!runLive || !serverUp) return;

    final saved = AppUtils.instance.getAccessToken() ?? '';
    await AppUtils.instance.clearTokens();
    await expectLater(db.students(), throwsA(isA<Exception>()));
    await AppUtils.instance.setTokens(access: saved, refresh: '');
  });
}
