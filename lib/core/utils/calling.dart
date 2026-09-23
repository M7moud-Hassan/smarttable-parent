import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart' show Level;

import '../errors/exceptions.dart';
import '../errors/failure.dart';
import '../share/widgets/parent_app_inactive_dialog.dart';
import 'app_utils.dart';

/// نقطة واحدة يمرّ منها كل نداء بيانات، فيتحوّل كل استثناء إلى `Left` بدل أن
/// يخرج من البلوك بلا التقاط فيسقط التطبيق.
class Calling {
  Future<Either<Failure, T>> call<T>(Function fun, dynamic input) async {
    try {
      return Right<Failure, T>(input == null ? await fun() : await fun(input));
    } on AppException catch (e) {
      final failure = e.map('تعذّر الاتصال بالخادم', 'لا يوجد اتصال');
      // كل شاشة بيانات تمرّ من هنا، فحوار عدم التفعيل يُعرض مرّةً واحدة هنا
      // بدل أن تكرّره كل شاشة على حدة — ويُتجنَّب تكديسه إن فشلت عدّة نداءات
      // معًا (كما في الرئيسية التي تطلب أكثر من مورد دفعة واحدة).
      if (failure is ParentAppInactiveFailure && Get.isDialogOpen != true) {
        Get.dialog(const ParentAppInactiveDialog());
      }
      return Left<Failure, T>(failure);
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