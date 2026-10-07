import 'package:flutter/material.dart';

import '../conts/app_colors.dart';
import '../conts/app_text_styles.dart';

/// أحجام النصّ هنا تمرّ بـ`AppTextStyles.scale` كبقيّة التطبيق.
///
/// وهي أحجام السمة الافتراضية: كلّ `Text` بلا نمطٍ صريح يأخذ منها، فلو تُركت
/// خارج المقياس كبر ما يصرّح بنمطه وحده وبقي ما عداه صغيرًا، فاختلّ التناسب
/// بين نصّين متجاورين لا لشيءٍ إلا أنّ أحدهما صرّح والآخر اتّكل على السمة.
///
/// السمة الفاتحة — التطبيق لا يملك سمة داكنة في التصميم، وهذه هي المعتمدة.
final ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  fontFamily: 'IBMPlexSansArabic',
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.surface,
  canvasColor: AppColors.surface,
  cardColor: AppColors.surface,
  dividerColor: AppColors.divider,
  hintColor: AppColors.textPlaceholder,
  disabledColor: AppColors.primaryLight,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primaryDark,
    surface: AppColors.surface,
    error: AppColors.danger,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.primaryDark),
    titleTextStyle: TextStyle(
      fontFamily: 'IBMPlexSansArabic',
      fontSize: 20 * AppTextStyles.scale,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryDark,
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.primary,
    selectionHandleColor: AppColors.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    hintStyle: TextStyle(
      fontSize: 12 * AppTextStyles.scale,
      fontWeight: FontWeight.w400,
      color: AppColors.textPlaceholder,
    ),
  ),
  textTheme: const TextTheme(
    displaySmall:
        TextStyle(fontSize: 24 * AppTextStyles.scale, fontWeight: FontWeight.w600, color: AppColors.text),
    headlineSmall: TextStyle(
        fontSize: 20 * AppTextStyles.scale, fontWeight: FontWeight.w500, color: AppColors.primaryDark),
    titleLarge:
        TextStyle(fontSize: 16 * AppTextStyles.scale, fontWeight: FontWeight.w600, color: AppColors.text),
    titleMedium:
        TextStyle(fontSize: 14 * AppTextStyles.scale, fontWeight: FontWeight.w500, color: AppColors.text),
    titleSmall: TextStyle(
        fontSize: 12 * AppTextStyles.scale, fontWeight: FontWeight.w500, color: AppColors.primaryDark),
    bodyMedium:
        TextStyle(fontSize: 12 * AppTextStyles.scale, fontWeight: FontWeight.w400, color: AppColors.text),
    bodySmall:
        TextStyle(fontSize: 10 * AppTextStyles.scale, fontWeight: FontWeight.w400, color: AppColors.textMuted),
  ),
);
