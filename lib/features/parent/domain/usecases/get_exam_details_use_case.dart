import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/exam_model.dart';
import 'base_use_case.dart';

class GetExamDetailsUseCase extends BaseUseCase {
  const GetExamDetailsUseCase({required super.repo, required super.db});

  Future<Either<Failure, Exam>> call(IdEntity entity) =>
      repo.calling(db: db.examDetails, entity: entity);
}
