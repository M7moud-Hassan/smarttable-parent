import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import 'base_use_case.dart';

class ChangePasswordUseCase extends BaseUseCase {
  const ChangePasswordUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call(ChangePasswordEntity entity) =>
      repo.calling(db: db.changePassword, entity: entity);
}
