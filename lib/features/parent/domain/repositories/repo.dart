import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

/// المستودع لا يعرف نداءً بعينه: يستقبل دالة من `Db` ووسيطها، ويردّ نتيجة
/// ملفوفة في `Either`. هذا ما يبقي حالات الاستخدام سطراً واحداً بلا تكرار.
abstract class Repo {
  Future<Either<Failure, T>> calling<T>({dynamic entity, required dynamic db});
}
