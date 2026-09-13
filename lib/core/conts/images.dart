/// مسارات الصور. الشعار والأفاتار غير مضمّنين في حزمة التصميم، فتُوضع ملفات
/// المشروع في `assets/images` بهذه الأسماء ويعمل التطبيق بلا تعديل شاشة.
class AppImages {
  AppImages._();

  static const String base = 'assets/images';

  static const String logo = '$base/logo.png';
  static const String parentAvatar = '$base/avatar.png';

  /// صورة الطالب الافتراضية حين لا يرسل الخادم صورة.
  static const String studentPlaceholder = '$base/student.png';
}
