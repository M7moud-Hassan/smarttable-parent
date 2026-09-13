import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import 'base_use_case.dart';

class VerifyOtpUseCase extends BaseUseCase {
  const VerifyOtpUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call(OtpEntity entity) =>
      repo.calling(db: db.verifyOtp, entity: entity);
}
