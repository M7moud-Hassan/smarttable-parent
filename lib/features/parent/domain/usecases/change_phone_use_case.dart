import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/parent_model.dart';
import '../entities/auth_entities.dart';
import 'base_use_case.dart';

/// الخطوة الثانية: الرمز يثبّت الرقم الجديد.
///
/// ويعيد وليّ الأمر بعد إعادة ربط أبنائه بالرقم، فما تعرضه الشاشات بعدها
/// هو حالة الخادم لا حالةً مخمَّنة في التطبيق.
class ChangePhoneUseCase extends BaseUseCase {
  const ChangePhoneUseCase({required super.repo, required super.db});

  Future<Either<Failure, ParentUser>> call(OtpEntity entity) =>
      repo.calling(db: db.changePhone, entity: entity);
}
