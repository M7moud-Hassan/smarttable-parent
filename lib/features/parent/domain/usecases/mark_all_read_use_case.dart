import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import 'base_use_case.dart';

class MarkAllReadUseCase extends BaseUseCase {
  const MarkAllReadUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call() => repo.calling(db: db.markAllRead);
}
