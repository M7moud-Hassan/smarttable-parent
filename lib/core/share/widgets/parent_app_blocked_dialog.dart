import '../../conts/app_colors.dart';
import 'package:flutter/material.dart';
import '../../conts/app_text_styles.dart';
import '../../enums/parent_app_state.dart';

/// التطبيق محجوب عن وليّ الأمر — إعلاميّة بحتة وقابلة للإغلاق: لا إجراء له
/// داخل التطبيق نفسه في الحالتين، فالتفعيل من حساب المدرسة وتسجيل رقمه من
/// سجلّات الطلاب.
///
/// النصّ والأيقونة من [ParentAppState]، لأن السبب يُغيّر ما يُطلب من وليّ
/// الأمر: مراجعةُ الاشتراك شيء، ومراجعةُ تسجيل رقمه مع ابنه شيءٌ آخر.
class ParentAppBlockedDialog extends StatelessWidget {
  const ParentAppBlockedDialog({
    super.key,
    this.state = ParentAppState.noSubscription,
  });

  final ParentAppState state;

  static Future<void> show(
    BuildContext context, {
    ParentAppState state = ParentAppState.noSubscription,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ParentAppBlockedDialog(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withValues(alpha: .12),
            child: Icon(
              state.icon,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18 * AppTextStyles.scale,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            state.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14 * AppTextStyles.scale, height: 1.5),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسنًا'),
          ),
        ),
      ],
    );
  }
}
