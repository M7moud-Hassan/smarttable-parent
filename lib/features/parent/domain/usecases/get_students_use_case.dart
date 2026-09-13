import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/student_model.dart';
import 'base_use_case.dart';

class GetStudentsUseCase extends BaseUseCase {
  const GetStudentsUseCase({required super.repo, required super.db});

  Future<Either<Failure, List<Student>>> call() => repo.calling(db: db.students);
}
