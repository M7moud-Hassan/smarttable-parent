import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/parent_model.dart';
import 'base_use_case.dart';

class GetMeUseCase extends BaseUseCase {
  const GetMeUseCase({required super.repo, required super.db});

  Future<Either<Failure, ParentUser>> call() => repo.calling(db: db.me);
}
