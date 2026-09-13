import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../conts/app_colors.dart';

/// حالة اليوم في سجل المواظبة (شاشة ج٢).
///
/// النصّ مفتاحٌ لا قيمة: الحالات تُعرض على الشاشة، فلو بقيت عربيةً في التعداد
/// بقيت عربيةً بعد تبديل اللغة بينما تتبدّل بقيّة الشاشة.
enum AttendanceStatus {
  present('statusPresent', AppColors.successStrong),
  late('statusLate', AppColors.warningIcon),
  absent('statusAbsent', AppColors.danger);

  const AttendanceStatus(this._key, this.color);

  final String _key;
  final Color color;

  String get label => _key.tr();
}

/// حالة العذر المقدَّم على فترة غياب.
enum ExcuseStatus {
  none(null, null, null),
  pending('excusePending', AppColors.warningDeep, AppColors.warning),
  accepted('excuseAccepted', AppColors.successSoft, AppColors.success),
  rejected('excuseRejected', AppColors.dangerSoft, AppColors.dangerText);

  const ExcuseStatus(this._key, this.background, this.foreground);

  final String? _key;
  final Color? background;
  final Color? foreground;

  String? get label => _key?.tr();
}
