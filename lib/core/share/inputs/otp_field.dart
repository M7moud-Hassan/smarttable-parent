import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../conts/app_colors.dart';
import '../../conts/app_text_styles.dart';
import '../../conts/dimensions.dart';

/// أربع خانات لرمز التحقق (شاشة A5)، 60×64 لكل خانة بفراغ 12.
///
/// الخانات مرتّبة من اليسار إلى اليمين وإن كانت الواجهة عربية، لأن الرقم
/// يُقرأ من اليسار دائماً: الرمز `5831` يصل في الرسالة بهذا الترتيب، فلو
/// رُتّبت الخانات باتجاه الواجهة لظهر مقلوباً ولبدأ وليّ الأمر الكتابة في
/// الخانة الأخيرة فيتوقّف عندها.
///
/// والتركيز ينتقل تلقائياً إلى التالية عند الكتابة وإلى السابقة عند المسح،
/// والنقر على خانةٍ فارغة يُحوَّل إلى أوّل فارغة: رسالة الرمز تُرشد من على
/// الإصدار القديم أن يبدأ بالخانة اليمنى، فلولا التحويل لوقع أوّل رقمٍ هنا في
/// آخر خانةٍ ووقف المستخدم.
class OtpField extends StatefulWidget {
  const OtpField({super.key, this.length = 4, required this.onChanged});

  final int length;
  final ValueChanged<String> onChanged;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());
  late final List<FocusNode> _nodes = List.generate(widget.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
    setState(() {});
  }

  /// أوّل خانةٍ فارغة، أو `null` إن امتلأت كلّها.
  int? _firstEmpty() {
    for (var i = 0; i < widget.length; i++) {
      if (_controllers[i].text.isEmpty) return i;
    }
    return null;
  }

  /// النقر على فارغةٍ نيّةُ كتابة، فيُصرف إلى أوّل فارغة كي لا تنشأ ثغرة.
  ///
  /// والنقر على خانةٍ مكتوبة يُترك كما هو: ذاك تصحيحُ رقمٍ بعينه، وصرفُه
  /// يمنع المستخدم من إصلاح ما كتبه.
  void _onTap(int index) {
    if (_controllers[index].text.isNotEmpty) return;
    final first = _firstEmpty();
    if (first != null && first != index) _nodes[first].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // الاتجاه مفروضٌ هنا ولا يُورَث من الواجهة: `Row` في وضع RTL يضع الخانة
    // الأولى على اليمين، فيُقرأ الرمز مقلوباً وتُكتب خاناته من آخرها.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) SizedBox(width: 12.w),
            _box(i),
          ],
        ],
      ),
    );
  }

  Widget _box(int index) {
    final filled = _controllers[index].text.isNotEmpty;
    return Container(
      width: 60.w,
      height: 64.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.cardRadiusSmall),
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.primaryLight,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controllers[index],
        focusNode: _nodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        cursorColor: AppColors.primary,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: AppTextStyles.s24,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onTap: () => _onTap(index),
        onChanged: (value) => _onChanged(index, value),
      ),
    );
  }
}
