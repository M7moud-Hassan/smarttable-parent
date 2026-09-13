import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/school_model.dart';
import 'base_use_case.dart';

class GetSchoolUseCase extends BaseUseCase {
  const GetSchoolUseCase({required super.repo, required super.db});

  Future<Either<Failure, SchoolInfo>> call(StudentEntity entity) =>
      repo.calling(db: db.school, entity: entity);
}
