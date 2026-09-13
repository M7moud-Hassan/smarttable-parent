import 'package:flutter/material.dart';

/// الأيقونات في حزمة التسليم مواضع فارغة (`FigIcon`) لأن ملف التصميم لم يضمّ
/// ملفاتها، ونصّ الحزمة يقول صراحة إنها «تُستبدل بأيقونات المشروع».
///
/// فكل أيقونة هنا بديل من مجموعة Material بالمقاس والموضع الصحيحين. عند وصول
/// أيقونات المشروع تُستبدل القيم في هذا الملف وحده ولا تتغيّر أي شاشة.
class AppIcons {
  AppIcons._();

  // المصادقة
  static const IconData user = Icons.person_outline;
  static const IconData lock = Icons.lock_outline;
  static const IconData eye = Icons.visibility_outlined;
  static const IconData eyeOff = Icons.visibility_off_outlined;
  static const IconData phone = Icons.phone_iphone;
  static const IconData mail = Icons.mail_outline;
  static const IconData info = Icons.info_outline;
  static const IconData check = Icons.check;
  static const IconData checkCircle = Icons.check_circle_outline;

  // التنقل
  static const IconData back = Icons.arrow_forward_ios;
  static const IconData chevron = Icons.chevron_left;
  static const IconData home = Icons.home_outlined;
  static const IconData bell = Icons.notifications_none;
  static const IconData account = Icons.person_outline;

  // الشاشات التعريفية
  static const IconData onboardingOverview = Icons.dashboard_customize_outlined;
  static const IconData onboardingExcuse = Icons.assignment_turned_in_outlined;
  static const IconData onboardingAlerts = Icons.notifications_active_outlined;

  // الخدمات
  static const IconData schedule = Icons.calendar_month_outlined;
  static const IconData attendance = Icons.fact_check_outlined;
  static const IconData behavior = Icons.psychology_alt_outlined;
  static const IconData adminActions = Icons.gavel_outlined;
  static const IconData exams = Icons.event_note_outlined;
  static const IconData circulars = Icons.campaign_outlined;
  static const IconData health = Icons.medical_services_outlined;

  // الإشعارات
  static const IconData absence = Icons.person_off_outlined;
  static const IconData excuseAccepted = Icons.verified_outlined;
  static const IconData summons = Icons.record_voice_over_outlined;
  static const IconData deduction = Icons.trending_down;

  // حسابي
  static const IconData profile = Icons.badge_outlined;
  static const IconData children = Icons.family_restroom_outlined;
  static const IconData password = Icons.key_outlined;
  static const IconData notificationSettings = Icons.tune_outlined;
  static const IconData language = Icons.language_outlined;
  static const IconData school = Icons.school_outlined;
  static const IconData support = Icons.headset_mic_outlined;
  static const IconData about = Icons.info_outline;
  static const IconData faq = Icons.help_outline;
  static const IconData privacy = Icons.privacy_tip_outlined;
  static const IconData terms = Icons.description_outlined;
  static const IconData share = Icons.share_outlined;
  static const IconData deleteAccount = Icons.delete_outline;
  static const IconData logout = Icons.logout;

  // متفرقات
  static const IconData attach = Icons.attach_file;
  static const IconData download = Icons.file_download_outlined;
  static const IconData pdf = Icons.picture_as_pdf_outlined;
  static const IconData clock = Icons.schedule;
  static const IconData location = Icons.location_on_outlined;
  static const IconData call = Icons.call;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData expand = Icons.keyboard_arrow_down;
  static const IconData collapse = Icons.keyboard_arrow_up;
  static const IconData camera = Icons.photo_camera_outlined;
}
