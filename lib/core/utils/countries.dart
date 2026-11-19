/// مفاتيح الدول لحقل رقم الجوال.
///
/// جدولٌ في الكود لا حزمةٌ خارجية: الحقل يحتاج المفتاح وطولَ الرقم المحلّي
/// وحدهما، وحزمةُ منتقي الدول تجرّ أعلامًا وبيانات لا تُستعمل. ولا أعلامَ
/// هنا بقصد: رموز الأعلام التعبيرية لا تُرسم في كل خطوط أندرويد، فتظهر
/// مربّعاتٍ فارغة في شاشة التسجيل — ورمز الدولة ومفتاحها يكفيان للتعريف.
///
/// وأطوالُ الرقم المحلّي دقيقةٌ حيث تُعرف، و`_kMinDigits.._kMaxDigits` حيث
/// لا تُعرف: حدٌّ متساهلٌ يقبل رقمًا صحيحًا أهونُ من حدٍّ مخترَعٍ يرفضه.
library;

/// الحدّان حين لا يُعرف طول الرقم في دولةٍ بعينها.
const int _kMinDigits = 4;
const int _kMaxDigits = 14;

/// حدّ E.164 الأعلى: مفتاح الدولة والرقم معًا. يطابق `PHONE_MAX_DIGITS`
/// في الخادم (`parent_api/utils.py`)، فما يقبله الحقل يقبله التسجيل.
const int kE164MaxDigits = 15;

/// أقصر رقمٍ دوليٍّ معقول — يطابق `PHONE_MIN_DIGITS` في الخادم.
const int kE164MinDigits = 8;

class Country {
  const Country(
    this.iso,
    this.dial,
    this.nameAr,
    this.nameEn, {
    this.minDigits = _kMinDigits,
    this.maxDigits = _kMaxDigits,
    this.prefixes = const <String>[],
  });

  /// رمز ISO 3166-1 alpha-2 — يُعرض شارةً صغيرة بدل العلم.
  final String iso;

  /// مفتاح الدولة بلا `+`.
  final String dial;

  final String nameAr;
  final String nameEn;

  /// طول الرقم المحلّي بعد حذف الصفر البادئ.
  final int minDigits;
  final int maxDigits;

  /// بادئاتُ الجوال إن كانت معروفةً ومحصورة — تُرفض ما عداها.
  ///
  /// تُملأ للسعودية وحدها اليوم: 64458 من 64459 رقمًا سعوديًّا في سجلّات
  /// الطلاب على صيغة `5XXXXXXXX`، فالبادئة معلومةٌ يقينًا. وبلا يقينٍ
  /// كهذا تبقى القائمة فارغة ولا يُرفض شيء.
  final List<String> prefixes;

  /// الرقم بصيغة E.164 كما يرسله التطبيق: `+<المفتاح><الرقم المحلّي>`.
  String e164(String national) => '+$dial${stripTrunk(national)}';

  /// أخطاءُ الرقم المحلّي، أو `null` إن كان صحيحًا.
  ///
  /// تعيد مفتاح ترجمةٍ لا نصًّا: الرسالة تُقرأ بلغة التطبيق لا بلغة الكود.
  PhoneIssue? validate(String national) {
    final digits = stripTrunk(national);
    if (digits.isEmpty) return PhoneIssue.empty;
    if (digits.length < minDigits) return PhoneIssue.tooShort;
    if (digits.length > maxDigits) return PhoneIssue.tooLong;
    if (dial.length + digits.length > kE164MaxDigits) return PhoneIssue.tooLong;
    if (dial.length + digits.length < kE164MinDigits) return PhoneIssue.tooShort;
    if (prefixes.isNotEmpty && !prefixes.any(digits.startsWith)) {
      return PhoneIssue.notMobile;
    }
    return null;
  }

  bool accepts(String national) => validate(national) == null;

  /// الرقم المحلّي بلا أصفارٍ بادئة.
  ///
  /// الصفر بادئةُ اتّصالٍ داخليّة لا جزءٌ من الرقم الدوليّ: المصريّ يكتب
  /// رقمه `01012345678` والسعوديّ `0551234567`، فبلا الحذف يصير الأوّل
  /// `+20010…` ولا يطابق ما سجّلته المدرسة. والحذف هنا لا في الخادم لأن
  /// حدَّ المفتاح لا يُعرف هناك بلا هذا الجدول.
  static String stripTrunk(String national) {
    final digits = national.replaceAll(RegExp(r'\D'), '');
    var i = 0;
    while (i < digits.length && digits[i] == '0') {
      i++;
    }
    return digits.substring(i);
  }
}

