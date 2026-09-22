import '../../conts/app_colors.dart';
import '../../services/app_update_service.dart';
import 'package:flutter/material.dart';

/// نافذة التحديث.
///
/// الإجباريّ منها لا يُغلق: لا زرّ «لاحقًا» ولا رجوعٌ بزرّ النظام، لأن السماح
/// بتخطّيه يُبقي المستخدم على نسخةٍ لم تعد تتفاهم مع الخادم — وهي حالٌ أسوأ
/// من نافذةٍ لا تُغلق، إذ تفشل الشاشات واحدةً واحدة بلا سبب ظاهر.
class UpdateRequiredDialog extends StatelessWidget {
  const UpdateRequiredDialog({super.key, required this.info});

  final AppUpdateInfo info;

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    return showDialog(
      context: context,
      barrierDismissible: !info.updateRequired,
      builder: (_) => UpdateRequiredDialog(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forced = info.updateRequired;

    return PopScope(
      canPop: !forced,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: .12),
              child: Icon(
                forced ? Icons.system_update : Icons.new_releases_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              forced ? 'تحديث مطلوب' : 'يتوفر تحديث جديد',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              info.message.isNotEmpty
                  ? info.message
                  : (forced
                      ? 'يلزم تحديث التطبيق للاستمرار في استخدامه.'
                      : 'صدرت نسخة جديدة من التطبيق.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (info.latestVersion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'أحدث إصدار: ${info.latestVersion}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (info.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  info.releaseNotes,
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                final opened =
                    await AppUpdateService().openStore(info.storeUrl);
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تعذّر فتح صفحة التحديث، حدّث التطبيق من المتجر'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('تحديث الآن'),
            ),
          ),
          if (!forced)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('لاحقًا'),
            ),
        ],
      ),
    );
  }
}
