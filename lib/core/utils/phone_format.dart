/// تنسيق أرقام الجوال للعرض.
///
/// الصيغتان كانتا مكرّرتين في النموذج وفي شاشة رمز التحقق، فاختلفتا حين
/// أُصلح اتجاه إحداهما دون الأخرى. وهما هنا في موضع واحد.
class PhoneFormat {
  PhoneFormat._();

  /// علامتا عزل الاتجاه حول الرقم.
  ///
  /// بلا العزل ينقلب «055****567» إلى «567****055» داخل الفقرة العربية، لأن
  /// خوارزمية الاتجاه تقرأ الأرقام في سياق الفقرة لا في سياقها.
  static String _isolate(String text) => '\u2066$text\u2069';

  static String _digits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  /// `0551234567` ← `+966 55 123 4567`، ويعود الرقم كما هو إن لم يكن سعودياً
  /// من عشر خانات.
  static String display(String phone) {
    final digits = _digits(phone);
    if (digits.length != 10 || !digits.startsWith('0')) return phone;
    final rest = digits.substring(1);
    return _isolate('+966 ${rest.substring(0, 2)} ${rest.substring(2, 5)} '
        '${rest.substring(5)}');
  }

  /// `0551234567` ← `055****567` — صيغة شاشة رمز التحقق.
  static String masked(String phone) {
    final digits = _digits(phone);
    if (digits.length < 10) return phone;
    return _isolate('${digits.substring(0, 3)}****${digits.substring(7)}');
  }
}