/// سببُ رفض الرقم — يُترجم في `AppText`.
enum PhoneIssue { empty, tooShort, tooLong, notMobile }

/// الدولة الافتراضية: كل أرقام المدارس تقريبًا سعودية.
const String kDefaultCountryIso = 'SA';

/// الدول المقدَّمة في رأس القائمة — السعودية ثم الخليج ثم بقيةُ العرب، وهي
/// حيث يقع أولياء الأمور فعلًا في سجلّات الطلاب.
const List<String> kPinnedIso = [
  'SA', 'BH', 'AE', 'KW', 'OM', 'QA', 'EG', 'JO', 'SY', 'YE', 'SD', 'PS',
];

/// كل الدول والأقاليم بمفاتيحها.
const List<Country> kCountries = [
  // ─── الخليج والعالم العربي ──────────────────────────────────────────────
  Country('SA', '966', 'السعودية', 'Saudi Arabia',
      minDigits: 9, maxDigits: 9, prefixes: ['5']),
  Country('AE', '971', 'الإمارات', 'United Arab Emirates',
      minDigits: 8, maxDigits: 9),
  Country('BH', '973', 'البحرين', 'Bahrain', minDigits: 8, maxDigits: 8),
  Country('KW', '965', 'الكويت', 'Kuwait', minDigits: 8, maxDigits: 8),
  Country('OM', '968', 'عُمان', 'Oman', minDigits: 8, maxDigits: 8),
  Country('QA', '974', 'قطر', 'Qatar', minDigits: 8, maxDigits: 8),
  Country('EG', '20', 'مصر', 'Egypt', minDigits: 10, maxDigits: 10),
  Country('JO', '962', 'الأردن', 'Jordan', minDigits: 9, maxDigits: 9),
  Country('SY', '963', 'سوريا', 'Syria', minDigits: 9, maxDigits: 9),
  Country('LB', '961', 'لبنان', 'Lebanon', minDigits: 7, maxDigits: 8),
  Country('IQ', '964', 'العراق', 'Iraq', minDigits: 10, maxDigits: 10),
  Country('PS', '970', 'فلسطين', 'Palestine', minDigits: 9, maxDigits: 9),
  Country('YE', '967', 'اليمن', 'Yemen', minDigits: 7, maxDigits: 9),
  Country('SD', '249', 'السودان', 'Sudan', minDigits: 9, maxDigits: 9),
  Country('LY', '218', 'ليبيا', 'Libya', minDigits: 9, maxDigits: 9),
  Country('TN', '216', 'تونس', 'Tunisia', minDigits: 8, maxDigits: 8),
  Country('DZ', '213', 'الجزائر', 'Algeria', minDigits: 9, maxDigits: 9),
  Country('MA', '212', 'المغرب', 'Morocco', minDigits: 9, maxDigits: 9),
  Country('MR', '222', 'موريتانيا', 'Mauritania', minDigits: 8, maxDigits: 8),
  Country('SO', '252', 'الصومال', 'Somalia', minDigits: 7, maxDigits: 9),
  Country('DJ', '253', 'جيبوتي', 'Djibouti', minDigits: 8, maxDigits: 8),
  Country('KM', '269', 'جزر القمر', 'Comoros', minDigits: 7, maxDigits: 7),

  // ─── آسيا ───────────────────────────────────────────────────────────────
  Country('AF', '93', 'أفغانستان', 'Afghanistan', minDigits: 9, maxDigits: 9),
  Country('AM', '374', 'أرمينيا', 'Armenia', minDigits: 8, maxDigits: 8),
  Country('AZ', '994', 'أذربيجان', 'Azerbaijan', minDigits: 9, maxDigits: 9),
  Country('BD', '880', 'بنغلاديش', 'Bangladesh', minDigits: 10, maxDigits: 10),
  Country('BN', '673', 'بروناي', 'Brunei', minDigits: 7, maxDigits: 7),
  Country('BT', '975', 'بوتان', 'Bhutan', minDigits: 8, maxDigits: 8),
  Country('CN', '86', 'الصين', 'China', minDigits: 11, maxDigits: 11),
  Country('GE', '995', 'جورجيا', 'Georgia', minDigits: 9, maxDigits: 9),
  Country('HK', '852', 'هونغ كونغ', 'Hong Kong', minDigits: 8, maxDigits: 8),
  Country('ID', '62', 'إندونيسيا', 'Indonesia', minDigits: 9, maxDigits: 12),
  Country('IN', '91', 'الهند', 'India', minDigits: 10, maxDigits: 10),
  Country('IR', '98', 'إيران', 'Iran', minDigits: 10, maxDigits: 10),
  Country('JP', '81', 'اليابان', 'Japan', minDigits: 10, maxDigits: 10),
  Country('KG', '996', 'قيرغيزستان', 'Kyrgyzstan', minDigits: 9, maxDigits: 9),
  Country('KH', '855', 'كمبوديا', 'Cambodia', minDigits: 8, maxDigits: 9),
  Country('KP', '850', 'كوريا الشمالية', 'North Korea'),
  Country('KR', '82', 'كوريا الجنوبية', 'South Korea',
      minDigits: 9, maxDigits: 10),
  Country('KZ', '7', 'كازاخستان', 'Kazakhstan', minDigits: 10, maxDigits: 10),
  Country('LA', '856', 'لاوس', 'Laos', minDigits: 8, maxDigits: 10),
  Country('LK', '94', 'سريلانكا', 'Sri Lanka', minDigits: 9, maxDigits: 9),
  Country('MM', '95', 'ميانمار', 'Myanmar', minDigits: 8, maxDigits: 10),
  Country('MN', '976', 'منغوليا', 'Mongolia', minDigits: 8, maxDigits: 8),
  Country('MO', '853', 'ماكاو', 'Macao', minDigits: 8, maxDigits: 8),
  Country('MV', '960', 'المالديف', 'Maldives', minDigits: 7, maxDigits: 7),
  Country('MY', '60', 'ماليزيا', 'Malaysia', minDigits: 9, maxDigits: 10),
  Country('NP', '977', 'نيبال', 'Nepal', minDigits: 10, maxDigits: 10),
  Country('PH', '63', 'الفلبين', 'Philippines', minDigits: 10, maxDigits: 10),
  Country('PK', '92', 'باكستان', 'Pakistan', minDigits: 10, maxDigits: 10),
  Country('SG', '65', 'سنغافورة', 'Singapore', minDigits: 8, maxDigits: 8),
  Country('TH', '66', 'تايلاند', 'Thailand', minDigits: 9, maxDigits: 9),
  Country('TJ', '992', 'طاجيكستان', 'Tajikistan', minDigits: 9, maxDigits: 9),
  Country('TL', '670', 'تيمور الشرقية', 'Timor-Leste'),
  Country('TM', '993', 'تركمانستان', 'Turkmenistan', minDigits: 8, maxDigits: 8),
  Country('TR', '90', 'تركيا', 'Türkiye', minDigits: 10, maxDigits: 10),
  Country('TW', '886', 'تايوان', 'Taiwan', minDigits: 9, maxDigits: 9),
  Country('UZ', '998', 'أوزبكستان', 'Uzbekistan', minDigits: 9, maxDigits: 9),
  Country('VN', '84', 'فيتنام', 'Vietnam', minDigits: 9, maxDigits: 10),

  // ─── أوروبا ─────────────────────────────────────────────────────────────
  Country('AL', '355', 'ألبانيا', 'Albania', minDigits: 9, maxDigits: 9),
  Country('AD', '376', 'أندورا', 'Andorra', minDigits: 6, maxDigits: 6),
  Country('AT', '43', 'النمسا', 'Austria', minDigits: 10, maxDigits: 11),
  Country('BA', '387', 'البوسنة والهرسك', 'Bosnia and Herzegovina',
      minDigits: 8, maxDigits: 8),
  Country('BE', '32', 'بلجيكا', 'Belgium', minDigits: 9, maxDigits: 9),
  Country('BG', '359', 'بلغاريا', 'Bulgaria', minDigits: 9, maxDigits: 9),
  Country('BY', '375', 'بيلاروسيا', 'Belarus', minDigits: 9, maxDigits: 9),
  Country('CH', '41', 'سويسرا', 'Switzerland', minDigits: 9, maxDigits: 9),
  Country('CY', '357', 'قبرص', 'Cyprus', minDigits: 8, maxDigits: 8),
  Country('CZ', '420', 'التشيك', 'Czechia', minDigits: 9, maxDigits: 9),
  Country('DE', '49', 'ألمانيا', 'Germany', minDigits: 10, maxDigits: 11),
  Country('DK', '45', 'الدنمارك', 'Denmark', minDigits: 8, maxDigits: 8),
  Country('EE', '372', 'إستونيا', 'Estonia', minDigits: 7, maxDigits: 8),
  Country('ES', '34', 'إسبانيا', 'Spain', minDigits: 9, maxDigits: 9),
  Country('FI', '358', 'فنلندا', 'Finland', minDigits: 9, maxDigits: 10),
  Country('FR', '33', 'فرنسا', 'France', minDigits: 9, maxDigits: 9),
  Country('GB', '44', 'المملكة المتحدة', 'United Kingdom',
      minDigits: 10, maxDigits: 10),
  Country('GR', '30', 'اليونان', 'Greece', minDigits: 10, maxDigits: 10),
  Country('HR', '385', 'كرواتيا', 'Croatia', minDigits: 8, maxDigits: 9),
  Country('HU', '36', 'هنغاريا', 'Hungary', minDigits: 9, maxDigits: 9),
  Country('IE', '353', 'أيرلندا', 'Ireland', minDigits: 9, maxDigits: 9),
  Country('IS', '354', 'آيسلندا', 'Iceland', minDigits: 7, maxDigits: 7),
  Country('IT', '39', 'إيطاليا', 'Italy', minDigits: 9, maxDigits: 10),
  Country('LT', '370', 'ليتوانيا', 'Lithuania', minDigits: 8, maxDigits: 8),
  Country('LU', '352', 'لوكسمبورغ', 'Luxembourg', minDigits: 9, maxDigits: 9),
  Country('LV', '371', 'لاتفيا', 'Latvia', minDigits: 8, maxDigits: 8),
  Country('MC', '377', 'موناكو', 'Monaco', minDigits: 8, maxDigits: 9),
  Country('MD', '373', 'مولدوفا', 'Moldova', minDigits: 8, maxDigits: 8),
  Country('ME', '382', 'الجبل الأسود', 'Montenegro', minDigits: 8, maxDigits: 8),
  Country('MK', '389', 'مقدونيا الشمالية', 'North Macedonia',
      minDigits: 8, maxDigits: 8),
  Country('MT', '356', 'مالطا', 'Malta', minDigits: 8, maxDigits: 8),
  Country('NL', '31', 'هولندا', 'Netherlands', minDigits: 9, maxDigits: 9),
  Country('NO', '47', 'النرويج', 'Norway', minDigits: 8, maxDigits: 8),
  Country('PL', '48', 'بولندا', 'Poland', minDigits: 9, maxDigits: 9),
  Country('PT', '351', 'البرتغال', 'Portugal', minDigits: 9, maxDigits: 9),
  Country('RO', '40', 'رومانيا', 'Romania', minDigits: 9, maxDigits: 9),
  Country('RS', '381', 'صربيا', 'Serbia', minDigits: 8, maxDigits: 9),
  Country('RU', '7', 'روسيا', 'Russia', minDigits: 10, maxDigits: 10),
  Country('SE', '46', 'السويد', 'Sweden', minDigits: 7, maxDigits: 9),
  Country('SI', '386', 'سلوفينيا', 'Slovenia', minDigits: 8, maxDigits: 8),
  Country('SK', '421', 'سلوفاكيا', 'Slovakia', minDigits: 9, maxDigits: 9),
  Country('SM', '378', 'سان مارينو', 'San Marino'),
  Country('UA', '380', 'أوكرانيا', 'Ukraine', minDigits: 9, maxDigits: 9),
  Country('VA', '379', 'الفاتيكان', 'Vatican City'),
  Country('XK', '383', 'كوسوفو', 'Kosovo', minDigits: 8, maxDigits: 9),

  // ─── إفريقيا ────────────────────────────────────────────────────────────
  Country('AO', '244', 'أنغولا', 'Angola', minDigits: 9, maxDigits: 9),
  Country('BF', '226', 'بوركينا فاسو', 'Burkina Faso', minDigits: 8, maxDigits: 8),
  Country('BI', '257', 'بوروندي', 'Burundi', minDigits: 8, maxDigits: 8),
  Country('BJ', '229', 'بنين', 'Benin', minDigits: 8, maxDigits: 10),
  Country('BW', '267', 'بوتسوانا', 'Botswana', minDigits: 7, maxDigits: 8),
  Country('CD', '243', 'الكونغو الديمقراطية', 'DR Congo',
      minDigits: 9, maxDigits: 9),
  Country('CF', '236', 'أفريقيا الوسطى', 'Central African Republic',
      minDigits: 8, maxDigits: 8),
  Country('CG', '242', 'الكونغو', 'Congo', minDigits: 9, maxDigits: 9),
  Country('CI', '225', 'ساحل العاج', "Côte d'Ivoire", minDigits: 8, maxDigits: 10),
  Country('CM', '237', 'الكاميرون', 'Cameroon', minDigits: 9, maxDigits: 9),
  Country('CV', '238', 'الرأس الأخضر', 'Cabo Verde', minDigits: 7, maxDigits: 7),
  Country('ER', '291', 'إريتريا', 'Eritrea', minDigits: 7, maxDigits: 7),
  Country('ET', '251', 'إثيوبيا', 'Ethiopia', minDigits: 9, maxDigits: 9),
  Country('GA', '241', 'الغابون', 'Gabon', minDigits: 7, maxDigits: 8),
  Country('GH', '233', 'غانا', 'Ghana', minDigits: 9, maxDigits: 9),
  Country('GM', '220', 'غامبيا', 'Gambia', minDigits: 7, maxDigits: 7),
  Country('GN', '224', 'غينيا', 'Guinea', minDigits: 9, maxDigits: 9),
  Country('GQ', '240', 'غينيا الاستوائية', 'Equatorial Guinea',
      minDigits: 9, maxDigits: 9),
  Country('GW', '245', 'غينيا بيساو', 'Guinea-Bissau', minDigits: 7, maxDigits: 7),
  Country('KE', '254', 'كينيا', 'Kenya', minDigits: 9, maxDigits: 9),
  Country('LR', '231', 'ليبيريا', 'Liberia', minDigits: 7, maxDigits: 9),
  Country('LS', '266', 'ليسوتو', 'Lesotho', minDigits: 8, maxDigits: 8),
  Country('MG', '261', 'مدغشقر', 'Madagascar', minDigits: 9, maxDigits: 9),
  Country('ML', '223', 'مالي', 'Mali', minDigits: 8, maxDigits: 8),
  Country('MU', '230', 'موريشيوس', 'Mauritius', minDigits: 7, maxDigits: 8),
  Country('MW', '265', 'مالاوي', 'Malawi', minDigits: 9, maxDigits: 9),
  Country('MZ', '258', 'موزمبيق', 'Mozambique', minDigits: 9, maxDigits: 9),
  Country('NA', '264', 'ناميبيا', 'Namibia', minDigits: 9, maxDigits: 9),
  Country('NE', '227', 'النيجر', 'Niger', minDigits: 8, maxDigits: 8),
  Country('NG', '234', 'نيجيريا', 'Nigeria', minDigits: 10, maxDigits: 10),
  Country('RW', '250', 'رواندا', 'Rwanda', minDigits: 9, maxDigits: 9),
  Country('SC', '248', 'سيشل', 'Seychelles', minDigits: 7, maxDigits: 7),
  Country('SL', '232', 'سيراليون', 'Sierra Leone', minDigits: 8, maxDigits: 8),
  Country('SN', '221', 'السنغال', 'Senegal', minDigits: 9, maxDigits: 9),
  Country('SS', '211', 'جنوب السودان', 'South Sudan', minDigits: 9, maxDigits: 9),
  Country('ST', '239', 'ساو تومي وبرينسيبي', 'São Tomé and Príncipe',
      minDigits: 7, maxDigits: 7),
  Country('SZ', '268', 'إسواتيني', 'Eswatini', minDigits: 8, maxDigits: 8),
  Country('TD', '235', 'تشاد', 'Chad', minDigits: 8, maxDigits: 8),
  Country('TG', '228', 'توغو', 'Togo', minDigits: 8, maxDigits: 8),
  Country('TZ', '255', 'تنزانيا', 'Tanzania', minDigits: 9, maxDigits: 9),
  Country('UG', '256', 'أوغندا', 'Uganda', minDigits: 9, maxDigits: 9),
  Country('ZA', '27', 'جنوب أفريقيا', 'South Africa', minDigits: 9, maxDigits: 9),
  Country('ZM', '260', 'زامبيا', 'Zambia', minDigits: 9, maxDigits: 9),
  Country('ZW', '263', 'زيمبابوي', 'Zimbabwe', minDigits: 9, maxDigits: 9),

  // ─── الأمريكتان ─────────────────────────────────────────────────────────
  Country('AR', '54', 'الأرجنتين', 'Argentina', minDigits: 10, maxDigits: 11),
  Country('BO', '591', 'بوليفيا', 'Bolivia', minDigits: 8, maxDigits: 8),
  Country('BR', '55', 'البرازيل', 'Brazil', minDigits: 10, maxDigits: 11),
  Country('BZ', '501', 'بليز', 'Belize', minDigits: 7, maxDigits: 7),
  Country('CA', '1', 'كندا', 'Canada', minDigits: 10, maxDigits: 10),
  Country('CL', '56', 'تشيلي', 'Chile', minDigits: 9, maxDigits: 9),
  Country('CO', '57', 'كولومبيا', 'Colombia', minDigits: 10, maxDigits: 10),
  Country('CR', '506', 'كوستاريكا', 'Costa Rica', minDigits: 8, maxDigits: 8),
  Country('CU', '53', 'كوبا', 'Cuba', minDigits: 8, maxDigits: 8),
  Country('DO', '1', 'الدومينيكان', 'Dominican Republic',
      minDigits: 10, maxDigits: 10),
  Country('EC', '593', 'الإكوادور', 'Ecuador', minDigits: 9, maxDigits: 9),
  Country('GT', '502', 'غواتيمالا', 'Guatemala', minDigits: 8, maxDigits: 8),
  Country('GY', '592', 'غيانا', 'Guyana', minDigits: 7, maxDigits: 7),
  Country('HN', '504', 'هندوراس', 'Honduras', minDigits: 8, maxDigits: 8),
  Country('HT', '509', 'هايتي', 'Haiti', minDigits: 8, maxDigits: 8),
  Country('JM', '1', 'جامايكا', 'Jamaica', minDigits: 10, maxDigits: 10),
  Country('MX', '52', 'المكسيك', 'Mexico', minDigits: 10, maxDigits: 10),
  Country('NI', '505', 'نيكاراغوا', 'Nicaragua', minDigits: 8, maxDigits: 8),
  Country('PA', '507', 'بنما', 'Panama', minDigits: 8, maxDigits: 8),
  Country('PE', '51', 'بيرو', 'Peru', minDigits: 9, maxDigits: 9),
  Country('PR', '1', 'بورتوريكو', 'Puerto Rico', minDigits: 10, maxDigits: 10),
  Country('PY', '595', 'باراغواي', 'Paraguay', minDigits: 9, maxDigits: 9),
  Country('SR', '597', 'سورينام', 'Suriname', minDigits: 7, maxDigits: 7),
  Country('SV', '503', 'السلفادور', 'El Salvador', minDigits: 8, maxDigits: 8),
  Country('TT', '1', 'ترينيداد وتوباغو', 'Trinidad and Tobago',
      minDigits: 10, maxDigits: 10),
  Country('US', '1', 'الولايات المتحدة', 'United States',
      minDigits: 10, maxDigits: 10),
  Country('UY', '598', 'أوروغواي', 'Uruguay', minDigits: 8, maxDigits: 8),
  Country('VE', '58', 'فنزويلا', 'Venezuela', minDigits: 10, maxDigits: 10),

  // ─── أوقيانوسيا ─────────────────────────────────────────────────────────
  Country('AU', '61', 'أستراليا', 'Australia', minDigits: 9, maxDigits: 9),
  Country('FJ', '679', 'فيجي', 'Fiji', minDigits: 7, maxDigits: 7),
  Country('NC', '687', 'كاليدونيا الجديدة', 'New Caledonia',
      minDigits: 6, maxDigits: 6),
  Country('NZ', '64', 'نيوزيلندا', 'New Zealand', minDigits: 8, maxDigits: 10),
  Country('PF', '689', 'بولينيزيا الفرنسية', 'French Polynesia',
      minDigits: 8, maxDigits: 8),
  Country('PG', '675', 'بابوا غينيا الجديدة', 'Papua New Guinea',
      minDigits: 8, maxDigits: 8),
  Country('SB', '677', 'جزر سولومون', 'Solomon Islands'),
  Country('VU', '678', 'فانواتو', 'Vanuatu', minDigits: 7, maxDigits: 7),
  Country('WS', '685', 'ساموا', 'Samoa'),
];

