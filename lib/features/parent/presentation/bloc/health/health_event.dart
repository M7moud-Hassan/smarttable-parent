part of 'health_bloc.dart';

sealed class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

final class GetHealthEvent extends HealthEvent {
  const GetHealthEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

final class ToggleDiseaseEvent extends HealthEvent {
  const ToggleDiseaseEvent({required this.disease});

  final String disease;

  @override
  List<Object?> get props => [disease];
}

final class ChangeInstructionsEvent extends HealthEvent {
  const ChangeInstructionsEvent({required this.instructions});

  final String instructions;

  @override
  List<Object?> get props => [instructions];
}

final class AttachMedicalReportEvent extends HealthEvent {
  const AttachMedicalReportEvent({required this.path});

  final String path;

  @override
  List<Object?> get props => [path];
}

final class SaveHealthEvent extends HealthEvent {
  const SaveHealthEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}
