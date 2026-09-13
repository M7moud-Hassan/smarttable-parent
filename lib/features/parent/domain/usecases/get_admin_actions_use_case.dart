import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/admin_action_model.dart';
import 'base_use_case.dart';

class GetAdminActionsUseCase extends BaseUseCase {
  const GetAdminActionsUseCase({required super.repo, required super.db});

  Future<Either<Failure, List<AdminAction>>> call(StudentEntity entity) =>
      repo.calling(db: db.adminActions, entity: entity);
}
