import 'package:flutter/material.dart';

/// أيفتح التطبيق لوليّ الأمر؟ وإن لم يفتح، فلماذا؟
///
/// السببان لا يُخلطان: `noSubscription` شأنُ إدارة المدرسة، و`noStudents` شأنُ
/// سجلّات الطلاب — رقم وليّ الأمر غير مدخَل مع ابنه أو مدخَلٌ بخطأ. وخلطُهما
/// كان يُخبر وليَّ أمرٍ في مدرسةٍ مشتركةٍ فعلًا أن مدرسته غير مشتركة، فيراجع
/// المدرسةَ في اشتراكٍ سليمٍ لا علّة فيه.
///
/// النصوص عربية في التطبيق لا في الخادم، كبقيّة الحوارات، فتبقى ثابتةً على
/// الجهاز بصرف النظر عن ترجمة الخادم لرسائله.
enum ParentAppState {
  ok('ok', '', ''),

  noSubscription(
    'no_subscription',
    'التطبيق غير مفعّل في هذه المدرسة',
    'يلزم أن تفعّل إدارة المدرسة الاشتراك في تطبيق ولي الأمر '
        'حتى تتمكن من متابعة ابنك.',
    icon: Icons.lock_clock_outlined,
  ),

  noStudents(
    'no_students',
    'لم نجد أبناءً مرتبطين برقمك',
    'رقم جوالك غير مسجّل مع أي طالب في سجلّات المدرسة. راجع إدارة المدرسة '
        'لتسجيل رقمك مع ابنك، ثم أعد الدخول.',
    icon: Icons.person_search_outlined,
  );

  const ParentAppState(
    this.wire,
    this.title,
    this.body, {
    this.icon = Icons.lock_clock_outlined,
  });

  /// القيمة كما يرسلها الخادم في `parent_app_state` — وهي نفسها ما يُخزَّن
  /// محلّيًا، كي يصحّ قراءة المخزون ثانيةً بلا جدول تحويل.
  final String wire;

  final String title;
  final String body;
  final IconData icon;

  bool get isOpen => this == ParentAppState.ok;

  /// يقرأ الحالة من ردّ الخادم أو من المخزون المحلّي.
  ///
  /// `active` هو `parent_app_active` القديم: غيابُ `parent_app_state` يعني
  /// خادمًا أقدم من هذا الحقل، أو مستخدمًا مخزَّنًا بنسخة تطبيقٍ أقدم — وفي
  /// الحالتين نعود إلى سلوك ما قبل التمييز بدل أن نفترض حالةً لا دليل عليها.
  static ParentAppState fromJson(Object? raw, {required bool active}) {
    for (final state in ParentAppState.values) {
      if (state.wire == raw) return state;
    }
    return active ? ParentAppState.ok : ParentAppState.noSubscription;
  }
}
