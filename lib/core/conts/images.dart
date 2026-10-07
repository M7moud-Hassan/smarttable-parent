/// مسارات الصور. الشعار والأفاتار غير مضمّنين في حزمة التصميم، فتُوضع ملفات
/// المشروع في `assets/images` بهذه الأسماء ويعمل التطبيق بلا تعديل شاشة.
class AppImages {
  AppImages._();

  static const String base = 'assets/images';

  static const String logo = '$base/logo.png';

  /// مصدر أيقونة التطبيق — هو عينه ما يقرؤه `flutter_launcher_icons` في
  /// `pubspec.yaml`. شاشة البدء تقرأ هذا الملفّ لا نسخةً عنه، فتبديل أيقونة
  /// التطبيق يبدّل ما يظهر على الشاشة معه ولا يفترق الاثنان.
  static const String launcherIcon = 'assets/icons/logo.png';
  static const String parentAvatar = '$base/avatar.png';

  /// صورة الطالب الافتراضية حين لا يرسل الخادم صورة.
  static const String studentPlaceholder = '$base/student.png';
}
