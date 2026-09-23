import '../../conts/app_colors.dart';
import 'package:flutter/material.dart';

/// التطبيق غير مفعَّل في مدرسة الطالب — إعلاميّة بحتة وقابلة للإغلاق: لا
/// إجراء لولي الأمر داخل التطبيق نفسه، التفعيل يتم من حساب المدرسة.
class ParentAppInactiveDialog extends StatelessWidget {
  const ParentAppInactiveDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ParentAppInactiveDialog(),
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
            child: const Icon(
              Icons.lock_clock_outlined,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'التطبيق غير مفعّل في هذه المدرسة',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'يلزم أن تفعّل إدارة المدرسة الاشتراك في تطبيق ولي الأمر '
            'حتى تتمكن من متابعة ابنك.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5),
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
