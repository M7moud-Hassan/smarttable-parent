import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../conts/api.dart';
import 'app_utils.dart';

class DioConfig {
  DioConfig({required this.dio});

  final Dio dio;

  Dio config() {
    dio.options
      ..baseUrl = Api.baseUrl
      ..connectTimeout = Api.timeout
      ..receiveTimeout = Api.timeout
      ..sendTimeout = Api.timeout
      // الخادم يردّ بغلافٍ فيه `success`، ورموز 4xx تحمل رسالةً تُعرض. فتُقرأ
      // الردود كلها ويُترك الحكم لطبقة البيانات لا لـ dio.
      ..validateStatus = ((status) => status != null && status < 500)
      ..responseType = ResponseType.json;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!AppUtils.netConnect) return;
        if (options.method.toUpperCase() != 'GET') EasyLoading.show();

        AppUtils.log('${options.method} ${options.baseUrl}${options.path}');

        // رمز الوصول في ترويسة كل طلب. مسارات الدخول والتسجيل لا تحتاجه،
        // ووجوده فيها لا يضرّ: الخادم يتجاهل الترويسة في نقاطٍ لا تصادق.
        final token = AppUtils.instance.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept-Language'] = AppUtils.instance.getLocale().languageCode;

        return handler.next(options);
      },
      onError: (error, handler) {
        EasyLoading.dismiss();
        AppUtils.log(error.toString());

        // الخادم لا يردّ دائماً بـ JSON: صفحة 404 أو 500 ترجع HTML كنص،
        // وفهرسته بمفتاح نصّي تُسقط التطبيق. فلا تُقرأ المفاتيح إلا من Map.
        //
        // ولا يُعرض الإشعار هنا: طبقة البيانات ترفع الرسالة نفسها إلى الشاشة
        // التي طلبت، فعرضها مرتين يُظهر إشعارين لخطأٍ واحد.
        final data = error.response?.data;
        AppUtils.log(data is Map ? '${data['message'] ?? data}' : '$data');

        // بلا تمرير الخطأ يبقى الطلب معلَّقاً فلا تخرج الشاشة من حالة التحميل.
        return handler.next(error);
      },
      onResponse: (response, handler) {
        EasyLoading.dismiss();
        return handler.next(response);
      },
    ));
    return dio;
  }
}
