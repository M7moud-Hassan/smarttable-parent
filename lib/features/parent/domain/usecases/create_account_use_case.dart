import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import '../../data/models/parent_model.dart';
import 'base_use_case.dart';

class CreateAccountUseCase extends BaseUseCase {
  const CreateAccountUseCase({required super.repo, required super.db});

  Future<Either<Failure, ParentUser>> call(CreateAccountEntity entity) =>
      repo.calling(db: db.createAccount, entity: entity);
}
