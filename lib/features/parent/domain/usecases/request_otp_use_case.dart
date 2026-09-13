import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import 'base_use_case.dart';

class RequestOtpUseCase extends BaseUseCase {
  const RequestOtpUseCase({required super.repo, required super.db});

  Future<Either<Failure, String>> call(PhoneEntity entity) =>
      repo.calling(db: db.requestOtp, entity: entity);
}
