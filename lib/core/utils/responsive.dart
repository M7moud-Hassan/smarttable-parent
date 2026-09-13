import 'package:flutter/widgets.dart';

import '../conts/dimensions.dart';

/// نسخة التابلت (شاشة B4) تختلف عن الجوال في الشريط الجانبي وعدد أعمدة
/// الخدمات فقط، فتُقاس هنا مرة ويقرأها كل من يحتاجها.
class Responsive {
  Responsive._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Dimensions.tabletBreakpoint;

  /// عدد أعمدة شبكة الخدمات في الرئيسية: عمودان في الجوال وثلاثة في التابلت.
  static int servicesColumns(BuildContext context) => isTablet(context) ? 3 : 2;
}
