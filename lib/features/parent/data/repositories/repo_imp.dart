import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/calling.dart';
import '../../domain/repositories/repo.dart';

class RepoImp implements Repo {
  RepoImp({required this.call});

  final Calling call;

  @override
  Future<Either<Failure, T>> calling<T>({dynamic entity, required dynamic db}) =>
      call(db, entity);
}