/// جداولُ بحثٍ تُبنى مرّة واحدة — القائمة ثابتة فلا داعي لمسحها كل ضغطة.
final Map<String, Country> _byIso = {
  for (final c in kCountries) c.iso: c,
};

/// الدولة الافتراضية مضمونةُ الوجود: `kDefaultCountryIso` في القائمة.
final Country kDefaultCountry = _byIso[kDefaultCountryIso]!;

/// دولةٌ برمز ISO، أو الافتراضية إن لم تُعرف.
Country countryByIso(String? iso) =>
    _byIso[(iso ?? '').toUpperCase()] ?? kDefaultCountry;

/// القائمة بترتيب العرض: المقدَّمة أوّلًا ثم الباقي أبجديًّا بالعربية.
final List<Country> kCountriesForDisplay = [
  for (final iso in kPinnedIso) if (_byIso[iso] != null) _byIso[iso]!,
  ...(kCountries.where((c) => !kPinnedIso.contains(c.iso)).toList()
    ..sort((a, b) => a.nameAr.compareTo(b.nameAr))),
];

/// نتيجةُ تفكيك رقمٍ مخزَّن إلى دولةٍ ورقمٍ محلّي.
class ParsedPhone {
  const ParsedPhone(this.country, this.national);

  final Country country;
  final String national;

