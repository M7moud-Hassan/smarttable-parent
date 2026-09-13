part of 'excuse_bloc.dart';

sealed class ExcuseEvent extends Equatable {
  const ExcuseEvent();

  @override
  List<Object?> get props => [];
}

final class GetAbsencePeriodEvent extends ExcuseEvent {
  const GetAbsencePeriodEvent({required this.periodId});

  final String periodId;

  @override
  List<Object?> get props => [periodId];
}

final class ToggleExcuseDayEvent extends ExcuseEvent {
  const ToggleExcuseDayEvent({required this.dayId});

  final String dayId;

  @override
  List<Object?> get props => [dayId];
}

final class SelectExcuseReasonEvent extends ExcuseEvent {
  const SelectExcuseReasonEvent({required this.reason});

  final String reason;

  @override
  List<Object?> get props => [reason];
}

final class ChangeExcuseNoteEvent extends ExcuseEvent {
  const ChangeExcuseNoteEvent({required this.note});

  final String note;

  @override
  List<Object?> get props => [note];
}

final class AttachExcuseFileEvent extends ExcuseEvent {
  const AttachExcuseFileEvent({required this.path});

  final String path;

  @override
  List<Object?> get props => [path];
}

final class SubmitExcuseEvent extends ExcuseEvent {
  const SubmitExcuseEvent({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}
