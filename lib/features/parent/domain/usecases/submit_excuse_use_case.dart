import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/service_entities.dart';
import 'base_use_case.dart';

class SubmitExcuseUseCase extends BaseUseCase {
  const SubmitExcuseUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call(ExcuseEntity entity) =>
      repo.calling(db: db.submitExcuse, entity: entity);
}