  String get e164 => country.e164(national);
}

/// يفكّك ما يعيده الخادم إلى دولةٍ ورقمٍ محلّي، لتعبئة حقل التعديل.
///
/// الخادم يعيد الرقم السعودي محلّيًّا (`0551234567`) وغيرَه دوليًّا
/// (`+97312345678`)، فالحالتان كلتاهما مقروءتان هنا. وبلا هذا التفكيك تظهر
/// شاشة «البيانات الشخصية» رقمًا دوليًّا كاملًا في حقلٍ مفتاحُه السعودية،
/// فيحفظه وليّ الأمر فيفقد صلته بأبنائه.
ParsedPhone parsePhone(String? raw, {Country? fallback}) {
  final base = fallback ?? kDefaultCountry;
  final text = (raw ?? '').trim();
  if (text.isEmpty) return ParsedPhone(base, '');

  final international = text.startsWith('+') || text.startsWith('00');
  var digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return ParsedPhone(base, '');
  if (digits.startsWith('00')) digits = digits.substring(2);

  if (!international) {
    // رقمٌ محلّي: الدولة هي المعروضة، والصفر البادئ بادئةٌ داخلية.
    return ParsedPhone(base, Country.stripTrunk(digits));
  }

  // أطولُ مفتاحٍ مطابق أوّلًا: `+1` و`+966` قد يتشاركان بادئةً مع غيرهما،
  // فمطابقةُ الأقصر تنسب الرقم إلى الدولة الخطأ وتكسر طولَه.
  for (var len = 4; len >= 1; len--) {
    if (digits.length <= len) continue;
    final dial = digits.substring(0, len);
    final national = Country.stripTrunk(digits.substring(len));
    final matches = kCountries.where((c) => c.dial == dial).toList();
    if (matches.isEmpty) continue;
    // دولٌ تتشارك المفتاح (`+1` و`+7`): تُختار من يقبل طولَ الرقم.
    final exact = matches.firstWhere(
      (c) => c.accepts(national),
      orElse: () => matches.first,
    );
    return ParsedPhone(exact, national);
  }

  return ParsedPhone(base, Country.stripTrunk(digits));
}
