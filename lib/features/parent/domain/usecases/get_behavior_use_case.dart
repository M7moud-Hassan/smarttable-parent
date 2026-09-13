import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/service_entities.dart';
import '../../data/models/behavior_model.dart';
import 'base_use_case.dart';

class GetBehaviorUseCase extends BaseUseCase {
  const GetBehaviorUseCase({required super.repo, required super.db});

  Future<Either<Failure, BehaviorReport>> call(BehaviorFilterEntity entity) =>
      repo.calling(db: db.behavior, entity: entity);
}
