part of 'health_bloc.dart';

sealed class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

final class HealthInitial extends HealthState {}

final class HealthLoading extends HealthState {}

final class HealthFailureState extends HealthState {
  const HealthFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure, DateTime.now().microsecondsSinceEpoch];
}

final class HealthSavedState extends HealthState {}

final class HealthFormState extends HealthState {
  const HealthFormState({required this.record, this.attachmentPath});

  final HealthRecord record;

  /// مسار التقرير الجديد قبل الحفظ.
  final String? attachmentPath;

  @override
  List<Object?> get props => [record, attachmentPath];
}
