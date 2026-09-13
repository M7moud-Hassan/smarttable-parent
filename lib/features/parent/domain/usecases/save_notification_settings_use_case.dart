import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/service_entities.dart';
import 'base_use_case.dart';

class SaveNotificationSettingsUseCase extends BaseUseCase {
  const SaveNotificationSettingsUseCase({required super.repo, required super.db});

  Future<Either<Failure, bool>> call(NotificationSettingsEntity entity) =>
      repo.calling(db: db.saveNotificationSettings, entity: entity);
}
