import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/health_model.dart';
import 'base_use_case.dart';

class GetHealthUseCase extends BaseUseCase {
  const GetHealthUseCase({required super.repo, required super.db});

  Future<Either<Failure, HealthRecord>> call(StudentEntity entity) =>
      repo.calling(db: db.health, entity: entity);
}
