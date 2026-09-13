import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/home_model.dart';
import 'base_use_case.dart';

class GetHomeUseCase extends BaseUseCase {
  const GetHomeUseCase({required super.repo, required super.db});

  Future<Either<Failure, HomeSummary>> call(StudentEntity entity) =>
      repo.calling(db: db.home, entity: entity);
}
