import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import '../../data/models/parent_model.dart';
import 'base_use_case.dart';

class LoginUseCase extends BaseUseCase {
  const LoginUseCase({required super.repo, required super.db});

  Future<Either<Failure, ParentUser>> call(LoginEntity entity) =>
      repo.calling(db: db.login, entity: entity);
}
