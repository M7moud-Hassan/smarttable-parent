import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../conts/app_colors.dart';

/// نوع ملاحظة السلوك (شاشة ج٤).
enum BehaviorNoteType {
  positive('notePositive', AppColors.successSoft, AppColors.success),
  needsWork('noteNeedsWork', AppColors.warningSoft, AppColors.warning);

  const BehaviorNoteType(this._key, this.background, this.foreground);

  final String _key;
  final Color background;
  final Color foreground;

  String get label => _key.tr();
}

/// مصدر الإجراء الإداري — ملاحظة مواظبة أو ملاحظة سلوك (شاشة د٥).
enum AdminActionSource {
  attendance('sourceAttendance', AppColors.warningDeep, AppColors.warning),
  behavior('sourceBehavior', AppColors.infoSoft, AppColors.info);

  const AdminActionSource(this._key, this.background, this.foreground);

  final String _key;
  final Color background;
  final Color foreground;

  String get label => _key.tr();
}

/// ما يطلبه الإجراء من ولي الأمر.
enum AdminActionState {
  /// اطّلع عليه ولي الأمر بالفعل.
  seen,

  /// يتطلب ضغطة «تم الاطلاع».
  needsAcknowledge,

  /// يتطلب تأكيد حضور موعد.
  needsAttendance,
}
