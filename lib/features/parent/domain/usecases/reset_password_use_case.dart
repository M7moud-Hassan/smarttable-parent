import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import 'base_use_case.dart';

class ResetPasswordUseCase extends BaseUseCase {
  const ResetPasswordUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call(ResetPasswordEntity entity) =>
      repo.calling(db: db.resetPassword, entity: entity);
}
