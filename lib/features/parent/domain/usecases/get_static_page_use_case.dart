import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/service_entities.dart';
import '../../data/models/school_model.dart';
import 'base_use_case.dart';

class GetStaticPageUseCase extends BaseUseCase {
  const GetStaticPageUseCase({required super.repo, required super.db});

  Future<Either<Failure, StaticPage>> call(StaticPageEntity entity) =>
      repo.calling(db: db.staticPage, entity: entity);
}
