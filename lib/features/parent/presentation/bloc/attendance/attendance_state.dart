part of 'attendance_bloc.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

final class AttendanceInitial extends AttendanceState {}

final class AttendanceLoading extends AttendanceState {}

final class AttendanceFailureState extends AttendanceState {
  const AttendanceFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class AttendanceLoadedState extends AttendanceState {
  const AttendanceLoadedState({required this.report});

  final AttendanceReport report;

  @override
  List<Object?> get props => [report];
}
