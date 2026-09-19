import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// مقياس النصوص كما في حزمة التسليم. الأحجام بالبكسل في التصميم، وتمرّ هنا
/// على `.sp` ليبقى التناسب نفسه على كل الأجهزة.
class AppTextStyles {
  AppTextStyles._();

  /// تكبيرٌ عامّ فوق مقاس التصميم.
  ///
  /// الأرقام أدناه تبقى أرقام حزمة التسليم فلا تُبدَّل واحدًا واحدًا: يُضرب
  /// المقياس كلّه في معاملٍ واحد، فتكبر النصوص بالنسبة نفسها ويبقى التناسب
  /// بينها كما رُسم — ويبقى الرجوع إلى مقاس التصميم تغييرَ رقمٍ واحد.
  ///
  /// ولا يصحّ وضعه في `MediaQuery` عند جذر التطبيق: اختبارات اللقطات ترسم
  /// الشاشات في تجهيزتها لا في `ParentApp`، فلن يبلغها التكبير ولن تكشف ما
  /// يفيض من النصّ الأكبر عن حدوده.
  static const double scale = 1.12;

  // ─── مقاسات ───────────────────────────────────────────────────────────────
  static double get s9 => 9.sp * scale;
  static double get s10 => 10.sp * scale;
  static double get s11 => 11.sp * scale;
  static double get s12 => 12.sp * scale;
  static double get s13 => 13.sp * scale;
  static double get s14 => 14.sp * scale;
  static double get s16 => 16.sp * scale;
  static double get s17 => 17.sp * scale;
  static double get s18 => 18.sp * scale;
  static double get s20 => 20.sp * scale;
  static double get s24 => 24.sp * scale;

  // ─── عناوين ───────────────────────────────────────────────────────────────
  /// عنوان الشاشة في الترويسة — 20px / 500.
  static TextStyle get screenTitle => TextStyle(
        fontSize: s20,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryDark,
      );

  /// عنوان الشاشة فوق خلفية الهوية.
  static TextStyle get screenTitleOnPrimary => TextStyle(
        fontSize: s20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  /// عنوان قسم داخل الشاشة — 14px / 600.
  static TextStyle get sectionTitle => TextStyle(
        fontSize: s14,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  /// عنوان بطاقة — 14px / 500.
  static TextStyle get cardTitle => TextStyle(
        fontSize: s14,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  /// تسمية حقل — 12px / 500 بلون primary-dark.
  static TextStyle get label => TextStyle(
        fontSize: s12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryDark,
      );

  /// نص أساسي — 12px / 500.
  static TextStyle get body => TextStyle(
        fontSize: s12,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  /// نص فقرة — 12px / 400 بارتفاع سطر واسع.
  static TextStyle get paragraph => TextStyle(
        fontSize: s12,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
        height: 2.1,
      );

  /// نص ثانوي — 12px / 400 رمادي.
  static TextStyle get bodyMuted => TextStyle(
        fontSize: s12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.7,
      );

  /// تعليق — 10px / 400.
  static TextStyle get caption => TextStyle(
        fontSize: s10,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  /// تعليق باهت — 10px / 400.
  static TextStyle get captionFaint => TextStyle(
        fontSize: s10,
        fontWeight: FontWeight.w400,
        color: AppColors.textFaint,
        height: 1.7,
      );

  /// شارة حالة — 10px / 600.
  static TextStyle get badge => TextStyle(
        fontSize: s10,
        fontWeight: FontWeight.w600,
      );

  /// نص الزر الرئيسي — 20px / 500.
  static TextStyle get primaryButton => TextStyle(
        fontSize: s20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  /// نص زر ثانوي — 12px / 500.
  static TextStyle get smallButton => TextStyle(
        fontSize: s12,
        fontWeight: FontWeight.w500,
      );

  /// تبويب الشريط السفلي — 12px / 400.
  static TextStyle get tab => TextStyle(
        fontSize: s12,
        fontWeight: FontWeight.w400,
      );

  /// الشعار النصي — Cairo 800.
  static TextStyle get wordmark => TextStyle(
        fontFamily: 'Cairo',
        fontSize: s24,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );
}
