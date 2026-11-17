import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartble_parent/core/share/inputs/otp_field.dart';

/// الرمز رقمٌ يُقرأ من اليسار وإن كانت الواجهة عربية. والاختبار يضع الودجت
/// داخل واجهةٍ RTL كحالها في التطبيق، لأن العطب لا يظهر إلا هناك.
void main() {
  testWidgets('خانات الرمز تُرتّب وتُكتب من اليسار داخل واجهة عربية',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(375, 812);
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await tester.binding.setSurfaceSize(null);
    });

    var code = '';
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => MaterialApp(
            locale: const Locale('ar', 'SA'),
            home: Scaffold(body: OtpField(onChanged: (v) => code = v)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));

    // الخانة الأولى هي الأقصى يساراً على الشاشة، لا الأقصى يميناً.
    final centers = <double>[
      for (var i = 0; i < 4; i++) tester.getCenter(fields.at(i)).dx,
    ];
    for (var i = 1; i < centers.length; i++) {
      expect(
        centers[i],
        greaterThan(centers[i - 1]),
        reason: 'الخانة رقم $i يجب أن تقع يمين التي قبلها على الشاشة',
      );
    }

    // الكتابة بترتيب القراءة تُنتج الرمز كما وصل في الرسالة لا مقلوباً.
    const digits = ['5', '8', '3', '1'];
    for (var i = 0; i < digits.length; i++) {
      await tester.enterText(fields.at(i), digits[i]);
      await tester.pump();
    }
    expect(code, '5831');
  });

  /// رسالة الرمز تُرشد إلى البدء بالخانة اليمنى، وهو ما يحتاجه الإصدار
  /// المنشور. والاختبار يتبع الإرشاد حرفياً على النسخة المصحَّحة: النقر يُصرف
  /// إلى أوّل خانةٍ فارغة، فتُكتب الأرقام بترتيبها ولا يقف المستخدم.
  testWidgets('اتّباع إرشاد «ابدأ بالخانة اليمنى» يعمل على النسخة المصحّحة',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(375, 812);
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await tester.binding.setSurfaceSize(null);
    });

    var code = '';
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => MaterialApp(
            locale: const Locale('ar', 'SA'),
            home: Scaffold(body: OtpField(onChanged: (v) => code = v)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    // الخانة الأقصى يميناً بعد الإصلاح هي الأخيرة لا الأولى.
    final xs = [for (var i = 0; i < 4; i++) tester.getCenter(fields.at(i)).dx];
    final rightmost = xs.indexOf(xs.reduce((a, b) => a > b ? a : b));
    expect(rightmost, 3);

    // النقر كما يفعل المستخدم، لا `enterText` على خانةٍ بعينها: تلك تُركّز
    // الخانة مباشرةً فتتجاوز التحويل الذي هو موضع الاختبار.
    await tester.tap(fields.at(rightmost));
    await tester.pump();

    for (final digit in ['5', '8', '3', '1']) {
      tester.testTextInput.enterText(digit);
      await tester.pump();
    }

    // الأرقام بترتيب الرسالة، والخانات الأربع ممتلئة فيُفعَّل الزرّ.
    expect(code, '5831');
  });
}
