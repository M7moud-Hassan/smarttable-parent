import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/base_entity.dart';
import '../../data/models/attendance_model.dart';
import 'base_use_case.dart';

class GetAttendanceUseCase extends BaseUseCase {
  const GetAttendanceUseCase({required super.repo, required super.db});

  Future<Either<Failure, AttendanceReport>> call(StudentEntity entity) =>
      repo.calling(db: db.attendance, entity: entity);
}
