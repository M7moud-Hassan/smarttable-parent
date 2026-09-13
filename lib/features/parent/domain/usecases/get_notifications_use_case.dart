import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/notification_model.dart';
import 'base_use_case.dart';

class GetNotificationsUseCase extends BaseUseCase {
  const GetNotificationsUseCase({required super.repo, required super.db});

  Future<Either<Failure, List<ParentNotification>>> call() =>
      repo.calling(db: db.notifications);
}
