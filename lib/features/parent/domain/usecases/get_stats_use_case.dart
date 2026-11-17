import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/stats_model.dart';
import '../entities/service_entities.dart';
import 'base_use_case.dart';

class GetStatsUseCase extends BaseUseCase {
  const GetStatsUseCase({required super.repo, required super.db});

  Future<Either<Failure, StudentStats>> call(StatsFilterEntity entity) =>
      repo.calling(db: db.stats, entity: entity);
}
