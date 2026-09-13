import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/home_model.dart';
import 'base_use_case.dart';

class GetNotificationSettingsUseCase extends BaseUseCase {
  const GetNotificationSettingsUseCase({required super.repo, required super.db});

  Future<Either<Failure, List<NotificationSetting>>> call() =>
      repo.calling(db: db.notificationSettings);
}
