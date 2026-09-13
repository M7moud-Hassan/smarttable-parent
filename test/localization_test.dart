import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartble_parent/core/conts/app_constants.dart';
import 'package:smartble_parent/core/conts/text.dart';
import 'package:smartble_parent/core/enums/attendance_status.dart';
import 'package:smartble_parent/core/enums/note_type.dart';

/// اللغتان العربية والإنجليزية.
///
/// `AppText` صار مفاتيحَ تُقرأ من `assets/lang`، وسقوطُ مفتاحٍ من أحد
/// الملفّين لا يُسقط الترجمة بل يعرض اسم المفتاح نفسه على الشاشة — عطبٌ صامت
/// لا يظهر إلا لمن يبدّل اللغة ويقرأ. فيُفحص هنا.
void main() {
  late Map<String, dynamic> arabic;
  late Map<String, dynamic> english;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    arabic = jsonDecode(
      File('assets/lang/ar-SA.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    english = jsonDecode(
      File('assets/lang/en-US.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  test('الملفّان يحملان المفاتيح نفسها', () {
    final missingInEnglish = arabic.keys.where((k) => !english.containsKey(k));
    final missingInArabic = english.keys.where((k) => !arabic.containsKey(k));

    expect(missingInEnglish, isEmpty,
        reason: 'مفاتيح بلا ترجمة إنجليزية — ستظهر باسمها على الشاشة');
    expect(missingInArabic, isEmpty,
        reason: 'مفاتيح بلا نصّ عربي');
  });

  test('لا قيمة فارغة في أي لغة', () {
    for (final entry in arabic.entries) {
      expect('${entry.value}', isNotEmpty, reason: 'العربية: ${entry.key}');
    }
    for (final entry in english.entries) {
      expect('${entry.value}', isNotEmpty, reason: 'الإنجليزية: ${entry.key}');
    }
  });

  test('كل مفتاح يستعمله AppText موجود في الملفّين', () {
    // `AppText` كلّه خصائص تقرأ مفتاحًا باسمها، فأسماء المفاتيح هي أسماؤها.
    final source = File('lib/core/conts/text.dart').readAsStringSync();
    final keys = RegExp(r"static String get \w+ => '(\w+)'\.tr\(\);")
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();

    expect(keys, isNotEmpty, reason: 'لم تُقرأ مفاتيح AppText');
    for (final key in keys) {
      expect(arabic.containsKey(key), isTrue, reason: 'ناقص بالعربية: $key');
      expect(english.containsKey(key), isTrue, reason: 'ناقص بالإنجليزية: $key');
    }
  });

  testWidgets('النصوص تتبدّل بتبديل اللغة', (tester) async {
    late BuildContext captured;

    await tester.pumpWidget(EasyLocalization(
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      path: AppConstants.pathTranslate,
      startLocale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      child: Builder(builder: (context) {
        captured = context;
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: const SizedBox.shrink(),
        );
      }),
    ));
    await tester.pumpAndSettle();

    expect(AppText.login, arabic['login']);
    expect(AttendanceStatus.absent.label, arabic['statusAbsent']);
    expect(BehaviorNoteType.positive.label, arabic['notePositive']);

    await captured.setLocale(const Locale('en', 'US'));
    await tester.pumpAndSettle();

    expect(AppText.login, english['login'],
        reason: 'النصّ لم يتبدّل — المفتاح لا يُقرأ من الملفّ');
    expect(AttendanceStatus.absent.label, english['statusAbsent'],
        reason: 'حالات المواظبة بقيت عربية بعد تبديل اللغة');
    expect(BehaviorNoteType.positive.label, english['notePositive'],
        reason: 'أنواع الملاحظات بقيت عربية بعد تبديل اللغة');
  });
}
