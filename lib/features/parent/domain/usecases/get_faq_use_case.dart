import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/school_model.dart';
import 'base_use_case.dart';

class GetFaqUseCase extends BaseUseCase {
  const GetFaqUseCase({required super.repo, required super.db});

  Future<Either<Failure, List<FaqItem>>> call() => repo.calling(db: db.faq);
}
