import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/attendance_model.dart';
import 'base_use_case.dart';

class GetAbsencePeriodUseCase extends BaseUseCase {
  const GetAbsencePeriodUseCase({required super.repo, required super.db});

  Future<Either<Failure, ExcuseForm>> call(IdEntity entity) =>
      repo.calling(db: db.absencePeriod, entity: entity);
}
