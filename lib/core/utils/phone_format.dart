import 'countries.dart';

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

  /// `0551234567` ← `+966 55 123 4567`.
  ///
  /// وكل دولةٍ أخرى بمفتاحها ثم رقمها: `+973 1234 5678`. كان غير السعوديّ
  /// يعود كما هو بلا تنسيقٍ ولا عزلِ اتجاه، فيُقرأ مقلوبًا في شاشة «حسابي».
  static String display(String phone) {
    final parsed = parsePhone(phone);
    final national = parsed.national;
    // ما لا تقبله دولته يعود كما هو: تنسيق `0551` إلى «966+ 551» يدّعي
    // مفتاحَ دولةٍ وشكلًا كاملًا لرقمٍ ناقص.
    if (!parsed.country.accepts(national)) return phone;

    final groups = <String>[];
    if (parsed.country.iso == kDefaultCountryIso && national.length == 9) {
      // الصيغة السعودية المعتادة: 55 123 4567.
      groups.addAll([
        national.substring(0, 2),
        national.substring(2, 5),
        national.substring(5),
      ]);
    } else {
      // تجزئةٌ عامة من اليمين بأربع خانات — تقرأ أطوالَ كل الدول بلا جدول
      // تنسيقٍ لكلٍّ منها.
      var rest = national;
      while (rest.length > 4) {
        groups.insert(0, rest.substring(rest.length - 4));
        rest = rest.substring(0, rest.length - 4);
      }
      groups.insert(0, rest);
    }

    return _isolate('+${parsed.country.dial} ${groups.join(' ')}');
  }

  /// `0551234567` ← `055****567` — صيغة شاشة رمز التحقق.
  ///
  /// تُقنَّع الخانات الوسطى أيًّا كان طول الرقم: الرقم البحريني ثماني خانات،
  /// والشرط `length < 10` كان يعيده بلا تقنيعٍ ولا عزلِ اتجاه.
  static String masked(String phone) {
    final digits = _digits(phone);
    if (digits.length < 6) return phone;

    final head = digits.substring(0, 3);
    final tail = digits.substring(digits.length - 3);
    return _isolate('$head****$tail');
  }
}
