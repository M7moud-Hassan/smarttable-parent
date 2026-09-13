import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/school_model.dart';
import 'base_use_case.dart';

class GetSupportUseCase extends BaseUseCase {
  const GetSupportUseCase({required super.repo, required super.db});

  Future<Either<Failure, SchoolInfo>> call() => repo.calling(db: db.support);
}
