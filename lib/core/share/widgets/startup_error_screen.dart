import 'package:flutter/material.dart';

import '../../conts/app_colors.dart';
import '../../conts/text.dart';

/// ما يُعرض حين تفشل تهيئة التطبيق.
///
/// بلا هذه الشاشة يبقى المستخدم أمام بياض دائم بلا رسالة ولا سبيل إلى
/// المحاولة — وهو أسوأ ما يمكن أن يراه عند الإقلاع.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text(
                    AppText.startupFailed,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(180, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      AppText.retry,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
