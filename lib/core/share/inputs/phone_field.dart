import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';
import '../../conts/icons.dart';
import '../../conts/text.dart';
import '../../utils/countries.dart';

/// حقل رقم الجوال: مفتاحُ الدولة يُختار، والرقم المحلّي يُكتب.
///
/// وُجد لأن الحقل كان عشر خاناتٍ بلا مفتاح، فكان كل رقمٍ سعوديًّا بالضرورة
/// وتعذّر على 71 وليَّ أمرٍ في سجلّات الطلاب (البحرين والإمارات ومصر
/// وقيرغيزستان) أن يسجّلوا أصلًا — وكان يقبل `0000000000` ثم يُحيلهم إلى
/// إدارة المدرسة في رقمٍ خطؤه عندهم.
///
/// وهو حقلٌ واحد في الشاشات الثلاث (التسجيل، استعادة كلمة المرور، البيانات
/// الشخصية): نسخُ الشرط في كلٍّ منها هو ما جعل «عشر خانات» يختلف عن معنى
/// «رقم صحيح» ويبقى الاختلافُ غير مرئي.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final Country country;
  final ValueChanged<Country> onCountryChanged;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.fieldHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
        border: Border.all(color: AppColors.primaryDark),
      ),
      // الاتجاه مثبَّت: الرقم يُكتب ويُقرأ من اليسار إلى اليمين في كل اللغات،
      // فبلا التثبيت ينقلب المفتاح إلى الطرف الآخر داخل الواجهة العربية
      // ويقرأ المستخدم «966+» بعد رقمه لا قبله.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _countryButton(context),
            Container(
              width: 1,
              height: 22.h,
              color: AppColors.border,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                autofocus: autofocus,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // حدُّ الطول من الدولة لا رقمًا ثابتًا: ثمانيُ خاناتٍ في
                  // البحرين وإحدى عشرة في الصين، و`maxDigits + 1` يتيح
                  // للصفر البادئ أن يُكتب ثم يُحذف عند التكوين.
                  LengthLimitingTextInputFormatter(country.maxDigits + 1),
                ],
                onChanged: onChanged,
                style: AppTextStyles.body,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: _hint,
                  hintStyle: TextStyle(
                    fontSize: AppTextStyles.s12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPlaceholder,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
          ],
        ),
      ),
    );
  }

  /// مثالٌ بطول رقم الدولة المختارة — `5XXXXXXXX` للسعودية.
  String get _hint {
    final lead = country.prefixes.isNotEmpty ? country.prefixes.first : '';
    return lead + 'X' * (country.minDigits - lead.length);
  }

  Widget _countryButton(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => _pick(context) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Text(
                country.iso,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textFaint,
                  fontSize: AppTextStyles.s12,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '+${country.dial}',
                style: AppTextStyles.body.copyWith(color: AppColors.primaryDark),
              ),
              SizedBox(width: 2.w),
              Icon(AppIcons.chevronDown,
                  size: 18.sp, color: AppColors.primary),
            ],
          ),
        ),
      );

  Future<void> _pick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountrySheet(selected: country),
    );
    if (picked != null) onCountryChanged(picked);
  }
}

/// رسالةُ سبب الرفض بلغة التطبيق.
///
/// هنا لا في `countries.dart`: ذاك جدولُ بيانات لا يعرف `AppText` ولا
/// `easy_localization`، وربطُه بهما يمنع اختبارَه وحده.
extension PhoneIssueMessage on PhoneIssue {
  String get message => switch (this) {
        PhoneIssue.empty => AppText.phoneTooShort,
        PhoneIssue.tooShort => AppText.phoneTooShort,
        PhoneIssue.tooLong => AppText.phoneTooLong,
        PhoneIssue.notMobile => AppText.phoneNotMobile,
      };
}

/// قائمة الدول في ورقةٍ سفلية ببحث.
///
/// بحثٌ لا تمريرٌ فقط: القائمة نحو مئتي دولة، والوصول إلى «البحرين» بالتمرير
/// وحده في شاشةٍ صغيرة يُنهي محاولة التسجيل قبل أن تبدأ.
class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.selected});

  final Country selected;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Country> get _results {
    final q = _query.text.trim().toLowerCase().replaceAll('+', '');
    if (q.isEmpty) return kCountriesForDisplay;
    return kCountriesForDisplay
        .where((c) =>
            c.nameAr.contains(q) ||
            c.nameEn.toLowerCase().contains(q) ||
            c.iso.toLowerCase().contains(q) ||
            c.dial.startsWith(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Padding(
      // الورقة ترتفع فوق لوحة المفاتيح: بلا هذا يغطّي الكيبورد حقلَ البحث
      // نفسه فلا يرى المستخدم ما يكتبه.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 520.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 14.h),
            Text(AppText.chooseCountry, style: AppTextStyles.sectionTitle),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: Dimensions.fieldHeight,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius:
                      BorderRadius.circular(Dimensions.cardRadiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.search, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _query,
                        autofocus: false,
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.body,
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: AppText.searchCountry,
                          hintStyle: TextStyle(
                            fontSize: AppTextStyles.s12,
                            color: AppColors.textPlaceholder,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(AppText.noCountryFound,
                          style: AppTextStyles.bodyMuted),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                        indent: 20.w,
                        endIndent: 20.w,
                      ),
                      itemBuilder: (_, i) => _row(results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(Country c) {
    final chosen = c.iso == widget.selected.iso;
    return InkWell(
      onTap: () => Navigator.of(context).pop(c),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
        child: Row(
          children: [
            SizedBox(
              width: 30.w,
              child: Text(
                c.iso,
                style: AppTextStyles.bodyMuted.copyWith(
                  fontSize: AppTextStyles.s12,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                c.nameAr,
                style: chosen
                    ? AppTextStyles.body.copyWith(color: AppColors.primaryDark)
                    : AppTextStyles.body,
              ),
            ),
            Text(
              '+${c.dial}',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.bodyMuted,
            ),
            if (chosen) ...[
              SizedBox(width: 8.w),
              Icon(AppIcons.checkCircle, size: 16.sp, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
