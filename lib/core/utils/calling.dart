import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart' show Level;

import '../errors/exceptions.dart';
import '../errors/failure.dart';
import 'app_utils.dart';

/// نقطة واحدة يمرّ منها كل نداء بيانات، فيتحوّل كل استثناء إلى `Left` بدل أن
/// يخرج من البلوك بلا التقاط فيسقط التطبيق.
class Calling {
  Future<Either<Failure, T>> call<T>(Function fun, dynamic input) async {
    try {
      return Right<Failure, T>(input == null ? await fun() : await fun(input));
    } on AppException catch (e) {
      return Left<Failure, T>(e.map('تعذّر الاتصال بالخادم', 'لا يوجد اتصال'));
    } on DioException catch (e) {
      // الرسالة التي يراها المستخدم يعرضها اعتراض dio نفسه، وما هنا للسجل.
      return Left<Failure, T>(
          ServerFailure(title: 'خطأ', message: e.message ?? e.toString()));
    } catch (e) {
      // ليس كل نداء يمرّ عبر dio، وأخطاء تحويل النماذج تصل إلى هنا أيضاً.
      AppUtils.log('استثناء غير متوقّع في Calling: $e', levelLog: Level.error);
      return Left<Failure, T>(ServerFailure(title: 'خطأ', message: e.toString()));
    }
  }
}
