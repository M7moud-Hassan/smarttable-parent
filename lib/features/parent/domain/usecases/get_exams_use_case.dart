import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/exam_model.dart';
import 'base_use_case.dart';

class GetExamsUseCase extends BaseUseCase {
  const GetExamsUseCase({required super.repo, required super.db});

  Future<Either<Failure, List<Exam>>> call(StudentEntity entity) =>
      repo.calling(db: db.exams, entity: entity);
}
