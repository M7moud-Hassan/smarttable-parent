import 'failure.dart';

abstract interface class AppException implements Exception {
  Failure map(String message, String title);
}

class OffLineException implements AppException {
  @override
  Failure map(String message, String title) =>
      OfflineFailure(message: message, title: title);
}

class ValidationException implements AppException {
  ValidationException(this.reason);

  final String reason;

  @override
  Failure map(String message, String title) =>
      ValidationFailure(message: reason, title: title);
}

/// ردّ خطأ من الخادم برسالةٍ عربية جاهزة للعرض.
///
/// الرسالة تُمرَّر كما هي لا تُستبدل بنصٍّ عامّ: الخادم وحده يعرف أن الرقم غير
/// مسجّل أو أن الرمز انتهى، وهو ما ينبغي أن يقرأه وليّ الأمر.
class ServerException implements AppException {
  ServerException(this.reason);

  final String reason;

  @override
  Failure map(String message, String title) =>
      ServerFailure(message: reason.isEmpty ? message : reason, title: title);
}

/// الرمز غير مقبول أو انتهت صلاحيته — تُنهي الشاشات الجلسة عند رؤيته.
class UnauthorizedException implements AppException {
  UnauthorizedException(this.reason);

  final String reason;

  @override
  Failure map(String message, String title) =>
      UnauthorizedFailure(message: reason.isEmpty ? message : reason, title: title);
}

/// المدرسة لم تفعّل تطبيق ولي الأمر — يميَّز بـ`code` من الخادم لا بنص
/// `message`، فيبقى التمييز صحيحًا مهما كانت لغة الردّ.
class ParentAppInactiveException implements AppException {
  @override
  Failure map(String message, String title) => const ParentAppInactiveFailure();
}
