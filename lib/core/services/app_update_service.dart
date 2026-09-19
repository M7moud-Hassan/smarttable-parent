import '../conts/api.dart';
import '../utils/app_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// نتيجة سؤال الخادم عن الإصدار.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.updateRequired,
    required this.updateAvailable,
    required this.latestVersion,
    required this.storeUrl,
    required this.message,
    required this.releaseNotes,
  });

  final bool updateRequired;
  final bool updateAvailable;
  final String latestVersion;
  final String storeUrl;
  final String message;
  final String releaseNotes;

  /// لا تحديث — وهي حال الخطأ أيضًا: عطلُ الشبكة لا يقفل التطبيق.
  static const none = AppUpdateInfo(
    updateRequired: false,
    updateAvailable: false,
    latestVersion: '',
    storeUrl: '',
    message: '',
    releaseNotes: '',
  );

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
        updateRequired: json['update_required'] == true,
        updateAvailable: json['update_available'] == true,
        latestVersion: json['latest_version']?.toString() ?? '',
        storeUrl: json['store_url']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        releaseNotes: json['release_notes']?.toString() ?? '',
      );
}

/// يسأل الخادم: أعلى هذا الجهاز تحديث؟
///
/// الفشل لا يُقفل: انقطاع الشبكة أو خطأ الخادم يعودان بـ[AppUpdateInfo.none]،
/// فلا يُحبس المستخدم خارج تطبيقه بسبب عطلٍ عندنا.
class AppUpdateService {
  AppUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// اسم هذا التطبيق عند الخادم. وليّ الأمر `parent`، والمعلّم `teacher`،
  /// والمدير `manager`.
  static const appKey = 'parent';

  String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// (رقم الإصدار، رقم البناء) من المنصّة — `2.0.16` و`31` من `2.0.16+31`.
  ///
  /// يُرسل الاثنان: الخادم يقارن بأيّهما كُتب في اللوحة، ورقم البناء أضبط
  /// لأنه عدّادٌ لا يتكرّر ولا يُعاد ترقيمه.
  Future<(String, String)> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return (info.version, info.buildNumber);
    } catch (_) {
      return ('', '');
    }
  }

  Future<AppUpdateInfo> check() async {
    try {
      final (version, build) = await currentVersion();
      final response = await _dio.get(
        Api.appVersionCheck,
        queryParameters: {
          'app': appKey,
          'platform': _platform,
          'version': version,
          'build': build,
        },
        options: Options(
          // الشاشة تُفتح والفحص جارٍ، فالانتظار الطويل يؤخّر الإقلاع بلا طائل.
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          // 4xx لا يُرمى: نقرؤه ونعامله كـ«لا تحديث».
          validateStatus: (_) => true,
        ),
      );

      final data = response.data;
      if (response.statusCode != 200 || data is! Map) return AppUpdateInfo.none;
      return AppUpdateInfo.fromJson(Map<String, dynamic>.from(data));
    } catch (error) {
      AppUtils.log('app version check failed: $error');
      return AppUpdateInfo.none;
    }
  }

  /// يفتح صفحة المتجر. يعود false إن تعذّر، فتُعرض رسالة بدل صمتٍ لا يُفهم.
  Future<bool> openStore(String url) async {
    if (url.isEmpty) return false;
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      AppUtils.log('opening store failed: $error');
      return false;
    }
  }
}
