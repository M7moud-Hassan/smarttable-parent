import 'package:flutter/material.dart';

/// ألوان التصميم كما وردت في حزمة التسليم (`styles.css` وجدول الـ Design Tokens).
/// كل قيمة هنا مأخوذة حرفياً من الشاشات، فلا تُعدَّل إلا بتعديل التصميم نفسه.
class AppColors {
  AppColors._();

  // ─── الهوية ───────────────────────────────────────────────────────────────
  /// الهيدر، الأزرار الرئيسية، الوصلات.
  static const Color primary = Color(0xFF44C4C5);

  /// عناوين الشاشات، التسميات، الروابط.
  static const Color primaryDark = Color(0xFF3C9AA6);

  /// خلفيات التنبيهات والأيقونات.
  static const Color primarySoft = Color(0xFFE2F6F5);

  /// زر معطّل / حدود الحقول الخفيفة.
  static const Color primaryLight = Color(0xFFB4E7E8);

  /// بطاقة «الحصة الحالية» وترويسة تفاصيل الاختبار.
  static const Color primaryDeep = Color(0xFF4CB8B9);

  /// التبويب النشط في الشريط السفلي.
  static const Color tabActive = Color(0xFF138D80);

  // ─── النصوص ───────────────────────────────────────────────────────────────
  static const Color text = Color(0xFF141218);
  static const Color textMuted = Color(0xFF969696);
  static const Color textFaint = Color(0xFFA1A1A1);
  static const Color textDark = Color(0xFF222222);
  static const Color textPlaceholder = Color(0xFFB4B4B4);

  // ─── الحالات ──────────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFEA4545);
  static const Color dangerSoft = Color(0xFFFEF0F0);
  static const Color dangerText = Color(0xFFC0453C);

  static const Color warning = Color(0xFFBD5126);
  static const Color warningSoft = Color(0xFFFEF7EE);
  static const Color warningDeep = Color(0xFFFBF3E4);
  static const Color warningIcon = Color(0xFFFFBA0C);
  static const Color orange = Color(0xFFE7581F);

  static const Color success = Color(0xFF2E8B2E);
  static const Color successSoft = Color(0xFFE8F6E8);
  static const Color successStrong = Color(0xFF40BA40);

  static const Color info = Color(0xFF213693);
  static const Color infoSoft = Color(0xFFEEF2FE);

  static const Color purple = Color(0xFF7A3FBF);
  static const Color purpleSoft = Color(0xFFF4EAFE);

  // ─── الأسطح والحدود ───────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color accountBackground = Color(0xFFFFFAF8);
  static const Color divider = Color(0xFFEFEAEA);
  static const Color border = Color(0xFFEAEAEA);
  static const Color fill = Color(0xFFF6F6F6);
  static const Color switchOff = Color(0xFFDDDDDD);
  static const Color dashed = Color(0xFFC9C9C9);

  /// الشريط الجانبي في نسخة التابلت.
  static const Color sidebar = Color(0xFFF7FBFB);
  static const Color sidebarBorder = Color(0xFFE6EFEF);

  /// معاينة الإشعار على الجهاز (شاشة هـ٣).
  static const Color deviceSheet = Color(0xFF2B2B2E);
  static const Color notificationTime = Color(0xFF8B8B93);
  static const Color notificationBody = Color(0xFF484A4A);

  // ─── ظلال متكررة ──────────────────────────────────────────────────────────
  /// ظل البطاقة القياسي `0 4px 10px rgba(0,0,0,.25)`.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
}
