import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import 'base_use_case.dart';

/// الخطوة الأولى من تغيير رقم الجوال: رمز تحقّق إلى الرقم الجديد.
///
/// الرقم معرّف الحساب وصلته بأبنائه، فلا يُحفظ بخطأ مطبّع: الرمز يثبت أن
/// الجهاز الذي يملك الرقم الجديد هو من طلب التغيير.
class RequestPhoneChangeUseCase extends BaseUseCase {
  const RequestPhoneChangeUseCase({required super.repo, required super.db});

  Future<Either<Failure, String>> call(PhoneEntity entity) =>
      repo.calling(db: db.requestPhoneChange, entity: entity);
}
