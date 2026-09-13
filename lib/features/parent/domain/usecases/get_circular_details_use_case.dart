import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/circular_model.dart';
import 'base_use_case.dart';

class GetCircularDetailsUseCase extends BaseUseCase {
  const GetCircularDetailsUseCase({required super.repo, required super.db});

  Future<Either<Failure, Circular>> call(IdEntity entity) =>
      repo.calling(db: db.circularDetails, entity: entity);
}
