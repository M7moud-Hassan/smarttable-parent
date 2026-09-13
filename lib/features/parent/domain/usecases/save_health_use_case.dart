import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/service_entities.dart';
import 'base_use_case.dart';

class SaveHealthUseCase extends BaseUseCase {
  const SaveHealthUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call(HealthEntity entity) =>
      repo.calling(db: db.saveHealth, entity: entity);
}
