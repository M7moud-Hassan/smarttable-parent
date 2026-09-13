import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/service_entities.dart';
import 'base_use_case.dart';

class RespondToActionUseCase extends BaseUseCase {
  const RespondToActionUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call(ActionResponseEntity entity) =>
      repo.calling(db: db.respondToAction, entity: entity);
}
