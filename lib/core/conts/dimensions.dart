import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد متكررة في التصميم. أسماؤها تصف موضعها لا قيمتها، فتغيّرها مع التصميم.
class Dimensions {
  Dimensions._();

  /// الهامش الأفقي لجسم كل شاشة.
  static double get screenPadding => 24.w;

  /// ارتفاع ترويسة الشاشات الداخلية.
  static double get headerHeight => 48.h;

  /// ارتفاع الشريط السفلي.
  static double get bottomBarHeight => 58.h;

  /// ارتفاع الحقل.
  static double get fieldHeight => 48.h;

  /// ارتفاع الزر الرئيسي.
  static double get buttonHeight => 50.h;

  /// ارتفاع الزر الثانوي.
  static double get smallButtonHeight => 36.h;

  /// زوايا البطاقة.
  static double get cardRadius => 10.r;
  static double get cardRadiusSmall => 8.r;

  /// زوايا الأزرار (pill).
  static double get pillRadius => 24.r;

  /// عرض الشريط الجانبي في نسخة التابلت.
  static double get sidebarWidth => 268.0;

  /// العرض الذي يتحوّل عنده التطبيق إلى تخطيط التابلت.
  static const double tabletBreakpoint = 700;
}
