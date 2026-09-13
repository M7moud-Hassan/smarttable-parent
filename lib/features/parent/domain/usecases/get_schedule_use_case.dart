import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/schedule_model.dart';
import 'base_use_case.dart';

class GetScheduleUseCase extends BaseUseCase {
  const GetScheduleUseCase({required super.repo, required super.db});

  Future<Either<Failure, WeekSchedule>> call(StudentEntity entity) =>
      repo.calling(db: db.schedule, entity: entity);
}
